#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
set -e

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# Drop the source feed's mosdns and v2ray-geodata definitions, then use the
# maintained package copies. This runs before make defconfig.
find ./ | grep Makefile | grep v2ray-geodata | xargs -r rm -f
find ./ | grep Makefile | grep mosdns | xargs -r rm -f

git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# The current packages feed has Kconfig cycles around optional fwknopd and
# squeezelite features. Keep those packages available, but make feature config
# symbols select their packages instead of letting packages depend back on the
# feature symbols.
python3 - <<'PY'
from pathlib import Path
import re

fw_config = Path('feeds/packages/net/fwknop/Config.in')
text = fw_config.read_text()
text = re.sub(
    r'^[ \t]*depends on PACKAGE_fwknopd \|\| PACKAGE_fwknop[ \t]*\n',
    '',
    text,
    flags=re.MULTILINE,
)
if 'select PACKAGE_gnupg2-utils' not in text:
    text = text.replace(
        '\tselect PACKAGE_gnupg2\n',
        '\tselect PACKAGE_gnupg2\n'
        '\tselect PACKAGE_gnupg2-utils\n'
        '\tselect PACKAGE_libgpgme\n',
        1,
    )
if 'select PACKAGE_libnetfilter-queue' not in text:
    text = text.replace(
        '\tselect PACKAGE_iptables-mod-nfqueue\n',
        '\tselect PACKAGE_iptables-mod-nfqueue\n'
        '\tselect PACKAGE_libnetfilter-queue\n'
        '\tselect PACKAGE_libnfnetlink\n',
        1,
    )
fw_config.write_text(text)

fw_make = Path('feeds/packages/net/fwknop/Makefile')
text = fw_make.read_text()
replacements = [
    (
        '  DEPENDS:=+iptables +libfko +!FWKNOPD_NFQ_CAPTURE:libpcap '
        '+FWKNOPD_NFQ_CAPTURE:iptables-mod-nfqueue \\\n'
        '\t+FWKNOPD_NFQ_CAPTURE:libnetfilter-queue '
        '+FWKNOPD_NFQ_CAPTURE:libnfnetlink \\\n'
        '\t+FWKNOPD_GPG:gnupg2 +FWKNOPD_GPG:gnupg2-utils '
        '+FWKNOPD_GPG:libgpgme',
        '  DEPENDS:=+iptables +libfko +libpcap',
    ),
    (
        '  DEPENDS:=+libfko +FWKNOPD_GPG:gnupg2 '
        '+FWKNOPD_GPG:gnupg2-utils +FWKNOPD_GPG:libgpgme',
        '  DEPENDS:=+libfko',
    ),
    (
        '  DEPENDS:=+FWKNOPD_GPG:gnupg2 +FWKNOPD_GPG:gnupg2-utils '
        '+FWKNOPD_GPG:libgpgme',
        '  DEPENDS:=',
    ),
]
for old, new in replacements:
    if old not in text:
        raise SystemExit(f'fwknop dependency block not found: {old[:60]}')
    text = text.replace(old, new, 1)
fw_make.write_text(text)

sq_make = Path('feeds/packages/sound/squeezelite/Makefile')
text = sq_make.read_text()
old = '\t\tif PACKAGE_squeezelite-custom\n'
if old not in text:
    raise SystemExit('squeezelite config guard not found')
sq_make.write_text(text.replace(old, '\t\tif y\n', 1))
PY

# Passwall luci-app: use official Openwrt-Passwall feed (passwall_luci, newer than
# immortalwrt bundled). Do NOT delete it — let it install normally so defconfig
# can expand INCLUDE_* options. INCLUDE_ShadowsocksR_Libev_Client is set to
# 'not set' in .config to avoid pulling shadowsocksr-libev (build failure).
# (Previously rm -rf feeds/passwall_luci/luci-app-passwall here — broke install
# symlink, caused passwall to vanish from defconfig. Removed 2026-07-26.)

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

# The current packages feed declares Kconfig cycles around optional features of
# fwknopd and squeezelite-custom. Neither package is enabled in this image, but
# Kconfig still validates every installed package graph, and LuCI apps inherit
# "depends on" edges from the conditional selects of the packages they select.
# Neutralise both feature menus and drop the conditional dependencies:
#  - fwknopd: stop sourcing Config.in and remove the +FWKNOPD_* conditional
#    dependencies so no gnupg2/nfqueue select edges remain.
#  - squeezelite-custom: make its feature menu unconditional so the options no
#    longer depend back on PACKAGE_squeezelite-custom.
sed -i 's|^define Package/fwknopd/config[[:space:]]*$|define Package/fwknopd/config-disabled|' \
  feeds/packages/net/fwknop/Makefile
sed -i 's|^[[:space:]]*if PACKAGE_squeezelite-custom[[:space:]]*$|if y|' \
  feeds/packages/sound/squeezelite/Makefile

python3 - <<'PY'
from pathlib import Path
p = Path('feeds/packages/net/fwknop/Makefile')
t = p.read_text()
old_daemon = (
    '  DEPENDS:=+iptables +libfko +!FWKNOPD_NFQ_CAPTURE:libpcap '
    '+FWKNOPD_NFQ_CAPTURE:iptables-mod-nfqueue \\\n'
    '\t+FWKNOPD_NFQ_CAPTURE:libnetfilter-queue '
    '+FWKNOPD_NFQ_CAPTURE:libnfnetlink \\\n'
    '\t+FWKNOPD_GPG:gnupg2 +FWKNOPD_GPG:gnupg2-utils '
    '+FWKNOPD_GPG:libgpgme'
)
old_client = (
    '  DEPENDS:=+libfko +FWKNOPD_GPG:gnupg2 +FWKNOPD_GPG:gnupg2-utils '
    '+FWKNOPD_GPG:libgpgme'
)
old_lib = (
    '  DEPENDS:=+FWKNOPD_GPG:gnupg2 +FWKNOPD_GPG:gnupg2-utils '
    '+FWKNOPD_GPG:libgpgme'
)
for old, new in (
    (old_daemon, '  DEPENDS:=+iptables +libfko +libpcap'),
    (old_client, '  DEPENDS:=+libfko'),
    (old_lib, '  DEPENDS:='),
):
    if old not in t:
        raise SystemExit('fwknop DEPENDS block not found: ' + old[:50])
    t = t.replace(old, new, 1)
p.write_text(t)
PY

grep -q '^define Package/fwknopd/config-disabled$' feeds/packages/net/fwknop/Makefile
grep -qE '^[[:space:]]*if y[[:space:]]*$' feeds/packages/sound/squeezelite/Makefile
! grep -q 'FWKNOPD_GPG:gnupg2' feeds/packages/net/fwknop/Makefile

# Passwall luci-app: use official Openwrt-Passwall feed (passwall_luci, newer than
# immortalwrt bundled). Do NOT delete it — let it install normally so defconfig
# can expand INCLUDE_* options. INCLUDE_ShadowsocksR_Libev_Client is set to
# 'not set' in .config to avoid pulling shadowsocksr-libev (build failure).
# (Previously rm -rf feeds/passwall_luci/luci-app-passwall here — broke install
# symlink, caused passwall to vanish from defconfig. Removed 2026-07-26.)

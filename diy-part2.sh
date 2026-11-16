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
# Kconfig still validates every installed package graph. Neutralise the two
# feature menus so the symbols cannot participate in a dependency cycle:
#  - fwknopd: stop sourcing Config.in, so FWKNOPD_GPG / FWKNOPD_NFQ_CAPTURE are
#    undefined and every "if FWKNOPD_*" select/depends edge becomes inactive.
#  - squeezelite-custom: make its feature menu unconditional so the options no
#    longer depend back on PACKAGE_squeezelite-custom.
sed -i 's|^define Package/fwknopd/config[[:space:]]*$|define Package/fwknopd/config-disabled|' \
  feeds/packages/net/fwknop/Makefile
sed -i 's|^[[:space:]]*if PACKAGE_squeezelite-custom[[:space:]]*$|if y|' \
  feeds/packages/sound/squeezelite/Makefile

grep -q '^define Package/fwknopd/config-disabled$' feeds/packages/net/fwknop/Makefile
grep -qE '^[[:space:]]*if y[[:space:]]*$' feeds/packages/sound/squeezelite/Makefile

# Passwall luci-app: use official Openwrt-Passwall feed (passwall_luci, newer than
# immortalwrt bundled). Do NOT delete it — let it install normally so defconfig
# can expand INCLUDE_* options. INCLUDE_ShadowsocksR_Libev_Client is set to
# 'not set' in .config to avoid pulling shadowsocksr-libev (build failure).
# (Previously rm -rf feeds/passwall_luci/luci-app-passwall here — broke install
# symlink, caused passwall to vanish from defconfig. Removed 2026-07-26.)

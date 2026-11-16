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

# These unused packages currently make Kconfig fail globally with recursive
# dependencies. Remove only their generated package/feeds links; the feed
# checkouts stay intact and can be reinstalled later if needed.
rm -rf package/feeds/packages/fwknop
rm -rf package/feeds/packages/squeezelite
rm -rf package/feeds/luci/luci-app-fwknopd

test ! -e package/feeds/packages/fwknop
test ! -e package/feeds/packages/squeezelite
test ! -e package/feeds/luci/luci-app-fwknopd

# Passwall luci-app: use official Openwrt-Passwall feed (passwall_luci, newer than
# immortalwrt bundled). Do NOT delete it — let it install normally so defconfig
# can expand INCLUDE_* options. INCLUDE_ShadowsocksR_Libev_Client is set to
# 'not set' in .config to avoid pulling shadowsocksr-libev (build failure).
# (Previously rm -rf feeds/passwall_luci/luci-app-passwall here — broke install
# symlink, caused passwall to vanish from defconfig. Removed 2026-07-26.)

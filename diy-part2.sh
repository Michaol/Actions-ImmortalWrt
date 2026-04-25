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

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# drop mosdns and v2ray-geodata packages that come with the source
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f

git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Replace passwall
#rm -rf feeds/luci/applications/luci-app-passwall
#git clone -b main https://github.com/xiaorouji/openwrt-passwall.git feeds/luci/applications/passwall
#mv feeds/luci/applications/passwall/luci-app-passwall feeds/luci/applications/
#rm -rf feeds/luci/applications/passwall

# Fix util-linux AT_HANDLE_FID on musl (Issue #23058)
mkdir -p package/utils/util-linux/patches
wget -qO package/utils/util-linux/patches/0002-nsenter-Fix-AT_HANDLE_FID-on-musl.patch https://github.com/util-linux/util-linux/commit/5452239f6e69d2d3aaa427d2d2253247cfb7cb7b.patch

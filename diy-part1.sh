#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
set -e

FEEDS=feeds.conf.default

# Add idempotently so this script is safe to run more than once.
grep -q '^src-git daeuniverse ' "$FEEDS" ||
  sed -i '1i src-git daeuniverse https://github.com/daeuniverse/openwrt-packages.git;main' "$FEEDS"
grep -q '^src-git passwall_luci ' "$FEEDS" ||
  sed -i '1i src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' "$FEEDS"
grep -q '^src-git passwall_packages ' "$FEEDS" ||
  sed -i '1i src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' "$FEEDS"

# This router does not need the desktop/video packages, and Qt5 currently has
# a recursive Kconfig dependency when the video feed is installed.
sed -i '/^src-git video /s/^/#/' "$FEEDS"

#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

FEEDS_PATH="./feeds"
PACKAGE_PATH="./package"

#修改argon主题字体和颜色
if [ -d "$PACKAGE_PATH/luci-theme-argon" ]; then
	echo " "
	if sed -i "s/primary '.*'/primary '#31a1a1'/g; s/'0.2'/'0.5'/g; s/'none'/'bing'/g; s/'600'/'normal'/g" \
		"$PACKAGE_PATH/luci-theme-argon/luci-app-argon-config/root/etc/config/argon"; then
		echo "theme-argon has been fixed!"
	else
		echo "theme-argon fix failed; continuing!"
	fi
fi

#修改aurora菜单式样
if [ -d "$PACKAGE_PATH/luci-app-aurora-config" ]; then
	echo " "
	if find "$PACKAGE_PATH/luci-app-aurora-config/root/usr/share/aurora/" -type f -name '*.template' -exec \
		sed -i "s/nav_type '.*'/nav_type 'dropdown'/g; s/struct_radius_base '.*'/struct_radius_base '0.125rem'/g" {} +; then
		echo "theme-aurora has been fixed!"
	else
		echo "theme-aurora fix failed; continuing!"
	fi
fi

#修改mini-diskmanager菜单位置
if [ -d "$PACKAGE_PATH/luci-app-mini-diskmanager" ]; then
	echo " "
	if sed -i "s/services/system/g" \
		"$PACKAGE_PATH/luci-app-mini-diskmanager/luci-app-mini-diskmanager/root/usr/share/luci/menu.d/luci-app-mini-diskmanager.json"; then
		echo "mini-diskmanager has been fixed!"
	else
		echo "mini-diskmanager fix failed; continuing!"
	fi
fi

#修改natmapt菜单位置
if [ -d "$PACKAGE_PATH/luci-app-natmapt" ]; then
	echo " "
	if sed -i "s/network/services/g" \
		"$PACKAGE_PATH/luci-app-natmapt/root/usr/share/luci/menu.d/luci-app-natmap.json"; then
		echo "natmapt has been fixed!"
	else
		echo "natmapt fix failed; continuing!"
	fi
fi

#修复QModem依赖循环
if [ -d "$PACKAGE_PATH/QModem" ]; then
	echo " "
	if sed -i 's/@!PACKAGE_luci-app-qmodem //g; s/+luci-app-qmodem-next/luci-app-qmodem-next/g' \
		"$PACKAGE_PATH/QModem/luci/luci-app-qmodem-next/Makefile"; then
		echo "QModem has been fixed!"
	else
		echo "QModem fix failed; continuing!"
	fi
fi

#修复Rust编译失败
if [ -d "$FEEDS_PATH/packages/lang/rust" ]; then
	echo " "
	if sed -i 's/ci-llvm=true/ci-llvm=false/g' \
		"$FEEDS_PATH/packages/lang/rust/Makefile"; then
		echo "rust has been fixed!"
	else
		echo "rust fix failed; continuing!"
	fi
fi

# Fibocom QMI WWAN 驱动使用了 Linux 6.6 已移除的 _irq 统计接口，
# 并直接写入只读的 dev_addr；在编译前修正上游源码。
QMI_WWAN_SOURCE="$PACKAGE_PATH/mtk/applications/5g-modem/fibocom_QMI_WWAN/src/qmi_wwan_f.c"
if [ -f "$QMI_WWAN_SOURCE" ]; then
	if sed -i \
		-e 's/u64_stats_fetch_begin_irq(/u64_stats_fetch_begin(/g' \
		-e 's/u64_stats_fetch_retry_irq(/u64_stats_fetch_retry(/g' \
		-e 's/memcpy (qmap_net->dev_addr, real_dev->dev_addr, ETH_ALEN);/eth_hw_addr_set(qmap_net, real_dev->dev_addr);/' \
		"$QMI_WWAN_SOURCE"; then
		echo "Fibocom QMI WWAN has been fixed for Linux 6.6!"
	else
		echo "Fibocom QMI WWAN fix failed!" >&2
		exit 1
	fi
fi

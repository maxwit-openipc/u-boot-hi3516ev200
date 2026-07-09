#!/usr/bin/env bash

if [ $# -gt 0 ]; then
	board_list=$1
else
	board_list="
	hi3516ev200-demb
	16ev2-2053
	hi3516ev300-demb
	hi3518ev300-demb
	"
fi

test -z $OUTPUT && OUTPUT=output
# rm -vf $OUTPUT/u-boot*
mkdir -p $OUTPUT

if [ -z "$TOOLCHAIN" ]; then
	for t in arm-himix100-linux- arm-linux-gcc arm-none-eabi-
	do
		if which ${t}gcc > /dev/null; then
			TOOLCHAIN=$t
			break
		fi
	done
fi

if [ -z $TOOLCHAIN ]; then
	echo "No toolchain found!"
	exit 1
fi

for board in $board_list
do
	case $(echo $board | tr A-Z a-z) in
	*16ev2*)
		soc=hi3516ev200
		;;
	*16ev3*)
		soc=hi3516ev300
		;;
	*18ev3*)
		soc=hi3518ev300
		;;
	*)
		echo "'$board' NOT supported"
		exit 1
	esac

	echo "Building u-boot for $board ($soc) ..."

	make distclean

	make ${soc}_defconfig

	cp -v reg_info_${soc}.bin .reg
	make CROSS_COMPILE=$TOOLCHAIN DEVICE_TREE=${board} $XOPT || exit 1

	[ ! -f tools/hi_gzip/bin/gzip ] && make -C tools/hi_gzip SHELL=/bin/bash
	cp -v tools/hi_gzip/bin/gzip arch/arm/cpu/armv7/${soc}/hw_compressed/ || exit 1

	make CROSS_COMPILE=$TOOLCHAIN u-boot-z.bin || exit 1

	# cp -v u-boot-${soc}.bin u-boot-${soc}-universal.bin
	mkdir -vp $OUTPUT/$soc
	cp -v u-boot-${soc}.bin $OUTPUT/$soc/u-boot-${board}.bin

	echo
done

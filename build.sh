mkdir -vp output

test -z "$TOOLCHAIN" && TOOLCHAIN=arm-himix100-linux-

for board in hi3516ev200-demb hi3516ev300-demb hi3518ev300-demb
do
    soc=${board%-demb} # FIXME

    echo "Building u-boot for $soc ..."

    make clean

    make ${soc}_defconfig

    cp -v reg_info_${soc}.bin .reg
    make CROSS_COMPILE=$TOOLCHAIN DEVICE_TREE=${board} -j$(nproc) || exit 1

    [ ! -f tools/hi_gzip/bin/gzip ] && make -C tools/hi_gzip SHELL=/bin/bash
    cp -v tools/hi_gzip/bin/gzip arch/arm/cpu/armv7/${soc}/hw_compressed/ || exit 1

    make CROSS_COMPILE=$TOOLCHAIN u-boot-z.bin || exit 1

    cp -v u-boot-${soc}.bin u-boot-${soc}-universal.bin
    cp -v u-boot-${soc}.bin output/u-boot-${board}.bin

    echo
done

mkdir -vp output

TOOLCHAIN=arm-himix100-linux-
# TOOLCHAIN=$PWD/../output-hi3516ev200/host/bin/arm-openipc-linux-musleabi-

for soc in hi3516ev200 hi3516ev300 hi3518ev300
do
    make clean

    cp -v config-${soc} .config

    cp -v reg_info_${soc}.bin .reg
    make CROSS_COMPILE=$TOOLCHAIN -j$(nproc) || exit 1

    [ ! -f tools/hi_gzip/bin/gzip ] && make -C tools/hi_gzip SHELL=/bin/bash || cp -v tools/hi_gzip/bin/gzip arch/arm/cpu/armv7/${soc}/hw_compressed/

    make CROSS_COMPILE=$TOOLCHAIN u-boot-z.bin || exit 1

    cp -v u-boot-${soc}.bin output/

    echo
done

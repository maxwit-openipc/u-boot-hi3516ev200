mkdir -vp output

for soc in hi3516ev200 hi3516ev300 hi3518ev300
do
    make clean

    cp -v config-${soc} .config

    cp -v reg_info_${soc}.bin .reg
    make CROSS_COMPILE=arm-himix100-linux- -j$(nproc)

    [ ! -f tools/hi_gzip/bin/gzip ] && make -C tools/hi_gzip SHELL=/bin/bash || cp tools/hi_gzip/bin/gzip arch/arm/cpu/armv7/${soc}/hw_compressed/ -rf

    make CROSS_COMPILE=arm-himix100-linux- u-boot-z.bin

    cp -v u-boot-${soc}.bin output/

    echo
done

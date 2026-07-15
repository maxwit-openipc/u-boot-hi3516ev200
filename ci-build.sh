#!/bin/bash -e

target_board=$1
OUTPUT=${OUTPUT:-$PWD/output}
XOPT=${XOPT:-V=1}

count=0
for dts in `ls arch/arm/dts/*.dts`
do
    chip_ids=($(grep -m1 -o '"hisilicon,hi35[0-9]\+[adce]v[1-9]00";' $dts | sed 's/[",;]/ /g'))
    test ${#chip_ids[@]} -ne 2 && continue

    # vendor=${chip_ids[0]}
    soc=${chip_ids[1]}

    board=$(grep -m1 'compatible' $dts | awk -F ',' '{print $2}' | sed 's/[",;]//g')
    test -n "$target_board" -a "$target_board" != $board && continue

    for tc in arm-openipc-linux-musleabi- \
        arm-linux-musleabi- \
        arm-linux-gnueabi- \
        arm-linux- \
        arm-none-eabi-
    do
        for out in $PWD/output $(dirname $PWD)/output $OUTPUT
        do
            path=$out/$soc/host/bin
            if test -e $path/${tc}gcc; then
                toolchain=$path/$tc
                break
            fi
        done

        test -n "$toolchain" && break

        if which ${tc}gcc > /dev/null; then
            toolchain=$tc
            break
        fi
    done

    if [ -z "$toolchain" ]; then
        echo "No toolchain found for $soc!"
        echo "Skip to build u-boot for $board!"
        echo
        continue
    fi

    echo "Building u-boot for $board ($soc) ..."

    make distclean

    make ${soc}_defconfig

    dtb=$(basename ${dts%.dts})
    cp -v reg_info_${soc}.bin .reg
    make CROSS_COMPILE=$toolchain DEVICE_TREE=$dtb $XOPT

    [ ! -f tools/hi_gzip/bin/gzip ] && make -C tools/hi_gzip
    cp -v tools/hi_gzip/bin/gzip arch/arm/cpu/armv7/$soc/hw_compressed/

    make CROSS_COMPILE=$toolchain u-boot-z.bin

    outfile="u-boot-${soc}.bin"
    outsize=$(stat -c %s $outfile)
    if [ "$outsize" -gt $((256 << 10)) ]; then
        echo "$outfile size is to large ($((outsize >> 10))K)!"
        exit 1
    fi

    # cp -v u-boot-${soc}.bin u-boot-${soc}-universal.bin
    mkdir -vp $OUTPUT/$soc
    cp -v $outfile $OUTPUT/$soc/u-boot-${board}.bin

    count=$((count + 1))
    echo

    test "$target_board" == $board && break
done

echo "Total $count boards was built."
echo

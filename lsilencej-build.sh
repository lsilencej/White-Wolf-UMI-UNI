#!/bin/bash

# Resources
KERNEL="Image"
DTBOIMG="dtbo.img"

# Defconfigs
UMIDEFCONFIG="lsilencej_umi_defconfig"

# Build dirs
KERNEL_DIR="/home/lsilencej/android/White-Wolf-UMI-UNI-KernelSU"
ANYKERNEL_DIR="/home/lsilencej/android/AnyKernel3"
MODULES_DIR="/home/lsilencej/android/AnyKernel3/modules/system/lib/modules"

# Toolchain paths
CLANG_DIR="/home/lsilencej/android/toolchains/google-clang/bin"
GCC_DIR="/home/lsilencej/android/toolchains/google-gcc/bin"

# Kernel Details
LSILENCEJ_UMI_VER="WHITE.WOLF.UNI.R.UMI.060"

# Vars
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=lsilencej
export KBUILD_BUILD_HOST=kernel

# Image dirs
ZIMAGE_DIR="$KERNEL_DIR/out/arch/arm64/boot"

# Output dir
ZIP_MOVE="/home/lsilencej/android/Zip"

if [ -f "$MODULES_DIR/*.ko" ]; then
	rm `echo $MODULES_DIR"/*.ko"`
fi
if [ -f "$ANYKERNEL_DIR/$KERNEL" ]; then
	rm `echo $ANYKERNEL_DIR/$KERNEL`
fi
if [ -f "$ANYKERNEL_DIR/$DTBOIMG" ]; then
	rm `echo $ANYKERNEL_DIR/$DTBOIMG`
fi
cd $KERNEL_DIR
echo
make clean && make mrproper
rm -rf out/

echo
export LOCALVERSION=-`echo $LSILENCEJ_UMI_VER`
export TARGET_PRODUCT=umi
make O=out ARCH=arm64 $UMIDEFCONFIG

PATH="$CLANG_DIR:$GCC_DIR:${PATH}" \
make -j$(nproc --all) O=out \
	ARCH=arm64 \
        CC=clang \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        CROSS_COMPILE=aarch64-linux-android-

cp -vr $ZIMAGE_DIR/$KERNEL $ANYKERNEL_DIR
cp -vr $ZIMAGE_DIR/$DTBOIMG $ANYKERNEL_DIR
find ${KERNEL_DIR} -name '*.ko' -exec cp -v {} ${MODULES_DIR} \;

cd $ANYKERNEL_DIR
zip -r9 `echo $LSILENCEJ_UMI_VER`.zip *
mv  `echo $LSILENCEJ_UMI_VER`.zip $ZIP_MOVE
cd $KERNEL_DIR

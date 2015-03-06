#!/bin/bash

## ensure deps are installed
sudo add-apt-repository ppa:phablet-team/tools
sudo apt-get update
sudo apt-get install -y phablet-tools
sudo apt-get install -y git gnupg flex bison gperf build-essential \
  zip bzr curl libc6-dev libncurses5-dev:i386 x11proto-core-dev \
  libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 \
  libgl1-mesa-dev g++-multilib mingw32 tofrodos \
  python-markdown libxml2-utils xsltproc zlib1g-dev:i386 schedtool \
  g++-4.8-multilib
  
 # prepare env
mkdir phablet
phablet-dev-bootstrap phablet
cd phablet
TOPDIR=`pwd`
DIFFDIR=$(TOPDIR)/diffs
CMDIFFDIR=$(DIFFDIR)/cm-diffs

mkdir -p device/samsung
# mkdir -p hardware/samsung
mkdir -p kernel/samsung

# device/samsung prep
cd device/samsung
git clone https://github.com/CyanogenMod/android_device_samsung_jf-common.git
mv android_device_samsung_jf-common jf-common
cd jf-common
git apply $(CMDIFFDIR)/jf-common.diff
cd ..
git clone https://github.com/CyanogenMod/android_device_samsung_jflte.git
mv android_device_samsung_jflte jflte
cd jflte
git apply $(CMDIFFDIR)/jflte.diff
cd ..
git clone https://github.com/CyanogenMod/android_device_samsung_msm8960-common.git
mv android_device_samsung_msm8960-common msm8960-common
cd msm8960-common
git apply $(CMDIFFDIR)/msm8960-common.diff
cd ..
git clone https://github.com/CyanogenMod/android_device_samsung_qcom-common.git
mv android_device_samsung_qcom-common qcom-common
cd $(TOPDIR)

# hardware/samsung prep
cd hardware
git clone https://github.com/CyanogenMod/android_hardware_samsung.git
mv android_hardware_samsung samsung
cd $(TOPDIR)

# kernel/samsung prep
cd kernel/samsung
git clone --depth 1 https://github.com/CyanogenMod/android_kernel_samsung_jf.git
mv android_kernel_samsung_jf jf
cd $(TOPDIR)

# fix kconfig
git clone https://github.com/janimo/phablet-porting-scripts.git
cd phablet-porting-scripts/kernel
./check-config ../kernel/samsung/jf/arch/arm/configs/cyanogenmod_jf_defconfig -w
cd $(TOPDIR)

# patch ubuntu-projects from repo
cd build
git apply $(DIFFDIR)/build-diff.txt
cd $(TOPDIR)

cd frameworks/av
git apply $(DIFFDIR)/frameworks_av-diff.txt
cd $(TOPDIR)

cd hardware/libhardware_legacy
git apply $(DIFFDIR)/hardware_libhardware_legacy-diff.txt
cd $(TOPDIR)

cd hardware/qcom
cd audio
git apply $(DIFFDIR)/hardware_qcom_audio-diff.txt
cd ..
cd display
git apply $(DIFFDIR)/hardware_qcom_display-diff.txt
cd ..
cd media
git apply $(DIFFDIR)/hardware_qcom_media-diff.txt
cd ..
cp $(TOPDIR)/added-files/hardware_qcom/crutch-includes.mk crutch-includes.mk
cd $(TOPDIR)
source build/envsetup.sh
echo "Done deal! lunch and make as usual!"
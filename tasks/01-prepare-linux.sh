#!/usr/bin/env bash
#
#  Copyright ©2022-2023 efikarl, https://efikarl.com.
#
#  This program is just made available under the terms and conditions of the
#  MIT license: https://efikarl.com/mit-license.html.
#
#  THE PROGRAM IS DISTRIBUTED UNDER THE MIT LICENSE ON AN "AS IS" BASIS,
#  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

echo "[+]:${BASH_SOURCE[0]}"
pushd .

if [ -z ${WORKSPACE} ]
then
  WORKSPACE=$0
fi
if [ -z ${WORKSPACE} ]
then
  echo "ERR:${BASH_SOURCE[0]}: WORKSPACE not setup!"
  popd
  exit 1
fi

cd  ${WORKSPACE}

if [ ! -d ${WORKSPACE}/${KERNEL_SRC} ]
then
  echo "ERR:${BASH_SOURCE[0]}: KERNEL_SRC not found!"
  popd
  exit 1
fi

# kernel.src
sed -i "s/pkgbase=${KERNEL_SRC}/pkgbase=${KERNEL_DST}/" ./${KERNEL_SRC}/PKGBUILD

# kernel_config_y config
function kernel_config_y()
{
  sed -i "s/^# $1 is not set$/$1=y/" $KERNEL_CFG && sed -i "s/^$1=m$/$1=y/" $KERNEL_CFG && sed -i "s/^$1=n$/$1=y/" $KERNEL_CFG
  cat $KERNEL_CFG | grep $1=y || echo $1=y >> $KERNEL_CFG
}
# kernel_config_m config
function kernel_config_m()
{
  sed -i "s/^# $1 is not set$/$1=m/" $KERNEL_CFG && sed -i "s/^$1=y$/$1=m/" $KERNEL_CFG && sed -i "s/^$1=n$/$1=m/" $KERNEL_CFG
  cat $KERNEL_CFG | grep $1=m || echo $1=m >> $KERNEL_CFG
}
# kernel_config_n config
function kernel_config_n()
{
  sed -i "s/^# $1 is not set$/$1=n/" $KERNEL_CFG && sed -i "s/^$1=y$/$1=n/" $KERNEL_CFG && sed -i "s/^$1=m$/$1=n/" $KERNEL_CFG
}
# kernel_config_d config
function kernel_config_d()
{
  sed -i "s/^$1=y$/# $1 is not set/" $KERNEL_CFG
  sed -i "s/^$1=m$/# $1 is not set/" $KERNEL_CFG
  sed -i "s/^$1=n$/# $1 is not set/" $KERNEL_CFG
}

# devmem acess
kernel_config_n "CONFIG_STRICT_DEVMEM"
kernel_config_n "CONFIG_IO_STRICT_DEVMEM"
# debug: uefi
kernel_config_y "CONFIG_DEBUG_EFI"
kernel_config_y "CONFIG_EFI_PGT_DUMP"
# debug: acpi
kernel_config_y "CONFIG_ACPI_DEBUGGER"
kernel_config_y "CONFIG_ACPI_DEBUGGER_USER"
# debug: ras
kernel_config_y "CONFIG_X86_MCE_INJECT"
kernel_config_y "CONFIG_PCIEAER_INJECT"
kernel_config_y "CONFIG_DEBUG_FS"
kernel_config_y "CONFIG_EDAC_DEBUG"
kernel_config_y "CONFIG_ACPI_APEI"
kernel_config_y "CONFIG_ACPI_APEI_EINJ"
kernel_config_y "CONFIG_ACPI_APEI_GHES"
# debug: test
kernel_config_m "CONFIG_EFI_TEST"

# check: ISOMK_CFG
if [[ ! -d ${WORKSPACE}/${ISOMK_CFG} ]]
then
  cp -rf /usr/share/archiso/configs/${ISOMK_CFG}/ ${WORKSPACE}
fi

popd
echo "[-]:${BASH_SOURCE[0]}"

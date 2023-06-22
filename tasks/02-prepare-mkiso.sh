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

# config.archiso
if [ -z ${ISOMK_CFG} ]
then
  ISOMK_CFG=$1
fi
if [ -z ${ISOMK_CFG} ]
then
  ISOMK_CFG=releng
fi
[[ -d ${WORKSPACE}/${ISOMK_CFG} ]] && rm -rf ${WORKSPACE}/${ISOMK_CFG}
[[ -d ${WORKSPACE}/${ISOMK_CFG} ]] || cp -rf /usr/share/archiso/configs/${ISOMK_CFG}/ ${WORKSPACE}

# ${ISOMK_CFG}/airootfs/etc/mkinitcpio.d/[${KERNEL_DST}.preset]
i=${ISOMK_CFG}/airootfs/etc/mkinitcpio.d
rm -rf $i/* && cp -rf override/$i/* $i

# ${ISOMK_CFG}/airootfs/etc/motd
i=${ISOMK_CFG}/airootfs/etc/motd
cp -rf override/$i   $i

# ${ISOMK_CFG}/airootfs/root/customize_airootfs.sh
i=${ISOMK_CFG}/airootfs/root/customize_airootfs.sh
cp -rf override/$i   $i

# ${ISOMK_CFG}/airootfs/usr/local/bin
i=${ISOMK_CFG}/airootfs/usr/local/bin
cp -rf override/$i/* $i

# ${ISOMK_CFG}/efiboot/loader
i=${ISOMK_CFG}/efiboot/loader
rm -rf $i/* && cp -rf override/$i/* $i

# ${ISOMK_CFG}/grub: never this ugly.
i=${ISOMK_CFG}/grub
rm -rf $i

# ${ISOMK_CFG}/syslinux
i=${ISOMK_CFG}/syslinux
rm -rf $i/* && cp -rf override/$i/* $i

# ${ISOMK_CFG}/packages.x86_64
i=${ISOMK_CFG}/packages.x86_64
t=${ISOMK_CFG}/packages.x86_64.backup
echo "#efikarl@kernel+" >> $t
#.1 kernel
for k in ${KERNEL_DST} ${KERNEL_DST}-headers ${KERNEL_DST}-docs
do
  echo $k >> $t
done
echo "#efikarl@kernel-" >> $t
#.2 org->backup
cat $i >> $t
#.3 tools+
cat override/$i >> $t
#.4 backup->org
mv -f $t $i
#.5 remove linux and grub
sed -i '/^linux$/d' $i && sed -i '/^grub$/d' $i

# ${ISOMK_CFG}/pacman.conf
i=${ISOMK_CFG}/pacman.conf
# enable repo: https://wiki.archlinux.org/title/pacman/tips_and_tricks#custom_local_repository
cat override/$i >> $i

# ${ISOMK_CFG}/profiledef.sh
i=${ISOMK_CFG}/profiledef.sh
cp -rf override/$i $i

popd
echo "[-]:${BASH_SOURCE[0]}"

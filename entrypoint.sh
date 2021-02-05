#!/usr/bin/env bash
THE_SCRIPT=${BASH_SOURCE:-$0}

LIN_CONFIG=$WORKSPACE/linux/config
# config.kernel
asp update linux
asp export linux
config_head='^#'
config_tail='is not set$'
# enable: CONFIG_PCIEAER_INJECT
sed -i "s/$config_head CONFIG_PCIEAER_INJECT $config_tail/CONFIG_PCIEAER_INJECT=y/" $LIN_CONFIG

# config.archiso
ISO_CONFIG=releng
# select: releng
cp -r /usr/share/archiso/configs/$ISO_CONFIG/ $WORKSPACE
# enable: biostools
biostools=(acpica linux-tools ipmitool)
for t in ${biostools[@]}
do
  echo $t >> $WORKSPACE/$ISO_CONFIG/packages.x86_64
done

if [[ $1 =~ bash ]]
then
  bash
else
  # building.kernel
  pushd . && {
    cd $WORKSPACE/linux
    updpkgsums && export MAKEFLAGS="-j$(nproc)" && makepkg -s --noconfirm --skippgpcheck
  } && popd
  # building.archiso
  pushd . && {
    cd $WORKSPACE/$ISO_CONFIG
    sudo bash ./build.sh -v
  } && popd
fi

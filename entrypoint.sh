#!/usr/bin/env bash
#
#  Copyright ©2022-2023 efikarl, https://efikarl.com.
#
#  This program is just made available under the terms and conditions of the
#  MIT license: https://efikarl.com/mit-license.html.
#
#  THE PROGRAM IS DISTRIBUTED UNDER THE MIT LICENSE ON AN "AS IS" BASIS,
#  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

THE_SCRIPT=${BASH_SOURCE:-$0}
#efikarl@globals+
export WORKSPACE=$(realpath $(dirname $THE_SCRIPT))
export ISOMK_CFG=releng #never change
export ISOMK_DST=${WORKSPACE}/work
#efikarl@globals
export KERNEL_SRC=linux-lts
export KERNEL_DST=linux-lts
export KERNEL_CFG=${WORKSPACE}/${KERNEL_SRC}/config
#efikarl@efirepo+
export EFIKA_REPO=/home/efika/.local/repo
export EFIKA_AURS=/home/efika/.local/aurs
#efikarl@efirepo-
export skip_build_archker=1
export skip_build_efirepo=1
export skip_build_archiso=0
#efikarl@globals-

build_archker()
{
  echo "[+] ${FUNCNAME[@]}"

  cd ${WORKSPACE}
  src="https://gitlab.archlinux.org/archlinux/packaging/packages/linux-lts.git"
  if [[ $skip_build_archker == 0 ]]
  then
    git clone $src
  fi
  local repo=$(basename $src .git)
  if [[ -d $repo ]]
  then
    cd $repo
  else
    echo "ERR: clone repo: $repo"
    return 1
  fi

  # prepare PKGBUILD for build:
  #   1. pkgbase=linux-lts
  #   2. make distclean && make nconfig && make prepare
  # config: kernel
  bash ${WORKSPACE}/tasks/01-prepare-linux.sh
  # makepkg kernel
  if [[ $skip_build_archker == 0 ]]
  then
    if !(updpkgsums && export MAKEFLAGS="-j$(nproc)" && makepkg -sf --noconfirm --skippgpcheck)
    then
      echo "ERR: build repo: $repo"
      return 1
    fi
  fi

  # clean repo and repo-add
  if ([[ ! -d ${EFIKA_REPO} ]] || rm -rf ${EFIKA_REPO}) && ([[ -d ${EFIKA_REPO} ]] || mkdir ${EFIKA_REPO})
  then
    repo-add -R $EFIKA_REPO/efika.db.tar.gz *.pkg.tar.zst && cp -f *.pkg.tar.zst $EFIKA_REPO
  fi

  return 0
  echo "[-] ${FUNCNAME[@]}"
}

build_efirepo()
{
  echo "[+] ${FUNCNAME[@]}"

  # build repo
  declare -A aurs
  aurs[0]="https://aur.archlinux.org/fwts-git.git"
  aurs[1]="https://aur.archlinux.org/chipsec-dkms-git.git"
  aurs[2]="https://aur.archlinux.org/chipsec-git.git"
  if [[ -d ${EFIKA_AURS} ]] || mkdir ${EFIKA_AURS}
  then
    for i in ${aurs[@]}
    do
      cd $EFIKA_AURS
      if [[ $skip_build_efirepo == 0 ]]
      then
        git clone $i
      fi
      local repo=$(basename $i .git)
      if [[ -d $repo ]]
      then
        cd $repo
      else
        echo "ERR: clone repo: $repo"
        return 1
      fi
      # building
      if [[ $skip_build_efirepo == 0 ]]
      then
        if ! makepkg -s --noconfirm
        then
          echo "ERR: build repo: $repo"
          return 1
        fi
      fi
      # repo-add
      if [[ -d ${EFIKA_REPO} ]] || mkdir ${EFIKA_REPO}
      then
        repo-add -R $EFIKA_REPO/efika.db.tar.gz *.pkg.tar.zst && cp -f *.pkg.tar.zst $EFIKA_REPO
      fi
    done
  fi

  return 0
  echo "[-] ${FUNCNAME[@]}"
}

build_archiso()
{
  echo "[+] ${FUNCNAME[@]}"

  cd ${WORKSPACE}
  # call mkarchiso with efika profile
  #   I: ISOMK_CFG
  #   O: work, where ISO is in
  if [ -d ${ISOMK_DST} ]
  then
    sudo rm -rf ${ISOMK_DST}
  fi
  # config: releng
  bash ${WORKSPACE}/tasks/02-prepare-mkiso.sh
  # create archiso
  if [[ $skip_build_archiso == 0 ]]
  then
    sudo mkarchiso -v ${WORKSPACE}/${ISOMK_CFG}
  fi

  return 0
  echo "[-] ${FUNCNAME[@]}"
}

#
# main:
#
if [[ $1 =~ bash ]]
then
  bash
else
  if !(build_archker)
  then
    exit 1
  fi
  if !(build_efirepo)
  then
    exit 1
  fi
  if !(build_archiso)
  then
    exit 1
  fi
fi

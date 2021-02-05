#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archlinux"
iso_label="ARCH_EFIKARL_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y)"
iso_publisher="efikarl"
iso_application="Arch Linux Live/Rescue CD"
iso_version="solstice"
install_dir="arch"
buildmodes=('iso')
#efikarl@bootmodes+
bootmodes=(
  'bios.syslinux.mbr'
  'bios.syslinux.eltorito'
  'uefi-x64.systemd-boot.esp'
  'uefi-x64.systemd-boot.eltorito'
)
#efikarl@bootmodes-
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
#efikarl@file_permissions+
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/acpidbg"]="0:0:755"
  ["/usr/local/bin/mce-inject"]="0:0:755"
  ["/usr/local/bin/aer-inject"]="0:0:755"
)
#efikarl@file_permissions-

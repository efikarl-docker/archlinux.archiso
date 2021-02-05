FROM efikarl/archlinux

ARG     THE_USER=efikarliso
ARG     THE_PSWD=efikarliso
ENV     WORKSPACE       /home/${THE_USER}

RUN pacman --noconfirm -Syu asp base-devel pacman-contrib archiso\
 && useradd -mUu 1000 ${THE_USER} && echo "root:root" | chpasswd && echo "$THE_USER:${THE_PSWD}" | chpasswd\
 && usermod -aG wheel ${THE_USER} && sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL$/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

COPY    entrypoint.sh   /
USER    ${THE_USER}:${THE_USER}

WORKDIR ${WORKSPACE}

ENTRYPOINT [ "/entrypoint.sh" ]
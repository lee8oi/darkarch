#!/bin/bash

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

mkdir -p /etc/skel/go/{src,pkg,bin}

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root

useradd -m -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /usr/bin/zsh arch
echo "arch:arch" | chpasswd

chmod 750 /etc/sudoers.d
chmod 0440 /etc/sudoers
chown -R root:root /etc/sudoers /etc/sudoers.d /etc/polkit-1

sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

systemctl enable pacman-init.service choose-mirror.service
systemctl set-default graphical.target
systemctl enable -f sddm

echo "adding Go paths"
echo "export GOROOT=/usr/lib/go" >> /etc/profile
echo "export GOPATH=\$HOME/go" >> /etc/profile
echo "export PATH=\$PATH:/usr/lib/go/bin:\$GOPATH/bin" >> /etc/profile

echo "Fixing liteide .env files"
for file in /usr/share/liteide/liteenv/*.env
do
sed -i 's/^GOROOT=.*/GOROOT=\/usr\/lib\/go/' $file
done

systemctl enable NetworkManager

workdir=`pwd`/build
mkdir $workdir
chown arch:users $workdir

echo "AUR - Downloading & Installing cower"
su - -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys 1EB2638FF56C0C53 && \
	cd ${workdir} && wget https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz\
	&& tar -xzf cower.tar.gz && cd cower && makepkg" arch
pacman -U $workdir/cower/*pkg.tar.xz --noconfirm

echo "AUR - Downloading & Installing Google Chrome"
su - -c "cd ${workdir} && wget https://aur.archlinux.org/cgit/aur.git/snapshot/google-chrome.tar.gz\
	&& tar -xzf google-chrome.tar.gz && cd google-chrome && makepkg" arch
pacman -U $workdir/google-chrome/*pkg.tar.xz --noconfirm

echo "Cleaning up the downloaded files"
rm -rf $workdir

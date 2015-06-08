#!/bin/bash

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

sed -i 's/^# %wheel ALL=(ALL) ALL.*/%wheel ALL=(ALL) ALL/' /etc/sudoers
mkdir -p /etc/skel/go/{src,pkg,bin}

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root

useradd -m -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /usr/bin/zsh arch
echo "arch:arch" | chpasswd

chmod 750 /etc/sudoers.d
#chmod 440 /etc/sudoers.d/g_wheel
chown -R root:root /etc/sudoers.d

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
#systemctl mask tmp.mount
systemctl enable NetworkManager

workdir=`pwd`/build
mkdir $workdir
chown arch:users $workdir

echo "AUR - Downloading & Installing libindicator"
su - -c "cd ${workdir} && wget https://aur.archlinux.org/packages/li/libindicator/libindicator.tar.gz\
	&& tar -xzf libindicator.tar.gz && cd libindicator && makepkg" arch
pacman -U $workdir/libindicator/*pkg.tar.xz --noconfirm

echo "AUR - Downloading & Installing libdbusmenu-gtk2"
su - -c "cd ${workdir} && wget https://aur.archlinux.org/packages/li/libdbusmenu-gtk2/libdbusmenu-gtk2.tar.gz\
	&& tar -xzf libdbusmenu-gtk2.tar.gz && cd libdbusmenu-gtk2 && makepkg" arch
pacman -U $workdir/libdbusmenu-gtk2/*pkg.tar.xz --noconfirm

echo "AUR - Downloading & Installing libappindicator"
su - -c "cd ${workdir} && wget https://aur.archlinux.org/packages/li/libappindicator/libappindicator.tar.gz\
	&& tar -xzf libappindicator.tar.gz && cd libappindicator && makepkg" arch
pacman -U $workdir/libappindicator/*pkg.tar.xz --noconfirm

echo "AUR - Downloading & Installing Octopi"
su - -c "cd ${workdir} && wget https://aur.archlinux.org/packages/oc/octopi/octopi.tar.gz\
	&& tar -xzf octopi.tar.gz && cd octopi && makepkg" arch
pacman -U $workdir/octopi/*pkg.tar.xz --noconfirm

echo "AUR - Downloading & Installing Google Chrome"
su - -c "cd ${workdir} && wget https://aur.archlinux.org/packages/go/google-chrome-beta/google-chrome-beta.tar.gz\
	&& tar -xzf google-chrome-beta.tar.gz && cd google-chrome-beta && makepkg" arch
pacman -U $workdir/google-chrome-beta/*pkg.tar.xz --noconfirm

echo "Cleaning up the downloaded files"
rm -rf $workdir

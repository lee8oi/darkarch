#!/usr/bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# patch.sh uses Archiso to build a customized Dark Arch live image.

#date=`date +"%Y%m%d-%H%M"`
date=`date +"%Y%m%d"`
file=archlinux-plasma-dark-$date
user=`stat -c "%U" .`
group=`stat -c "%G" .`
defaultpkgs="\
automoc4
binutils
cmake
fakeroot
gcc
make
patch
pkg-config
xorg-server
xorg-luit
xbitmaps
xterm
xf86-input-synaptics
xf86-video-vesa
xf86-video-intel
xf86-video-nouveau
xf86-video-ati
xf86-video-openchrome
harfbuzz-icu
filezilla
file-roller
gparted
git
gnome-doc-utils
gobject-introspection
guake
gtk-sharp-2
gwenview
intltool
konversation
konsole
kdevelop
kdebase-kdialog
kdebase-dolphin
kdesdk-dolphin-plugins
kate
kompare
kdegraphics-okular
kdegraphics-ksnapshot
kdemultimedia-kmix
kdenetwork-kopete
libdbusmenu-gtk3
mercurial
networkmanager
pavucontrol
perl-xml-libxml
plasma
pulseaudio
pulseaudio-alsa
oxygen-gtk2
sddm
sddm-kcm
subversion
snappy
sni-qt
speech-dispatcher
transmission-qt
ttf-dejavu
ttf-liberation
unzip
vala
vim
virtualbox-guest-utils
vlc
yaourt
zip
zsh-completions
zsh-syntax-highlighting\
"

check () {
	if [ $1 -eq 0 ]; then
		printf " - done!\n"
	else
		printf " - failed! See $file.log\n"
	fi
}

unmountall () {
	for i in `mount | grep \`pwd\`/releng | awk '{print $3}'`; do
		if mount | grep $i > /dev/null; then
			echo "Unmounting $i" >> $file.log
			umount -R $i >> $file.log 2>&1
		fi
	done
	if mount | grep `pwd`/releng > /dev/null; then
		printf "\nFailed to unmount existing airootfs!\n"
		exit
	fi
	return 0
}

cleanup () {
	if ls releng &> /dev/null; then
		rm -rf releng
	fi
	if ls archlinux* &> /dev/null; then
		for i in `ls archlinux*`; do rm -rf $i; done
	fi
	if ls *.log &> /dev/null; then
		for i in `ls *.log`; do rm -rf $i; done
	fi
	return $?
}

addpkgs () {
	if [ -e $1 ] && [ -s $1 ]; then
		for i in `cat $1`; do
			grep $i $2 &> /dev/null
			if [ $? -ne 0 ]; then
				echo $i >> $2
			fi
		done
	fi
	return $?
}

packages () {
	for i in $defaultpkgs; do
		echo $i >> releng/packages.both
	done
	addpkgs packages.both releng/packages.both &&
	addpkgs packages.i686 releng/packages.i686 &&
	addpkgs packages.x86_64 releng/packages.x86_64
	return $?
}

checkargs () {
	for i in $*; do
	        pacman -Si $i > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			grep $i releng/packages.both &> /dev/null
			if [ $? -ne 0 ]; then
				echo $i >> releng/packages.both
				printf "Added $i to packages.both\n"
			fi
		fi
	done
	return 0
}

# addwallpaper () {
# 	mkdir -p releng/airootfs/usr/share/
# 	cp -r wallpapers releng/airootfs/usr/share/
# 	return $?
# }

createskel () {
	mkdir -p releng/airootfs/etc/
	cp -r skel releng/airootfs/etc/
}

setupvbox () {
	mkdir releng/airootfs/etc/modules-load.d/ &&
	touch releng/airootfs/etc/modules-load.d/virtualbox.conf &&
	echo "vboxguest" >> releng/airootfs/etc/modules-load.d/virtualbox.conf &&
	echo "vboxsf" >> releng/airootfs/etc/modules-load.d/virtualbox.conf &&
	echo "vboxvideo" >> releng/airootfs/etc/modules-load.d/virtualbox.conf
	return $?
}

customrepo () {
	rm customrepo/i686/customrepo.db*
	rm customrepo/x86_64/customrepo.db*
	rpath="`pwd`/customrepo"
	repo-add $rpath/i686/customrepo.db.tar.gz $rpath/i686/*.pkg.tar.xz &&
	repo-add $rpath/x86_64/customrepo.db.tar.gz $rpath/x86_64/*.pkg.tar.xz &&
	echo "[archlinuxfr]" >> releng/pacman.conf &&
	echo "SigLevel = Never" >> releng/pacman.conf &&
	echo "Server = http://repo.archlinux.fr/\$arch" >> releng/pacman.conf &&
	echo "" >> releng/pacman.conf &&
	echo "[customrepo]" >> releng/pacman.conf &&
	echo "SigLevel = Optional TrustAll" >> releng/pacman.conf &&
	echo "Server = file://$rpath/\$arch" >> releng/pacman.conf
	return $?
}

buildrelease () {
	workpath=`pwd`
	cd $workpath/releng;./build.sh -v &&
	chown $user:$group out/archlinux*.iso &&
	mv out/archlinux*.iso $workpath/$file-dual.iso &&
	cd $workpath && rm -rf ./releng >> $file.log 2>&1
	if [ -e $workpath/$file-dual.iso ]; then
		return 0
	fi
	return 1
}

echo
if [ $USER != "root" ]; then
	printf "You must run this script at root"
	exit 1
fi

unmountall

printf "Cleaning up old build files"
cleanup >> $file.log 2>&1
check $?

printf "Grabbing fresh copy of releng"
cp -r /usr/share/archiso/configs/releng/ . >> $file.log 2>&1
check $?

printf "Populating the package lists"
packages >> $file.log 2>&1
check $?

printf "Checking shell arguments for additional packages"
checkargs $* >> $file.log 2>&1
check $?

printf "Adding customization scripts"
addscripts >> $file.log 2>&1
rm releng/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf &&
cp customize_airootfs.sh releng/airootfs/root/
check $?

# printf "Adding wallpapers"
# addwallpaper >> $file.log 2>&1
# check $?

printf "Adding skel/ files"
createskel >> $file.log 2>&1
check $?

printf "Adding etc/ files"
cp -r etc releng/airootfs/ >> $file.log 2>&1
check $?

printf "Adding usr/ files"
cp -r usr releng/airootfs/ >> $file.log 2>&1
check $?

printf "Configuring Virtualbox Guest modules"
setupvbox >> $file.log 2>&1
check $?

printf "Adding custom local repository"
customrepo >> $file.log 2>&1
check $?

printf "Creating source archive [./$file.tar.gz]"
tar -czf $file.tar.gz customrepo customize_airootfs.sh sddm.conf pa* skel etc usr releng >> $file.log 2>&1
chown $user:$group $file.tar.gz
check $?

echo
printf "Ready to build the Dark Arch ISO image\n"
printf "Note: This will take a while\n\n"
read -p "Press [Enter] to continue"

printf "\nBuilding ISO image (./$file-dual.iso)"
buildrelease >> $file.log 2>&1
check $?

Dark Arch
========

A custom Arch LiveCD featuring the Plasma 5 desktop, a slick looking dark theme, and a pre-configured Go environment with LiteIDE. Source contains the scripts and files needed to build the Dark Arch ISO image in Arch Linux with all the latest packages (requires Arch & Archiso).

WARNING: The Dark Arch live environment is designed for Arch installations, system administration, and system rescue. It does not ask for a password to perform root tasks and is intended for experienced Linux users.

#### Features
* Full Arch-based system. Not a fork or spinoff, just a custom LiveCD with all the raw power of Arch Linux.
* Dual architecture ISO for running 32-bit OR 64-bit systems.
* SDDM with a Plasma 5 environment for a customizable & modern desktop experience.
* Slick looking dark Arch theming including a wallpaper from Desktop Nexus (http://technology.desktopnexus.com/wallpaper/1128145/)
* Go and LightIDE pre-configured & ready to use so you can build & integrate your Go based programs into your Arch installation.
* Desktop applications include Google Chrome, Transmission, Filezilla, Hexchat, Kopete, Gparted, and VLC.
* Guake drop-down style terminal for quick and easy access to command line from the desktop.
* Discover - A graphical pacman frontend for easy package management and system updates.
* Cower helper tool pre-installed for easy commandline access to Arch User Repository.
* Pulseaudio based sound system with Pavucontrol.
* NetworkManager & wireless tools installed for easy internet connection management from the desktop.
* Pre-configured for use as a Virtualbox guest.
* Google Chrome is pre-configured to load the Arch Beginners Guide for quick reference during Arch installations.

#### Usage
Requires sudo access. You also need to be on an Arch based system and have Archiso installed.

Start the build by running patch.sh

```
sudo ./patch.sh
```

Add additional packages on-the-fly by passing them to patch.sh as arguments:

```
sudo ./patch.sh pkgname1 pkgname2 pkgname3 ...
```

Packages saved in packages.both, packages.i686, or packages.x86_64 are added to build automatically.

To add additional wallpapers to the build simply add them to the 'usr/share/wallpapers' folder. For files intended for /etc/skel, you can add them to the 'skel' folder and they will be automatically added to the build. Run patch.sh after any changes.

Note: The resulting ISO and source archive file names include a version number based the current date for easier build tracking.

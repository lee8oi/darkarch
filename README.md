Dark Arch
========

A custom Arch LiveCD with a Plasma 5 desktop, a slick looking dark Arch theme, and a preconfigured Go environment with LiteIDE. Source contains the scripts and files needed to build the latest Dark Arch ISO in Arch Linux with all the latest packages from Arch.

#### Features
* Full Arch based system. Not a fork or spinoff, just a custom LiveCD with all the raw power of Arch.
* Dual architecture ISO for running 32-bit OR 64-bit systems.
* SDDM with a Plasma 5 environment for a customizable & modern desktop experience.
* Slick looking dark Arch theming including a wallpaper from Desktop Nexus (http://technology.desktopnexus.com/wallpaper/1128145/)
* Go and LightIDE preconfigured & ready to use so you can build & integrate your Go based programs into your Arch installation.
* All build scripts & files used to build Dark Arch are freely provided so you can easily build your own up-to-date ISO with all the latest packages (requires Arch & Archiso).
* Custom yet minimal list of desktop applications including Google Chrome, Gimp Transmission, Filezilla, Konversation, Kopete, and VLC.
* Guake drop-down style terminal for quick and easy access to command line from the desktop.
* Octopi - A graphical pacman frontend for easy package management.
* Yaourt repository tool pre-installed for easy access to Arch User Repository.
* Pulseaudio based sound system with Pavucontrol & kmix.
* NetworkManager works with Plasma 5's own network manager applet.
* Preconfigured for use as a Virtualbox guest.


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

To add additional wallpapers to the build simply add them to the 'wallpapers' folder. Same for files intended for /etc/skel, you can add them to the 'skel' folder and they will be automatically added to the build. Run patch.sh after any changes.

Note: The resulting ISO and source archive file names should include a version number based the current date for easier build tracking.


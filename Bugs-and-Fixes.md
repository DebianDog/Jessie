**List of DebianDog-Jessie fixes found after 04.09.2015:**

**1.** Installing and running **rythmbox** (and maybe similar packages) could fail with message like:
```
 GLib-GIO-ERROR : Settings schema 'org.gtk.Settings.FileChooser
```
The problem is in some schemas from Wheezy included in gnome-mplayer-1.0.7 package. More information read [here.](http://murga-linux.com/puppy/viewtopic.php?p=863936#863936) To fix this download [gnome-mplayer-fix.zip](http://murga-linux.com/puppy/viewtopic.php?mode=attach&id=90533) and extract the archive in /opt/bin (or /usr/bin). Typing this is enough to fix the problem in your running system:
```
sudo gnome-mplayer-fix
```
Or you can upgrade fixed gnome-mplayer-1.0.7 deb with:
    sudo apt-get update
    sudo apt-get install gnome-mplayer-1.0.7

**2.** Fixes for frugal installer from Fred described [here.](http://murga-linux.com/puppy/viewtopic.php?p=867572#867572) Upgrade the installer package with:
```
sudo apt-get update
sudo apt-get install debdoginstallscripts
```

**3.** Jwm version has xdm login manager included but it doesn't work well in OpenBox.
In OpenBox version you can install this [slim](http://kazzascorner.com.au/saintless/DebianDog/DebianDog-Jessie/Packages/Extra/slim_1.3.6-4-ddjessie_i386.deb) package.
You can stop/start it from System -> Start/Stop Slim display-manager. More information read [here.](http://murga-linux.com/puppy/viewtopic.php?p=869164#869164) Available also in debiandog-repository:
```
sudo apt-get update
sudo apt-get install slim
```

**4.** The included /sbin/cryptsetup doesn't create working encrypted save file. Install this fixed  [cryptsetup-bin_1.6.6-9-debdog_i386.deb](http://kazzascorner.com.au/saintless/DebianDog/DebianDog-Jessie/Packages/Mod/cryptsetup-bin_1.6.6-9-debdog_i386.deb) or run in terminal:
```
sudo apt-get update
sudo apt-get install cryptsetup-bin
```

**5.** Some fixes from Fred for fixdepinstall (install deb and dependencies right click option).
[More information read here.](http://murga-linux.com/puppy/viewtopic.php?p=871384#871384)
Install fixed version from the link above or from terminal:
```
sudo apt-get update
sudo apt-get install fixdepinstall
```

**6.** In OpenBox version when trying to install the full xfce4 desktop:
```
apt-get install xfce4	
```

There is an error:
```
xfce4 : Depends: libxfce4ui-utils (>= 4.10) but it is not going to be installed	
```
To fix it downgrade libxfce4ui-1-0 to official jessie version:
```
apt-get install libxfce4ui-1-0=4.10.0-6	
```

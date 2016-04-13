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

**2.** The installer scripts bugs fixing created new problem and the last two versions removed from the repository. 
Recommended to make sure you have this version on your system by reinstalling this package: [debdoginstallscripts_1.0.5_i386.deb](http://kazzascorner.com.au/saintless/DebianDog/DebianDog-Jessie/Packages/Included/debdoginstallscripts_1.0.5_i386.deb)

Or by running in terminal:
```
sudo apt-get update
sudo apt-get remove debdoginstallscripts
sudo apt-get install debdoginstallscripts
```
In case you have some problem with this package check out for updated deb package from Fred [here.](http://murga-linux.com/puppy/viewtopic.php?p=877300&sid=7a08609033f6af763ab2acf4c3941c8c#877300)

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
**7.** For **porteus-boot only** we have a report about a problem with clean shutdown described [here](http://murga-linux.com/puppy/viewtopic.php?p=876371#876371). In case you experience the same problem extract this [archive](http://murga-linux.com/puppy/viewtopic.php?mode=attach&id=92743) with fix from **Jrb** inside /live/image/live/rootcopy

The fix will be loaded only with porteus-boot without replacing the original /etc/init.d files for live-boot.

**8.** Fix for squashfs module loading scripts from Fred. [More information read here.](http://murga-linux.com/puppy/viewtopic.php?p=878996#878996)
```
sudo apt-get update
sudo apt-get install sfsload portablesfs-loadsfs-fuse
```

**9.** Small fix for frisbee. [More information read here.](http://murga-linux.com/puppy/viewtopic.php?p=883158&sid=3588429564754e676ce49df134d930a8#883158)
```
sudo apt-get update
sudo apt-get install frisbee
```

**10.** Small fix for apt2sfs. [More information read here.](http://murga-linux.com/puppy/viewtopic.php?p=885536&sid=e09b92e591e85bcc4632168abdb32e5b#885536)
```
sudo apt-get update
sudo apt-get install apt2sfs
```

**11.** Fix for porteus-boot initrd1.xz in case you are using **encrypted save file and usb keyboard**. More information about this problem read [here.](http://murga-linux.com/puppy/viewtopic.php?p=885874&sid=a1a579b99b8a00be9a2b36bc9a227635#885874)

For **NOPAE** DD-Jessie iso versions (DebianDog-Jessie-jwm_icewm-2015-09-02.iso or DebianDog-Jessie-openbox_xfce-2015-09-02.iso) use this [initrd1.xz-hid-dd-nopae](https://github.com/DebianDog/Jessie/releases/download/v.0.1/initrd1.xz-hid-dd-nopae) instead initrd1.xz included in the iso.

For **PAE** DD-Jessie iso versions (DebianDog-Jessie-openbox_xfce-2015-09-02-PAE.iso or DebianDog-Jessie-jwm_icewm-2015-09-02-PAE.iso) use this [initrd1.xz-hid-dd-pae](https://github.com/DebianDog/Jessie/releases/download/v.0.1/initrd1.xz-hid-dd-pae) instead initrd1.xz included in the iso.

initrd1.xz will be replaced with the fixed versions in next iso updates.

In case you don't use **encrypted save file + usb keyboard** combination there is no need to change initrd1.xz yet.

**12.** With porteus-boot and only when using save on exit code upgrading libc6 could create some issues. More information and workarownd read [here](http://murga-linux.com/puppy/viewtopic.php?p=889934&sid=00f59036fe7b1df6f8bc7168fe1df597#889934) and the fix [here.](http://murga-linux.com/puppy/viewtopic.php?p=890342&sid=00f59036fe7b1df6f8bc7168fe1df597#890342)
Install this package to fix the problem:
```
sudo apt-get update
sudo apt-get install porteusbootscripts

```
Porteus-boot scripts will be upgraded to new versions with some improvements for save on exit. The changes are not well tested in DebianDog-Jessie yet. In case you experience some problem you can downgrade the package to the previous version (it has only the fix in snapmergepuppy script for the problem described above and will restore the other scripts to the versions included in the iso):
```
sudo apt-get install porteusbootscripts=0.0.1

```

**13.** New packages **sfs-get-smokey-get** and **debdog-repo-updater** uploaded.

We need to change some scripts and free some space by removing modules from kazzascorner.com.au and smokey01.com in order to make the maintaining easier. Sfs-get script will download the extra modules from github.com in the future for all DD versions and MintPup.

**It is recommended to install both packages by running these commands to keep sfs-get and dd-repo up to date:**
```
sudo apt-get update
sudo apt-get install debdog-repo-updater sfs-get-smokey-get
sudo apt-get update
```

**14.** **Only for DebianDog-Jwm version** fix for XDM login manager. In case XDM is activated using porteus-boot save on Exit and typing reboot command in terminal (instead using the Reboot-Shutdown menu) does not give option **not to save** changes. [More information read here.](https://github.com/DebianDog/Jessie/issues/2)
To fix this just reisntall XDM (make sure to install debdog-repo-updater first and run apt-get update again - the previous fix):
```
sudo apt-get update
sudo apt-get install --reinstall xdm

```
Or download and install the package [xdm_1.1.11-2_i386.deb](http://smokey01.com/saintless/DebianDog-Jessie/Packages/Included/xdm_1.1.11-2_i386.deb)


**15.** **Only for DebianDog-openbox_xfce version** fix for Thunar file-manager. When right-clicking on a file or folder > Properties, > Permissions, the options are disabled/greyed out. Fixed by recompiling Thunar (with patch to "not-show-root-warning") , see [Here](http://murga-linux.com/puppy/viewtopic.php?p=898519#898519) for more info.
Install first debdog-repo-updater, then:
```
sudo apt-get update
sudo apt-get install thunar

```
Or download and install the package [thunar_1.6.3-2_i386.deb](http://www.smokey01.com/saintless/DebianDog-Jessie/Packages/Extra/thunar_1.6.3-2_i386.deb)

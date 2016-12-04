**List of DebianDog-Jessie changes or fixes found after 16.10.2016:**

**1.** Package quick-remaster updated.
Added quick-remastergui (GUI version) and some improvements, e.g. choice to backup save storage.
See also [Here](http://murga-linux.com/puppy/viewtopic.php?p=929398#929398)   
Bug fix: gz compression option not working in quick-remastergui from version 1.0.3, fixed in new version 1.0.4   

**2.** Added package upgrade-kernel
Upgrade to latest kernel and update intrd + vmlinuz1 files at the same time (frugal install only)
See also [Here](http://murga-linux.com/puppy/viewtopic.php?p=930244#930244) and [Here](http://murga-linux.com/puppy/viewtopic.php?p=929740#929740)

**3.** Included gnome-player doesn't play Audio CD's
It's because of mplayer not compiled with cdda support, fixed now by recompiling (with CD and DVD support), to upgrade gnome-mplayer-1.0.7 :

```
apt-get update
apt-get install gnome-mplayer-1.0.7 # will upgrade to newer version 1:1.0.6.2

```
**4.** Fixed ffmpeg package conflicting with (official Debian) libav-tools package, install:    
```
apt-get update
apt-get install ffmpeg # will upgrade to newer version
```
 
**5.** Small fix for youtube-get2 (should not show warning anymore about avconv version in download list), install:      
```
apt-get update
apt-get install youtube-get2 # will upgrade to newer version
```

**6.** Small fix for grub4dosconfig, use busybox dc in /usr/sbin/grub4dosconfig, install:    
```
apt-get update
apt-get install grub4dosconfig # will upgrade to newer version
```    

**7.** Packages remasterscripts, apt2sfs and quick-remaster are updated to a newer version.
Install with synaptic or apt-get (first 'apt-get update' to update the package lists)
Fix is that the scripts will skip symlinks while cleaning files in /usr/share/man and /usr/share/doc






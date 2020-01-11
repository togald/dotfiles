#!/bin/sh

userresources=$HOME/.Xresources
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# To make libreOffice behave
export SAL_USE_VCLPLUGIN=gtk3 lowriter

# xmodmap
/usr/bin/xmodmap $HOME/.xmodmap

# Mouse cursor set
xsetroot -cursor_name left_ptr

# Start my private DE's programs
stalonetray &
nm-applet &
nitrogen --restore &
mount $HOME/ramdisk &

# Finally, start xmonad
systemd --user &
xmonad

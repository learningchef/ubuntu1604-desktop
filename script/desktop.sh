#!/bin/bash

if [[ ! "$DESKTOP" =~ ^(true|yes|on|1|TRUE|YES|ON])$ ]]; then
  exit
fi

echo "==> Installing ubunutu-desktop"
apt-get install -y ubuntu-desktop

SSH_USER=${SSH_USERNAME:-vagrant}
LIGHTDM_CONFIG=/etc/lightdm/lightdm.conf
GDM_CUSTOM_CONFIG=/etc/gdm/custom.conf

mkdir -p $(dirname ${GDM_CUSTOM_CONFIG})
echo "[daemon]" >> $GDM_CUSTOM_CONFIG
echo "# Enabling automatic login" >> $GDM_CUSTOM_CONFIG
echo "AutomaticLoginEnable=True" >> $GDM_CUSTOM_CONFIG
echo "AutomaticLoginEnable=${USERNAME}" >> $GDM_CUSTOM_CONFIG

echo "==> Configuring lightdm autologin"
echo "[SeatDefaults]" >> $LIGHTDM_CONFIG
echo "autologin-user=${SSH_USERNAME}" >> $LIGHTDM_CONFIG
echo "autologin-user-timeout=0" >> $LIGHTDM_CONFIG
echo "display-setup-script=/etc/lightdm/dpms-enable" >> $LIGHTDM_CONFIG
echo "session-setup-script=/etc/lightdm/dpms-disable" >> $LIGHTDM_CONFIG

cat << EOF > /etc/lightdm/dpms-enable
#!/bin/sh

(
  # This delay is required. Might be because the X server isn't
  # started yet.
  sleep 10

  # Set up a 5 minute timeout before powering off the display.
  xset dpms 0 0 300 
) &
EOF
chmod +x /etc/lightdm/dpms-enable

cat << EOF > /etc/lightdm/dpms-disable
#!/bin/ash

(
    # This delay is required. Might be because the X server isn't
    # started yet.
    sleep 10

    # Turn off X's handling of dpms timeout. Otherwise
    # gnome-settings-daemon and gnome-screensaver will fight over it.
    xset -dpms s off s noblank s 0 0 s noexpose

    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gsettings set org.gnome.desktop.screensaver lock-delay 0
) &
EOF
chmod +x /etc/lightdm/dpms-disable

# echo "==> Disabling screen blanking"
# NODPMS_CONFIG=/etc/xdg/autostart/nodpms.desktop
# echo "[Desktop Entry]" >> $NODPMS_CONFIG
# echo "Type=Application" >> $NODPMS_CONFIG
# echo "Exec=xset -dpms s off s noblank s 0 0 s noexpose" >> $NODPMS_CONFIG
# echo "Hidden=false" >> $NODPMS_CONFIG
# echo "NoDisplay=false" >> $NODPMS_CONFIG
# echo "X-GNOME-Autostart-enabled=true" >> $NODPMS_CONFIG
# echo "Name[en_US]=nodpms" >> $NODPMS_CONFIG
# echo "Name=nodpms" >> $NODPMS_CONFIG
# echo "Comment[en_US]=" >> $NODPMS_CONFIG
# echo "Comment=" >> $NODPMS_CONFIG

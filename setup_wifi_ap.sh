#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Installing AP software"
apt-get install hostapd dnsmasq -y
echo "Stopping hostapd"
systemctl stop hostapd
echo "Stopping dnsmasq"
systemctl stop dnsmasq

echo "Setting up /etc/dhcpcd.conf"
cat <<EOT >> /etc/dhcpcd.conf
interface wlan0
static ip_address=10.0.1.1/24
EOT

echo "Copying over /etc/dnsmasq.conf /etc/dnsmasq.conf.orig"
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

echo "Setting up /etc/dnsmasq.conf"
cat > /etc/dnsmasq.conf <<EOF
interface=wlan0
  dhcp-range=10.0.1.2,10.0.1.15,255.255.255.0,24h
EOF

echo "Setting up /etc/hostapd/hostapd.conf"
cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ssid=PJSDV_TEMP
wpa_passphrase=allhailthemightypi
EOF

echo "Setting up /etc/default/hostapd"
cat <<EOT >> /etc/default/hostapd
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOT

echo "Removing client connection"
cat > /etc/wpa_supplicant/wpa_supplicant.conf <<EOF
country=NL
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
EOF

echo "Unmasking hostapd"
systemctl unmask hostapd
echo "Enabling hostapd"
systemctl enable hostapd
sleep 5
echo "Restarting hostapd"
systemctl restart hostapd.service

echo "Done!"
echo "Reboot the Raspberry Pi for the changes to take effect."

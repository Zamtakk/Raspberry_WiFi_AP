#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt-get install hostapd dnsmasq -y
systemctl stop hostapd
systemctl stop dnsmasq

cat <<EOT >> /etc/dhcpcd.conf
interface wlan0
static ip_address=10.0.1.1/24
EOT

mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

cat > /etc/dnsmasq.conf <<EOF
interface=wlan0
  dhcp-range=10.0.1.2,10.0.1.15,255.255.255.0,24h
EOF

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

cat <<EOT >> /etc/default/hostapd
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOT

systemctl unmask hostapd
systemctl enable hostapd
systemctl restart hostapd.service

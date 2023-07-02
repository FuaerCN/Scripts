#!/bin/bash

apt-get install wget curl -y

sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
sysctl -p

PUB_KEY=$(curl -fsSL https://github.com/FuaerCN.keys)
mkdir -p ${HOME}/.ssh/
touch ${HOME}/.ssh/authorized_keys
echo -e "${PUB_KEY}\n" > ${HOME}/.ssh/authorized_keys
chmod 700 ${HOME}/.ssh/
chmod 600 ${HOME}/.ssh/authorized_keys
sed -i "s@.*\(PasswordAuthentication \).*@\1no@" /etc/ssh/sshd_config
systemctl restart sshd

wget -qN --no-check-certificate https://github.com/SagerNet/sing-box/releases/download/v1.1.7/sing-box_1.1.7_linux_amd64.deb
dpkg -i sing-box_1.1.7_linux_amd64.deb
rm -f sing-box_1.1.7_linux_amd64.deb
cat <<EOF > /etc/sing-box/config.json
{
  "inbounds": [
    {
      "type": "socks",
      "listen_port": 2408
    }
  ]
}
EOF
systemctl enable sing-box
systemctl start sing-box

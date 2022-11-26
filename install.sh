#!/bin/bash

sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
sysctl -p >/dev/null 2>&1

PUB_KEY=$(curl -fsSL https://github.com/FuaerCN.keys)
mkdir -p ${HOME}/.ssh/
touch ${HOME}/.ssh/authorized_keys
echo -e "${PUB_KEY}\n" > ${HOME}/.ssh/authorized_keys
chmod 700 ${HOME}/.ssh/
chmod 600 ${HOME}/.ssh/authorized_keys
sed -i "s@.*\(PasswordAuthentication \).*@\1no@" /etc/ssh/sshd_config
systemctl restart sshd

version_tag=$(curl -Ls "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
download_tag=$(echo $version_tag | sed "s/v//g")
wget -N --no-check-certificate https://github.com/SagerNet/sing-box/releases/download/$version_tag/sing-box_"$download_tag"_linux_amd64.deb
dpkg -i sing-box_"$download_tag"_linux_amd64.deb
rm -f sing-box_"$download_tag"_linux_amd64.deb
cat <<EOF > /etc/sing-box/config.json
{
  "inbounds": [
    {
      "type": "socks",
      "listen_port": 2408,
      "users": [
        {
          "username": "admin",
          "password": "yeasty"
        }
      ]
    }
  ]
}
EOF
systemctl start sing-box
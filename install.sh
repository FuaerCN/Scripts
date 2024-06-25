#!/bin/bash

apt-get install curl -y

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

last_version=$(curl -s "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep -Po '"name": "\K.*?(?=")' | head -n 1)
curl -sLo sing-box.deb https://github.com/SagerNet/sing-box/releases/latest/download/sing-box_"$last_version"_linux_amd64.deb
dpkg -i sing-box.deb
rm -f sing-box.deb
cat <<EOF > /etc/sing-box/config.json
{
    "inbounds": [
        {
            "type": "socks",
            "tag": "socks-in",
            
            "listen": "::",
            "listen_port": 2408
        }
    ]
}
EOF
systemctl enable sing-box
systemctl restart sing-box

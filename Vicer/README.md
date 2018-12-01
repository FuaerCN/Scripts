# 一个逗比写的逗比脚本

## 背景:
- 适用于由GRUB引导的CentOS,Ubuntu,Debian系统.
- 使用官方发行版去掉模板预装的软件.
- 同时也可以解决内核版本与软件不兼容的问题。
- 只要有root权限,还您一个纯净的系统。

## 注意:
- 全自动安装默认root密码:Vicer,安装完成后请立即更改密码.
- 能够全自动重装Debian/Ubuntu/CentOS等系统.
- 同时提供dd安装镜像功能,例如: 全自动无救援dd安装windows系统
- 全自动安装CentOS时默认提供VNC功能,可使用VNC Viewer查看进度,
- VNC端口为1或者5901,可自行尝试连接.(成功后VNC功能会消失.)
- 目前CentOS系统只支持任意版本重装为 CentOS 6.x 及以下版本.
- 特别注意:OpenVZ构架不适用.

## 确保安装了所需软件:
## Debian/Ubuntu:
- apt-get install -y xz-utils openssl gawk file
## RedHat/CentOS:
- yum install -y xz openssl gawk file

## 快速使用示例:
``` bash
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/FuaerCN/Shell/master/Vicer/InstallNET.sh') -d 8 -v 64 -a
```

## 下载及说明:
``` bash
wget --no-check-certificate -qO InstallNET.sh 'https://raw.githubusercontent.com/FuaerCN/Shell/master/Vicer/InstallNET.sh' && chmod a+x InstallNET.sh
```



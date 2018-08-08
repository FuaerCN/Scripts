#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
apt-get install -y ca-certificates
Crontab_file="/usr/bin/crontab"
caddyfile="/usr/local/caddy/"
caddy_file="/usr/local/caddy/caddy"
caddy_conf_file="/usr/local/caddy/Caddyfile"
aria2ng_new_ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/mayswind/AriaNg/releases/latest | grep -o '"tag_name": ".*"' | sed 's/"//g' | sed 's/tag_name: //g') && echo ${Ver}
aria2ng_download_http="https://github.com/mayswind/AriaNg/releases/download/${aria2ng_new_ver}/aria-ng-${aria2ng_new_ver}.zip"
aria2_new_ver=$(wget --no-check-certificate -qO- "https://github.com/q3aql/aria2-static-builds/tags"| grep "/q3aql/aria2-static-builds/releases/tag/"| head -n 1| awk -F "/tag/v" '{print $2}'| sed 's/\">//') && echo -e "${aria2_new_ver}"

Install_php(){
	#Debian 8系统
	#添加源
	echo "deb http://packages.dotdeb.org jessie all" | tee --append /etc/apt/sources.list
	echo "deb-src http://packages.dotdeb.org jessie all" | tee --append /etc/apt/sources.list
	#添加key
	wget --no-check-certificate https://www.dotdeb.org/dotdeb.gpg
	apt-key add dotdeb.gpg
	#更新系统
	apt-get update -y
	#安装PHP 7和Sqlite 3
	apt-get install php7.0-cgi php7.0-fpm php7.0-curl php7.0-gd php7.0-mbstring php7.0-xml php7.0-sqlite3 sqlite3 -y
}

Install_caddy(){
	bit=`uname -m`
	if [[ -e ${caddy_file} ]]; then
		echo && echo  "[信息] 检测到 Caddy 已安装，是否继续安装(覆盖更新)？[y/N]"
		stty erase '^H' && read -p "(默认: n):" yn
		[[ -z ${yn} ]] && yn="n"
		if [[ ${yn} == [Nn] ]]; then
			echo && echo "已取消..." && exit 1
		fi
	fi
	[[ ! -e ${caddyfile} ]] && mkdir "${caddyfile}"
	cd "${caddyfile}"
	PID=$(ps -ef |grep "caddy" |grep -v "grep" |grep -v "init.d" |grep -v "service" |grep -v "caddy_install" |awk '{print $2}')
	[[ ! -z ${PID} ]] && kill -9 ${PID}
	[[ -e "caddy_linux*.tar.gz" ]] && rm -rf "caddy_linux*.tar.gz"
	
	if [[ ${bit} == "i386" ]]; then
		wget --no-check-certificate -O "caddy_linux.tar.gz" "https://caddyserver.com/download/linux/386?license=personal" && caddy_bit="caddy_linux_386"
	elif [[ ${bit} == "i686" ]]; then
		wget --no-check-certificate -O "caddy_linux.tar.gz" "https://caddyserver.com/download/linux/386?license=personal" && caddy_bit="caddy_linux_386"
	elif [[ ${bit} == "x86_64" ]]; then
		wget --no-check-certificate -O "caddy_linux.tar.gz" "https://caddyserver.com/download/linux/amd64?license=personal" && caddy_bit="caddy_linux_amd64"
	else
		echo -e "[错误] 不支持 ${bit} !" && exit 1
	fi
	[[ ! -e "caddy_linux.tar.gz" ]] && echo  "[错误] Caddy 下载失败 !" && exit 1
	tar zxf "caddy_linux.tar.gz"
	rm -rf "caddy_linux.tar.gz"
	[[ ! -e ${caddy_file} ]] && echo  "[错误] Caddy 解压失败或压缩文件错误 !" && exit 1
	rm -rf LICENSES.txt
	rm -rf README.txt 
	rm -rf CHANGES.txt
	rm -rf "init/"
	chmod +x caddy
	wget --no-check-certificate https://raw.githubusercontent.com/FuaerCN/sh/master/Caddyfile
	
}

Install_aria2(){
	cd /root/.aria2
    wget --no-check-certificate -N https://raw.githubusercontent.com/FuaerCN/sh/master/aria2/aria2.conf
    wget --no-check-certificate https://raw.githubusercontent.com/FuaerCN/sh/master/aria2/UpGDrive.sh && chmod +x UpGDrive.sh
    wget --no-check-certificate https://raw.githubusercontent.com/FuaerCN/sh/master/aria2/UpOneDrive.sh && chmod +x UpOneDrive.sh.sh
	cp -f /root/.aria2/UpGDrive.sh /root/.aria2/UpDrive.sh
	
}

Install_aria2ng(){
    mkdir -p /home/AriaNg && cd /home/AriaNg
	wget --no-check-certificate ${aria2ng_download_http} && unzip aria-ng-${aria2ng_new_ver}.zip
}

Install_oneindex(){
    cd /home/ && wget --no-check-certificate -O oneindex.zip https://codeload.github.com/donwa/oneindex/zip/master && unzip oneindex.zip
	rm -rf /home/oneindex
	mv /home/oneindex-master /home/oneindex
	chown www-data:www-data -R /home/oneindex/*
	rm -rf /home/oneindex.zip
	echo "0 * * * * php /home/oneindex/one.php token:refresh
*/10 * * * * php /home/oneindex/one.php cache:refresh" >> /var/spool/cron/crontabs/root
}

Install_skicka(){
	cd /usr/bin/
	wget --no-check-certificate https://raw.githubusercontent.com/FuaerCN/sh/master/skicka/skicka && chmod -R 755 /usr/bin/skicka
	skicka init
	skicka -no-browser-auth ls
}

main(){
	Install_php
	caddy_install
	Install_aria2
	Install_aria2ng
	Install_oneindex
	Install_skicka
}

main
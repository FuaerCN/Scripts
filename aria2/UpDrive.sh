#!/bin/bash
path=$3
downloadpath='/home/AriaNg/Download'
if [ $2 -eq 0 ]
        then
                exit 0
fi
while true; do  #提取下载文件根路径，如把/root/downloads/a/b/c/d.jpg变成/root/downloads/a

#删掉些BT中没用的辣鸡文件
find "$path" -regextype posix-extended -regex ".*\.(chm|torrent|htm|html|url|nfo|ico|mht|gif)" -exec rm -f {} \;

filepath=$path
filename=${filepath%.*}
extension=${filepath##*.}
if [[ $extension = "zip" ]] ; then 
	echo "解压 ZIP"
	unzip -o -d $filename $filepath
	/usr/bin/php /home/oneindex/one.php upload:folder "$filename"/ /Aria2/"${filename##*/}"/
	#skicka upload "$filename"/ /Aria2/"${filename##*/}"/
	#rm -rf "$filepath" "$filename"
	rm -rf "$filename"
	echo '解压文件上传'$path >> /root/UpDrive.log
	
elif [[ $extension = "rar11" ]] ; then 
	echo "解压 RAR"
	unzip -o -d $filename $filepath
	#skicka upload "$filename"/ /Aria2/"${filename##*/}"/
	rm -rf "$filepath" "$filename"
	exit
	
else
	echo "不解压"
fi

path=${path%/*};
if [ "$path" = "$downloadpath" ] && [ $2 -eq 1 ]  #如果下载的是单个文件
    then
	/usr/bin/php /home/oneindex/one.php upload:file "$filepath" /Aria2/
	#skicka upload "$filepath" /Aria2
    rm -rf "$filepath"
	echo '删除上传完成'$filepath >> /root/UpDrive.log
    exit 0
elif [ "$path" = "$downloadpath" ]   #文件夹
    then
	/usr/bin/php /home/oneindex/one.php upload:folder "$filepath"/ /Aria2/"${filepath##*/}"/
	#skicka upload "$filepath"/ /Aria2/"${filepath##*/}"/
    rm -rf "$filepath"/
	echo '删除上传完成'$filepath >> /root/UpDrive.log
    exit 0
fi
done

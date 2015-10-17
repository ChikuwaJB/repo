#!/bin/bash
export LANG=ja_JP.UTF-8
export LESSCHARSET=utf-8
script_dir=$(dirname $0)
cur=$(pwd)

cd "$script_dir"
if [ $# -eq 0 ]; then
  echo "Usage: $0 <command>" >&2
  exit 1
fi

if [ "$1" == "add" ]; then
	if [ "$#" -ne 3 ]; then
	  echo "Usage: $0 add <package> <deb file>" >&2
	  exit 1
	fi
	echo "Adding new package...";

	cp "$3" "$script_dir/debs/$2.deb"

elif [ "$1" == "update" ]; then
	echo "Updating packaging...";
else
	echo "Usage: $0 <command>" >&2
	exit 1
fi

rm Packages.bz2
rm Packages
i=0
for deb in debs/*.deb
do
  i=`expr $i + 1`
	echo "$deb を処理中！";
  dpkg-deb -f "$deb" >> Packages
  md5sum "$deb" | echo "MD5sum: $(awk '{ print $1 }')" >> Packages
  wc -c "$deb" | echo "Size: $(awk '{ print $1 }')" >> Packages
  echo "Filename: $deb" >> Packages
  dpkg-deb -f "$deb" Package | echo "Depiction: http://repo.chikuwajb.cf/dp/?p=$(xargs -0)" >> Packages
  echo "" >> Packages
done

echo "" >> Packages; ## Add extra new line
echo "圧縮中。。。"
cp Packages Packages.txt
bzip2 Packages
echo "完了！"
n=`cat zenkai`
echo -n "${i}" > zenkai
echo "${i}個のパッケージを処理しました。(前回は${n}個)"

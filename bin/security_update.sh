#!/usr/bin/sh
echo "security_update処理を開始します。"

MYHOST=$(hostname -s)
HOSTNUM=$(echo $MYHOST | cut -c 1-1 | rev)
HOSTNUM=${MYHOST: -1:1}
HOSTNUM=$(( $HOSTNUM % 2 ))
MONTH=$(date '+%-m')
MONTHNUM=$(( $MONTH % 2))

if [ $HOSTNUM -eq $MONTHNUM ];then
	cd /security
	yum list installed > /script/log/yum_list_before.log
	curl http://cefs.steve-meier.de/errata.latest.xml.bz2 -O
	bzip2 -dc /security/errata.latest.xml.bz2 > /security/errata.latest.xml
	python generate_updateinfo.py --destination=/security --release=7 errata.latest.xml
	modifyrepo /security/updateinfo-7/updateinfo.xml /security/repodata/
	yum --security check-update
	yum -y --security update
		if [ $? -eq 0 ];then
			echo "security_updateが成功しました。"
			RESULT=0
		else
			echo "security_updateが失敗しました。"
			RESULT=1
		fi
	yum list installed > /script/log/yum_list_after.log
	diff /script/log/yum_list_before.log /script/log/yum_list_after.log > /script/log/yum_list_diff.log
else
    echo "security_updateの実行週ではありません。Updateをスキップします。"
    echo "全ての処理は正常に完了しました。スクリプトを終了します。"
    exit 0
fi

if [ $RESULT -eq 0 ];then
	echo "スクリプト終了後、5分待機して再起動します。"
	echo "全ての処理は正常に完了しました。スクリプトを終了します。"
	shutdown -r +5
	exit 0
else
	echo "処理は失敗しました。スクリプトを終了します。"
	exit 1
fi

#!/bin/sh
SOURCE_PATH="/mnt/gsuite/close/ADIV/ADIV_Share/社員情報/"
#SOURCE_PATH="/mnt/gsuite/temporary/urano/"
FILE_NAME="社員情報_`date -d '1day' +%Y%m%d`.emp"
DESTINATION_PATH="/script/tmp/社員情報.xlsx"
#DESTINATION_PATH="/mnt/gsuite/temporary/urano/des/社員情報.xlsx"
BACKUP_PATH="/mnt/gsuite/close/ADIV/ADIV_Share/社員情報/old/"
#BACKUP_PATH="/mnt/gsuite/temporary/urano/old/"
CHECK_PATH="/mnt/gsuite/close"
#ファイルがあったら削除
if [ -e $DESTINATION_PATH ]; then
  rm -f $DESTINATION_PATH
fi
#mountしてなかったらする
if [ ! -e $CHECK_PATH ]; then
  sudo mount -t cifs -o username=administrator,password=34Xv2D+9 //moose.dad-way.local/share /mnt/gsuite
fi
#「社員情報_YYYYMMDD.emp」のファイルがあればコピー。なければ「社員情報.emp」をコピー
#YYYYMMDDは現在日付。
if [ -e $SOURCE_PATH$FILE_NAME ]; then
  cp $SOURCE_PATH$FILE_NAME $DESTINATION_PATH
  cp -f $SOURCE_PATH$FILE_NAME $SOURCE_PATH"社員情報.emp"
  mv -f $SOURCE_PATH$FILE_NAME $BACKUP_PATH$FILE_NAME
else
  cp $SOURCE_PATH"社員情報.emp" $DESTINATION_PATH
fi

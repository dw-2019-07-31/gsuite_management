#!/bin/sh
SOURCE_PATH="/mnt/gsuite/close/ADIV/ADIV_Share/社員情報/社員情報.emp"
DESTINATION_PATH="/script/tmp/社員情報.xlsx"
CHECK_PATH="/mnt/gsuite/close"
#ファイルがあったら削除
if [ -e $DESTINATION_PATH ]; then
  rm -f $DESTINATION_PATH
fi
#社員情報ファイルコピー
if [ -e $CHECK_PATH ]; then
  cp $SOURCE_PATH $DESTINATION_PATH
else
  sudo mount -t cifs -o username=administrator,password=34Xv2D+9 //moose.dad-way.local/share /mnt/gsuite
  cp $SOURCE_PATH $DESTINATION_PATH
fi

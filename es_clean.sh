#!/bin/bash

###################################
#删除早于7天的ES集群的索引
###################################
function delete_indices() {
    comp_date=`date -d "7 days ago" +"%Y-%m-%d"`
    date1="$1 00:00:00"
    date2="$comp_date 00:00:00"

    t1=`date -d "$date1" +%s`
    t2=`date -d "$date2" +%s`

    if [ $t1 -le $t2 ]; then
        echo "$1时间早于$comp_date，进行索引删除"
        #转换一下格式，将类似2019-01-01格式转化为2019.01.01
        format_date=`echo $1| sed 's/-/\./g'`
        curl -XDELETE http://172.17.3.102:9200/*$format_date
    fi
}

curl -XGET http://172.17.3.102:9200/_cat/indices | awk -F" " '{print $3}' | awk -F"-" '{print $NF}' | egrep "[0-9]*\.[0-9]*\.[0-9]*" | sort | uniq  | sed 's/\./-/g' | while read LINE
do
    #调用索引删除函数
    delete_indices $LINE
done

if [ $? -eq 0 ];then
  curl 'https://oapi.dingtalk.com/robot/send?access_token=8a85bbc0b969c7e650d080910f6db82ad1078dcf4862d65045f7bb2d68d28324' \
  -H 'Content-Type: application/json' \
  -d '
  {"msgtype": "text",
    "text": {
      "content": "ELK索引清除7天以上成功"
    }
  }'
else
  curl 'https://oapi.dingtalk.com/robot/send?access_token=8a85bbc0b969c7e650d080910f6db82ad1078dcf4862d65045f7bb2d68d28324' \
  -H 'Content-Type: application/json' \
  -d '
  {"msgtype": "text",
    "text": {
      "content": "ELK索引清除7天以上失败"
    }
  }'									    
fi

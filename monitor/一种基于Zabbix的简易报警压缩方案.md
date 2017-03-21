# 一种基于Zabbix的简易报警压缩方案

支持简单压缩合并

## 架构图

![](img/zabbix-alert.png)

## 配置动作

默认信息

```
{'date':'{DATE}', 'time':'{TIME}', 'itemid':'{ITEM.ID}', 'actionid':'{ACTION.ID}', 'downdate':'{EVENT.DATE}', 'downtime':'{EVENT.TIME}', 'age':'{EVENT.AGE}', 'ip':'{HOST.CONN1}', 'triggerid':'{TRIGGER.ID}', 'name':'{TRIGGER.NAME}', 'status':'{TRIGGER.STATUS}', 'severity':'{TRIGGER.SEVERITY}', 'url':'{TRIGGER.URL}', 'itemname':'{ITEM.NAME1}', 'itemname2':'{ITEM.NAME2}', 'hostname':'{HOST.HOST1}', 'itemkey':'{ITEM.KEY1}', 'itemkey2':'{ITEM.KEY2}','itemvalue':'{ITEM.VALUE1}', 'itemvalue2':'{ITEM.VALUE2}', 'eventid':'{EVENT.ID}','hostgroup':'{TRIGGER.HOSTGROUP.NAME}'}
```

恢复信息

```
{'date':'{DATE}', 'time':'{TIME}', 'itemid':'{ITEM.ID}', 'actionid':'{ACTION.ID}', 'downdate':'{EVENT.DATE}', 'downtime':'{EVENT.TIME}', 'age':'{EVENT.AGE}', 'ip':'{HOST.CONN1}', 'triggerid':'{TRIGGER.ID}', 'name':'{TRIGGER.NAME}', 'status':'{TRIGGER.STATUS}', 'severity':'{TRIGGER.SEVERITY}', 'url':'{TRIGGER.URL}', 'itemname':'{ITEM.NAME1}', 'itemname2':'{ITEM.NAME2}', 'hostname':'{HOST.HOST1}', 'itemkey':'{ITEM.KEY1}', 'itemkey2':'{ITEM.KEY2}','itemvalue':'{ITEM.VALUE1}', 'itemvalue2':'{ITEM.VALUE2}', 'eventid':'{EVENT.ID}','hostgroup':'{TRIGGER.HOSTGROUP.NAME}','update':'{EVENT.RECOVERY.DATE}', 'uptime':'{EVENT.RECOVERY.TIME}'}
```
## kapacitor报警使用此脚本
参考`tools/k2zabbix.py`

## HTTP MAIL
使用 <https://github.com/iambocai/mailer> 在多台机器上搭建并使用Nginx做负载均衡，避免单台机器发送频率过快被对方服务器限制。

如使用本地smtp，建议使用postfix搭建。sendmail会出现 `unencrypted connection` 错误。原因尚未调查。

## 合并效果预览

![](img/alert-reduce.png)

## 报警统计
报警数据push到InfluxDB,用Grafana可以展示报警数据，例如小时报警量，天报警量，周报警量，报警接收人排行，报警类型排行等等

![](img/alertlog.png)

## 附录
报警联系人查询接口(cmdbApi)基于iTop实现，链接：[https://github.com/annProg/cmdbApi](https://github.com/annProg/cmdbApi)。
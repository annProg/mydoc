# Zabbix问题处理

## Zabbix discoverer processes more than 75% busy

修改server配置文件

```
### Option: StartDiscoverers
#   Number of pre-forked instances of discoverers.
#
# Mandatory: no
# Range: 0-250
# Default:
# StartDiscoverers=1
StartDiscoverers=5
```

StartDiscoverers改大一些。[1]

可以看到效果明显

![](image/zabbix_discovery.png)

## Zabbix agent on Zabbix server is unreachable
参考[2]:

> This problems can have lots of different causes.
>
> * Try to check the following:  
> * Is the Zabbix Server allowed to connect to Agent in zabbix_agentd.conf?  
> * Is Zabbix Agent running? (systemctl status, or ps -A)
> * What is your OS? Do you have SELinux enabled?


## 邮件延迟

邮件服务器会限制发信频率，超过频率可能会造成邮件队列堆积，告警邮件不能及时发出，或者收到一天甚至几天前的告警。

### 解决方案：

* 合理设置告警动作，例如，1般处理完成故障都是分钟级的，就没必要把step的持续时间设置为秒级了。如果SLA规定10分钟，那就可以step1-0隔10分钟
* 示警媒介使用多收件人，这样可以减少邮件数量
* 使用多个邮件服务发信（sendcloud, mailgun等或者公共邮箱的smtp服务）
* 经常清理过期邮件队列。自行搭建smtp服务器时，zabbix面板如果没有故障，可以把deffered队列全部清了

### postfix队列相关操作

```
postqueue -p    #查看队列
postsuper -d ALL deferred #清除deffered队列
```

## 参考资料



```
[1]. https://www.zabbix.com/forum/showthread.php?t=25417
[2]. https://87.110.183.172/forum/showthread.php?t=49999
```

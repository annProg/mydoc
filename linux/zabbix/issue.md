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

## 参考资料


```
[1]. https://www.zabbix.com/forum/showthread.php?t=25417
[2]. https://87.110.183.172/forum/showthread.php?t=49999
```

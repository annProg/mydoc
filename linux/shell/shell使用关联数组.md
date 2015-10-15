# Shell使用关联数组

Shell数组默认以下标访问，因此键名都是整数。如果想使用字符串做为键名，可以通过关联数组来处理。

使用关联数组前，需要显示声明 : declare -A arrayName，示例代码如下。

```
#!/bin/bash

############################
# Usage:
# File Name: arr.sh
# Author: annhe  
# Mail: i@annhe.net
# Created Time: 2015-10-15 11:59:11
############################

declare -A fields
fields=(
[hostname]=restlasttest.cnc.proxy.1
[sn]=vm20150101-1
[vendor]=VMware
[mem]=4
[cpu]=8
[IP]=10.0.0.1
[administrator]=10
[product-line]=20
)

echo "hostname: "${fields["hostname"]}
echo "sn: "${fields["sn"]}
echo "mem: "${fields["mem"]}

echo "all keys: "${!fields[*]}
echo "sum(keys): "${#fields[@]}
echo "all values: "${fields[@]}
```

执行结果

```
[root@repo tmp]# ./arr.sh 
hostname: restlasttest.cnc.proxy.1
sn: vm20150101-1
mem: 4
all keys: hostname product-line mem sn administrator vendor IP cpu
sum(keys): 8
all values: restlasttest.cnc.proxy.1 20 4 vm20150101-1 10 VMware 10.0.0.1 8
```
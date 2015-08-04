# 找出子网中最长连续可用IP

昨天的一道面试题，要求找出一个网段中最长的连续可用IP，需要考虑关机的但已经静态分配了IP的机器。

当时用ping找出了能ping通的IP，但是没有想到怎么找出最长的连续段，并且不模拟多线程会比较慢。现在先不考虑关机的情况，用nmap做一遍。代码如下：

```
#!/bin/bash

#-----------------------------------------------------------
# Usage: 找出子网中最长连续可用ip
# $Id: continuous-ip-baidu.sh  i@annhe.net  2015-08-04 12:06:11 $
#-----------------------------------------------------------

subnet="192.168.60.0/24"

used=(`nmap -sP -n $subnet |grep report |awk -F "." '{print $NF}'`)

echo "used: ${used[*]}"
num=${#used[*]}

let max=${used[1]}-${used[0]}
continuous="${used[0]} -> ${used[1]}"
for ((i=0; i<num-1; i++)); do
	let next=i+1
	let sum=${used[next]}-${used[i]}
	if [ $sum -gt $max ]; then
		max=$sum
		continuous="${used[$i]} -> ${used[$next]}"
	fi
done

echo -e "\n$continuous -- max:$max"
```

结果如下：

```
[root@HADOOP-215 interview]# ./continuous-ip-baidu.sh 
used: 1 2 129 254

2 -> 129 -- max:127
```
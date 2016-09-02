# Kapacitor行为测试

## 测试数据

```
#!/bin/bash

influx="http://localhost:8086/write?db=test"

i1=(1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
i1=(1 1 0 1 0 1 1 1 1 1)

for id in ${i1[@]};do
	curl -i -XPOST $influx --data-binary "ka,app=cmdb code_match=$id,http_code=200"
	sleep 1
done
```

## 简单序列测试

tickscript：

```
var origin = stream
	|from()
		.database('test')
		.retentionPolicy('default')
		.measurement('ka')
		.groupBy('app')

origin
	
	|alert()
		.id('HTTP_CODE:{{ index .Tags "app" }}')
		.message('')
		.crit(lambda: "code_match" == 0)
		.log('/tmp/alerts.log')
```

测试数据

```
i1=(1 1 0 1 0 1 1 1 1 1)
```

结果

```
[root@repo ~]# cat /tmp/alerts.log |jq . |grep "level"
  "level": "CRITICAL",
  "level": "OK",
  "level": "CRITICAL",
  "level": "OK",
```

结论：

1. 每个点顺序匹配，状态频繁变更。

## 加windows测试

tickscript：

```
var win = 5s
var origin = stream
	|from()
		.database('test')
		.retentionPolicy('default')
		.measurement('ka')
		.groupBy('app')

origin
	|window()
		.period(win)
		.every(1s)
	
	|alert()
		.id('HTTP_CODE:{{ index .Tags "app" }}')
		.message('')
		.crit(lambda: "code_match" == 0)
		.log('/tmp/alerts.log')
```

测试数据

```
i1=(1 1 0 1 0 1 1 1 1 1)
```

结果

```
1,1,0	"CRITICAL"	0
1,1,0,1	"CRITICAL"	0
1,0,1,0	"CRITICAL"	0
0,1,0,1	"CRITICAL"	0
1,0,1,1	"CRITICAL"	2034708173
0,1,1,1	"CRITICAL"	2034708173
1,1,1,1	"OK"	    7107346394
```

结论：

1. 可以看到，如果有一个0进入win，那么就保持crit状态，并且duration直到这个0出了win之后才会变化
2. win全部为1时才触发OK状态
3. 故障时间为7s，从第一个0开始算起。实际故障时间可能认为只有 `0 1 0` 这个序列的3s。故实际故障时间可能是 `7-win+1`

## all()测试

tickscript：

```
var win = 5s
var origin = stream
	|from()
		.database('test')
		.retentionPolicy('default')
		.measurement('ka')
		.groupBy('app')

origin
	|window()
		.period(win)
		.every(1s)
	
	|alert()
		.id('HTTP_CODE:{{ index .Tags "app" }}')
		.message('')
		.all()
		.crit(lambda: "code_match" == 0)
		.log('/tmp/alerts.log')
		.all()
```

测试数据

```
i1=(1 1 0 1 0 1 1 1 1 1)
```

结果

```
无报警
```

结论：

1. 一个win里面全部数据都满足条件才能触发

测试数据2

```
i1=(1 0 0 0 0 1 1 1 1 1 0 1 1)
```

结果

```
0,0,0,0	"CRITICAL"	0
0,0,0,1	"OK"	    1022011392
```

结论：

1. 一个win里面全部数据都满足条件才能触发
2. 报警之后如果有一个1进入win，那么立即离开crit状态
3. duration为1s，少于实际故障时间。实际应为 `1s + win - 1`

## influxql测试

tickscript：

```
var win = 5s
var origin = stream
	|from()
		.database('test')
		.retentionPolicy('default')
		.measurement('ka')
		.groupBy('app')

origin
	|window()
		.period(win)
		.every(1s)
	
	|stddev('code_match')
	|alert()
		.id('HTTP_CODE:{{ index .Tags "app" }}')
		.message('')
		.all()
		.crit(lambda: "stddev" > 0)
		.log('/tmp/alerts.log')
		.all()
```

结论：

1. 原始fileds被丢弃，不能满足需求，放弃




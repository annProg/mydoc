# Kapacitor行为测试
公司的Url监控需求之前是用zabbix的`web scenarios`来做的，优点是zabbix的触发器功能很好用，缺点是：

* 和其他系统的结合有些不够方便灵活
* item名称长度有限制，不能显示完整的url
* 无法记录请求失败时的网页内容（只告诉你匹配失败了）

因此决定尝试使用telegraf，写一个[Url监控插件](https://github.com/annProg/url_monitor) 来做这个事情。因为是向influxdb提交数据，支持push任意tags和fields(指标)，因此可以很方便的记录url，url归属的app，失败时的返回数据，甚至阈值匹配结果。

报警使用TickStack里的kapacitor，但是这个工具没有zabbix的trigger简单直观，理解起来有点费劲，设置不好会导致报警频繁。下面是我一开始约遇到的问题：

1. 不用滑动窗口的情况下(window)，报警很频繁
2. 用滑动窗口，窗口里有一个监控点失败，立即报警，单要等窗口里全是正常point之后才会触发OK
3. 如果使用.all()，可以改善第2条的问题，但是一旦有正常point进入窗口，立即触发OK状态（在zabbix里有Hysterisis功能，可以设置连续n次都成功才能从Problem转到OK）
4. 使用influxqlnode，计算平均值，，会丢弃原始的fields

需要实现的报警效果：窗口中所有的point都异常，触发Problem状态，窗口中所有point都恢复，触发OK状态。

下面是我最近几天的测试结果（基于0.13.1版本和1.0-rc2版本）以及目前的解决方案。


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


## kapacitor 1.0 reset表达式

github上提issue：[#863](https://github.com/influxdata/kapacitor/issues/863)，得到答复后尝试了 reset表达式（感觉跟flapping很像），然而还是要用influxqlnode，原始的Fields还是会消失。

## joinNode
继续自己试验探索，最后通过joinNode，终于实现了既使用influxqlnode的计算node，又保留Fields的需求。

```
var win = 5s
var origin = stream
    |from()
        .database('test')
        .retentionPolicy('default')
        .measurement('ka')
        .groupBy('app')
    |window()
        .period(win)
        .every(1s)

var code_match = origin
    |mean('code_match')

var http_code = origin
	|last('http_code')

code_match
	|join(http_code)
		.as('code_match', 'http_code')
    |alert()
        .id('HTTP_CODE:{{ index .Tags "app" }}')
        .message('')
		.stateChangesOnly()
        .crit(lambda: "code_match.mean" == 0)
        .critReset(lambda: "code_match.mean" == 1)
        .log('/tmp/alerts.log')
```

测试数据

```
i1=(1 0 0 0 0 1 1 1 1 1 0 1 1)
```

结果可以看到，Fields没有少，而且duration也更准确了，完美

```
{
  "data": {
    "series": [
      {
        "values": [
          [
            "2016-09-04T16:16:35.686926673Z",
            0,
            0,
            200
          ]
        ],
        "columns": [
          "time",
          "code_match.mean",
          "http_code.code_match",
          "http_code.last"
        ],
        "tags": {
          "app": "cmdb"
        },
        "name": "ka"
      }
    ]
  },
  "level": "CRITICAL",
  "duration": 0,
  "time": "2016-09-04T16:16:35.686926673Z",
  "details": "{&#34;Name&#34;:&#34;ka&#34;,&#34;TaskName&#34;:&#34;test&#34;,&#34;Group&#34;:&#34;app=cmdb&#34;,&#34;Tags&#34;:{&#34;app&#34;:&#34;cmdb&#34;},&#34;ID&#34;:&#34;HTTP_CODE:cmdb&#34;,&#34;Fields&#34;:{&#34;code_match.mean&#34;:0,&#34;http_code.code_match&#34;:0,&#34;http_code.last&#34;:200},&#34;Level&#34;:&#34;CRITICAL&#34;,&#34;Time&#34;:&#34;2016-09-04T16:16:35.686926673Z&#34;,&#34;Message&#34;:&#34;&#34;}\n",
  "message": "",
  "id": "HTTP_CODE:cmdb"
}
{
  "data": {
    "series": [
      {
        "values": [
          [
            "2016-09-04T16:16:39.83037438Z",
            1,
            1,
            200
          ]
        ],
        "columns": [
          "time",
          "code_match.mean",
          "http_code.code_match",
          "http_code.last"
        ],
        "tags": {
          "app": "cmdb"
        },
        "name": "ka"
      }
    ]
  },
  "level": "OK",
  "duration": 4143447707,
  "time": "2016-09-04T16:16:39.83037438Z",
  "details": "{&#34;Name&#34;:&#34;ka&#34;,&#34;TaskName&#34;:&#34;test&#34;,&#34;Group&#34;:&#34;app=cmdb&#34;,&#34;Tags&#34;:{&#34;app&#34;:&#34;cmdb&#34;},&#34;ID&#34;:&#34;HTTP_CODE:cmdb&#34;,&#34;Fields&#34;:{&#34;code_match.mean&#34;:1,&#34;http_code.code_match&#34;:1,&#34;http_code.last&#34;:200},&#34;Level&#34;:&#34;OK&#34;,&#34;Time&#34;:&#34;2016-09-04T16:16:39.83037438Z&#34;,&#34;Message&#34;:&#34;&#34;}\n",
  "message": "",
  "id": "HTTP_CODE:cmdb"
}
```

## 使用Fields作为变量
tickscript：

```
var win = 5s
var origin = stream
    |from()
        .database('test')
        .retentionPolicy('default')
        .measurement('ka')
        .groupBy('app')
    |window()
        .period(win)
        .every(1s)

origin
    |alert()
		.id('HTTP_CODE:{{ index .Tags "app" }}')
		.message('')
		.stateChangesOnly()
		.all()
		.crit(lambda: "code_match" < "count")
		.log('/tmp/alerts.log')
```

测试数据及脚本:

```
i1=(1 0 0 0 0 1 1 1 1 1 0 1 1)

for id in ${i1[@]};do
	curl -i -XPOST $influx --data-binary "ka,app=cmdb code_match=$id,http_code=200,count=0.5"
	sleep 1
done
```

结果：

```
{
  "data": {
    "series": [
      {
        "values": [
          [
            "2016-09-05T06:24:31.532711141Z",
            0,
            0.5,
            200
          ],
          [
            "2016-09-05T06:24:32.621932436Z",
            0,
            0.5,
            200
          ],
          [
            "2016-09-05T06:24:33.64890981Z",
            0,
            0.5,
            200
          ],
          [
            "2016-09-05T06:24:34.686454948Z",
            0,
            0.5,
            200
          ]
        ],
        "columns": [
          "time",
          "code_match",
          "count",
          "http_code"
        ],
        "tags": {
          "app": "cmdb"
        },
        "name": "ka"
      }
    ]
  },
  "level": "CRITICAL",
  "duration": 0,
  "time": "2016-09-05T06:24:35.686454948Z",
  "details": "{&#34;Name&#34;:&#34;ka&#34;,&#34;TaskName&#34;:&#34;test&#34;,&#34;Group&#34;:&#34;app=cmdb&#34;,&#34;Tags&#34;:{&#34;app&#34;:&#34;cmdb&#34;},&#34;ID&#34;:&#34;HTTP_CODE:cmdb&#34;,&#34;Fields&#34;:{&#34;code_match&#34;:0,&#34;count&#34;:0.5,&#34;http_code&#34;:200},&#34;Level&#34;:&#34;CRITICAL&#34;,&#34;Time&#34;:&#34;2016-09-05T06:24:35.686454948Z&#34;,&#34;Message&#34;:&#34;&#34;}\n",
  "message": "",
  "id": "HTTP_CODE:cmdb"
}
{
  "data": {
    "series": [
      {
        "values": [
          [
            "2016-09-05T06:24:32.621932436Z",
            0,
            0.5,
            200
          ],
          [
            "2016-09-05T06:24:33.64890981Z",
            0,
            0.5,
            200
          ],
          [
            "2016-09-05T06:24:34.686454948Z",
            0,
            0.5,
            200
          ],
          [
            "2016-09-05T06:24:35.705047313Z",
            1,
            0.5,
            200
          ]
        ],
        "columns": [
          "time",
          "code_match",
          "count",
          "http_code"
        ],
        "tags": {
          "app": "cmdb"
        },
        "name": "ka"
      }
    ]
  },
  "level": "OK",
  "duration": 1018592365,
  "time": "2016-09-05T06:24:36.705047313Z",
  "details": "{&#34;Name&#34;:&#34;ka&#34;,&#34;TaskName&#34;:&#34;test&#34;,&#34;Group&#34;:&#34;app=cmdb&#34;,&#34;Tags&#34;:{&#34;app&#34;:&#34;cmdb&#34;},&#34;ID&#34;:&#34;HTTP_CODE:cmdb&#34;,&#34;Fields&#34;:{&#34;code_match&#34;:0,&#34;count&#34;:0.5,&#34;http_code&#34;:200},&#34;Level&#34;:&#34;OK&#34;,&#34;Time&#34;:&#34;2016-09-05T06:24:36.705047313Z&#34;,&#34;Message&#34;:&#34;&#34;}\n",
  "message": "",
  "id": "HTTP_CODE:cmdb"
}
```

结论：

1. 可以实现Fields之间的数值比较
2. 可以用来自定义不同tags的阈值，例如监控流量异常，可以由用户定义流量增长几倍才算异常
		

## 参考资料
```
1. https://docs.influxdata.com/kapacitor/v0.13/
2. https://groups.google.com/forum/m/#!topic/influxdb/qg9on1deA_8
```
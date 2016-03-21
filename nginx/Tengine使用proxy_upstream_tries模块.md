# Tengine使用proxy_upstream_tries模块

proxy_next_upstream指令可以指定故障转移的状态码，但是不能限制故障转移的次数，当upstream全部故障时，所有upstream都会被请求一遍，造成后端压力成倍增加。因此有必要限制故障转移的次数。Tengine中使用proxy_upstream_tries模块实现限制重试的次数。

## 实验
只配置proxy_upstream_tries

```
proxy_upstream_tries 3;
```

不转移 500,502,503,504

```
10.0.0.10 [2016-01-12T11:33:16+08:00]  504 584 "GET / HTTP/1.1" "-" "curl" "-" "0.002" "up.204:49309" "504" "0.002"
10.0.0.10 [2016-01-12T11:33:17+08:00]  500 537 "GET / HTTP/1.1" "-" "curl" "-" "0.002" "up.157:49180" "500" "0.002"
10.0.0.10 [2016-01-12T10:56:37+08:00]  503 614 "GET / HTTP/1.1" "-" "curl" "-" "0.003" "up.204:49309" "503" "0.003"
10.0.0.10 [2016-01-12T11:33:49+08:00]  502 681 "GET / HTTP/1.1" "-" "curl" "-" "0.001" "up.204:49309" "502" "0.001"
```

配合proxy_next_upstream，可以实现5xx故障转移并且控制转移次数

```
    proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
    proxy_upstream_tries 2;
```

已负载2个后端，仍然没有得到正确响应码，直接返回后一个后端的状态码

```
10.0.0.10 [2016-01-12T11:37:58+08:00]  500 732 "GET / HTTP/1.1" "-" "curl" "-" "0.002" "up.204:49309, up.157:49180" "502, 500" "0.001, 0.001"
```

负载2个后端，返回200

```
10.0.0.10 [2016-01-12T11:37:53+08:00]  200 10224 "GET / HTTP/1.1" "-" "curl" "-" "0.011" "up.204:49309, up.157:49181" "502, 200" "0.001, 0.010"
```

## 与proxy_next_upstream的关系

由上面的实验可以看出proxy_upstream_tries和proxy_next_upstream可以协同工作。什么情况下重试由proxy_next_upstream决定。

## 参考资料
```
1. https://segmentfault.com/q/1010000004259366
```
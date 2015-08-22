# Linux系统监控工具

## cpu信息

### /proc/cpuinfo 查看cpu基本信息

```
[root@HADOOP-215 ~]# cat /proc/cpuinfo 
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 37
model name	: Intel(R) Core(TM) i5 CPU       M 480  @ 2.67GHz
stepping	: 5
cpu MHz		: 2659.978
cache size	: 3072 KB
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtr
r pge mca cmov pat pse36 clflush dts mmx fxsr sse sse2 ss syscall nx rdtscp lm constant_tsc up arch_perfmon pebs bts xtopology tsc_reliable nonstop_tsc aperfmperf unfair_spinlock pni ssse3 cx16 sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer hypervisor lahf_lm ida arat dtsbogomips	: 5319.95
clflush size	: 64
cache_alignment	: 64
address sizes	: 42 bits physical, 48 bits virtual
power management:
```

### uptime查看负载

```
[root@HADOOP-215 ~]# uptime 
 23:02:38 up 4 days,  2:12,  1 user,  load average: 0.00, 0.00, 0.00
```

> load average这个输出值，它的3个值的大小一般不能大于系统CPU的个数

### vmstat

```
[root@lab1 vhost]# vmstat --help
usage: vmstat [-V] [-n] [delay [count]]
              -V prints version.
              -n causes the headers not to be reprinted regularly. 表示在周期性循环输出时，输出的头部信息仅显示一次
              -a print inactive/active page stats.
              -d prints disk statistics
              -D prints disk table
              -p prints disk partition statistics
              -s prints vm table
              -m prints slabinfo
              -t add timestamp to output
              -S unit size
              delay is the delay between updates in seconds.   表示两次输出之间的间隔时间
              unit size k:1000 K:1024 m:1000000 M:1048576 (default is K)
              count is the number of updates.    表示按照“delay”指定的时间间隔统计的次数 | 默认为1
```

```
[root@HADOOP-215 ~]# vmstat
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0  79256  41724  23836  90836    0    0    29     6   77  122  1  0 98  0  0	
```

| ---- | ----- |
| proc - r | 运行和等待cpu时间片的进程数量，如果长时间大于0(另说大于系统cpu个数), 表示cpu不足 |
| proc - b | 等待资源（IO、memory）的进程数量，如果长时间大于0, 表示cpu不足 |
| cpu - us | 用户态时间，如果us + sy 大于80, 表示cpu不足 |
| cpu - sy | 系统态时间，如果us + sy 大于80, 表示cpu不足 |
| cpu - id | 系统空闲时间 |
| cpu - wa | 等待IO时间 根据经验，wa的参考值为20%，如果wa超过20%，说明I/O等待严重，引起I/O等待的原因可能是磁盘大量随机读写造成的 ，也可能是磁盘或者磁盘控制器的带宽瓶颈（主要是块操作）造成的 |
| cpu - st | 非自愿等待时间（系统调度） |
| system-in | 每秒设备中断数 |
| system-cs | 每秒产生的上下文切换次数 |

> in, cs 这两个值越大，由内核消耗的CPU时间越多  
> us 表示用户进程消耗的CPU时间百分比，us的值比较高时，说明用户进程消耗的CPU时间多，但是如果长期大于50%，就需要考虑优化程序或算法  
> sy列显示了内核进程消耗的CPU时间百分比，sy的值较高时，说明内核消耗的CPU资源很多  

### sar

需要安装sysstat

```
[root@lab1 vhost]# sar -h
用法: sar [ 选项 ] [ <时间间隔> [ <次数> ] ]
主选项和报告：
	-b	I/O 和传输速率信息状况
	-B	分页状况
	-d	块设备状况
	-I { <中断> | SUM | ALL | XALL }
		中断信息状况
	-m	电源管理信息状况
	-n { <关键词> [,...] | ALL }
		网络统计信息
		关键词可以是：
		DEV	网卡
		EDEV	网卡 (错误)
		NFS	NFS 客户端
		NFSD	NFS 服务器
		SOCK	Sockets (套接字)	(v4)
		IP	IP 流	(v4)
		EIP	IP 流	(v4) (错误)
		ICMP	ICMP 流	(v4)
		EICMP	ICMP 流	(v4) (错误)
		TCP	TCP 流	(v4)
		ETCP	TCP 流	(v4) (错误)
		UDP	UDP 流	(v4)
		SOCK6	Sockets (套接字)	(v6)
		IP6	IP 流	(v6)
		EIP6	IP 流	(v6) (错误)
		ICMP6	ICMP 流	(v6)
		EICMP6	ICMP 流	(v6) (错误)
		UDP6	UDP 流	(v6)
	-q	队列长度和平均负载
	-r	内存利用率
	-R	内存状况
	-S	交换空间利用率
	-u [ ALL ]
		CPU 利用率
	-v	Kernel table 状况
	-w	任务创建与系统转换统计信息
	-W	交换信息
	-y	TTY 设备状况
```

```
[root@HADOOP-215 ~]# sar -u 3 3
Linux 2.6.32-431.29.2.el6.x86_64 (HADOOP-215) 	2015年07月27日 	_x86_64_	(1 CPU)

23时14分00秒     CPU     %user     %nice   %system   %iowait    %steal     %idle
23时14分03秒     all      0.34      0.00      2.02      0.00      0.00     97.64
23时14分06秒     all      5.80      0.00      1.71      0.00      0.00     92.49
23时14分09秒     all      0.00      0.00      2.36      1.68      0.00     95.96
平均时间:     all      2.03      0.00      2.03      0.56      0.00     95.38
```

| ---- | ----- |
| %user | 等同于vmstat的us |
| %nice | 进程正常运行消耗的cpu(去除系统调度等其他开销) |
| %system | 等同于vmstat的sy |
| %iowait | 等同于vmstat的wa |
| %steal | 内存紧张时, pagein强制对不同的页面做的steal |
| %idle | 等同于vmstat的id |

### mpstat

包含在sysstat

```
[root@HADOOP-215 ~]# mpstat 
Linux 2.6.32-431.29.2.el6.x86_64 (HADOOP-215) 	2015年07月27日 	_x86_64_	(1 CPU)

23时18分51秒  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
23时18分51秒  all    1.16    0.00    0.38    0.42    0.00    0.04    0.00    0.00   98.00
```
| ---- | ----- |
| %irq | 中断消耗的cpu时间 |
| %soft | 软中断消耗的cpu时间 |
| %intr/s | cpu每秒收到的中断个数 |

### top

- 按`1`看系统当前cpu负载
- 按`bx`进入高亮模式， `>`和`<`选择CPU列，能看到进程CPU消耗排行

```
top - 23:26:08 up 4 days,  2:36,  1 user,  load average: 0.04, 0.05, 0.06
Tasks:  97 total,   1 running,  96 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.3%us,  0.3%sy,  0.0%ni, 98.0%id,  1.3%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:    486276k total,   442832k used,    43444k free,    17540k buffers
Swap:  1048572k total,   101992k used,   946580k free,   129584k cached

   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND                                                               
 57769 mongod    20   0  653m  61m  33m S  0.7 13.0  11:56.91 mongod                                                                 
   276 root      20   0     0    0    0 S  0.3  0.0   0:21.30 jbd2/sda2-8                                                            
  1593 mysql     20   0  709m  13m  744 S  0.3  2.8   2:39.87 mysqld                                                                 
 95127 root      20   0 15028 1276  984 R  0.3  0.3   0:00.02 top                                                                    
     1 root      20   0 19232  728  524 S  0.0  0.1   0:01.75 init                                                                   
     2 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kthreadd                                                               
     3 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 migration/0                                                            
     4 root      20   0     0    0    0 S  0.0  0.0   0:08.58 ksoftirqd/0                                                            
     5 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 migration/0                                                            
     6 root      RT   0     0    0    0 S  0.0  0.0   0:01.17 watchdog/0                                                             
     7 root      20   0     0    0    0 S  0.0  0.0   7:00.30 events/0                                                               
     8 root      20   0     0    0    0 S  0.0  0.0   0:00.00 cgroup                                                                 
     9 root      20   0     0    0    0 S  0.0  0.0   0:00.00 khelper                                                                
    10 root      20   0     0    0    0 S  0.0  0.0   0:00.00 netns                                                                  
    11 root      20   0     0    0    0 S  0.0  0.0   0:00.00 async/mgr                                                              
    12 root      20   0     0    0    0 S  0.0  0.0   0:00.00 pm                                                                     
    13 root      20   0     0    0    0 S  0.0  0.0   0:02.94 sync_supers                                                            
    14 root      20   0     0    0    0 S  0.0  0.0   0:02.52 bdi-default                                                            
    15 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kintegrityd/0                                                          
    16 root      20   0     0    0    0 S  0.0  0.0   0:20.20 kblockd/0                                                              
    17 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kacpid                                                                 
    18 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kacpi_notify                                                           
    19 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kacpi_hotplug 
```

| --- | ---- |
| Tasks-total | 进程的总数 |
| Tasks-running | 正在运行的进程数 |
| Tasks-sleeping | 处于休眠的进程数 |
| Tasks-stopped | 停止的进程数 |
| Tasks-zombie | 僵死的进程数 |
| Cpu(s)-%us | 表示用户进程占用CPU的百分比 |
| Cpu(s)-%sy | 系统进程占用CPU的百分比 |
| Cpu(s)-%ni | 用户进程空间内改变过优先级的进程占用CPU的百分比 |
| Cpu(s)-%id | 空闲CPU占用的百分比 |
| Cpu(s)-%wa | 等待输入输出的进程占用CPU的 |

## 内存监控
### free

```
[root@HADOOP-215 sar]# free -m
             total       used       free     shared    buffers     cached
Mem:           474        429         45          0         15        197
-/+ buffers/cache:        216        258
Swap:         1023        173        850
```

| ---- | ----- |
| total | 物理总内存 |
| used | 已经使用的内存 |
| free | 剩余内存 |
| shared | 使用的共享内存 |
| buffers | 磁盘块的读写缓存 |
| cached | 文件读写的cache |
| - buffer/cache | 实际使用的内存, userd - buffer - cache |
| + buffer/cache | 实际可用的内存, free + buffer + cache |
| swap | 交换分区 |

> 一般的经验公式是: 实际使用内存/ 系统物理内存> 70%时, 需要引起注意，考虑加内存了
> 
> 如果swap经常用到了很多, 这是真的内存不够了, 需要引起注意
> 
> 有一种不推荐的方式可以清空cache和buffer: echo "3" > /proc/sys/vm/drop_caches, 这会降低磁盘IO的效率

### vmstat

```
[root@lab1 vhost]# vmstat 1 2
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0   6216  52660  29384 317436    1    2    13    13   25   14  1  0 98  0  0	
 0  0   6216  52620  29384 317436    0    0     0     0   17   16  0  0 100  0  0	
```

| ---- | ----- |
| memory-swpd | 切换到内存交换区的内存大小（以KB为单位），如果swpd的值不为0，或者比较大，只要si、so的值长期为0，这种情况一般不用担心 ，不会影响系统性能 |
| memory-free | 当前空闲的物理内存数量（以KB为单位） |
| memory-buff | buffers cache的内存数量，一般对块设备的读写才需要缓冲 |
| memory-cache | page cached的内存数量，一般作为文件系统进行缓存，频繁访问的文件都会被缓存 |
|如果cache值较大 | 说明缓存的文件数较多，如果此时io中的bi比较小，说明文件系统效率比较好 |
|swap-si| 由磁盘调入内存，每秒从交换区写到内存的大小 - Amount of memory swapped in from disk (/s) |
|swap-so| 由内存调入磁盘，每秒写入交换区的内存大小 - Amount of memory swapped to disk (/s) |


### top

| ---- | ---- |
| VIRT | 进程占用总虚存, 包括了code, data, 动态链接库以及swap，一般看进程占用内存及内存泄漏, 关注这一项就对了 |
| RES | man上的解释是非swap内存，早期版本的kernel上man page里会说RES = CODE + DATA，但是实际漏了动态链接库的部分，现在的man page里已经不会有这个错误了 |
| SHR | 共享内存段, 包括mmap以及动态链接的部分. |


## I/O监控

### vmstat

```
[root@lab1 vhost]# vmstat 1 2
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0   6216  52660  29384 317436    1    2    13    13   25   14  1  0 98  0  0	
 0  0   6216  52620  29384 317436    0    0     0     0   17   16  0  0 100  0  0	
```

| ---- | ----- |
| io-bi | 表示从块设备读入数据的总量（即读磁盘）（kb/s） - Blocks received from a block device (blocks/s) |
| io-bo | bo列表示写到块设备的数据总量（即写磁盘）（kb/s） - Blocks sent to a block device (blocks/s) |


> 设置的bi+bo参考值为1000 | 如果超过1000 | 而且wa值较大 | 则表示系统磁盘I/O有问题 | 应该考虑提高磁盘的读写性能

### iostat

```
iostat [ -c | -d ] [ -k ] [ -t ] [ -x [ device ] ] [ interval  [ count ] ]

-c | 显示CPU的使用情况
-d | 显示磁盘的使用情况
-k | 每秒以KB为单位显示数据
-t | 打印出统计信息开始执行的时间
-p [ { device [,...] | ALL } ]
              The -p option displays statistics for block devices and all their partitions that are used by the system.
              If  a  device name is entered on the command line, then statistics for it and all its partitions are dis-
              played. Last, the ALL keyword indicates that statistics have to be displayed for all  the  block  devices
              and  partitions defined by the system, including those that have never been used. If option -j is defined
              before this option, devices entered on the command line can be specified with the chosen persistent  name
              type.  Note that this option works only with post 2.5 kernels.
-x device | 指定要统计的磁盘设备名称 | 默认为所有的磁盘设备
interval | 指定两次统计间隔的时间
count | 按照“interval”指定的时间间隔统计的次数 |
|
```

```
[root@lab1 ~]# iostat -d 2 3
Linux 2.6.32-431.el6.x86_64 (lab1) 	2015年08月16日 	_x86_64_	(1 CPU)

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda               0.71        24.55        25.15    5306090    5436544

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda               0.00         0.00         0.00          0          0

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda               0.00         0.00         0.00          0          0
```
| ---- | ----- |
| Blk_read/s | 每秒读取的数据块数 |
| Blk_wrtn/s | 每秒写入的数据块数 |
| Blk_read | 读取的所有块数 |
| Blk_wrtn | 写入的所有块数 |

> 第一行是系统从启动到统计时的所有传输信息 | 第二次输出的数据才代表在检测的时间段内系统的传输值

```
[root@lab1 ~]# iostat -p -k 1 1 
Linux 2.6.32-431.el6.x86_64 (lab1) 	2015年08月17日 	_x86_64_	(1 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.94    0.01    0.25    0.44    0.00   98.36

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda               0.68        11.21        11.70    2654385    2770312
sda1              0.04         1.07         1.99     253720     470244
sda2              0.64        10.13         9.71    2400057    2300068
```

| ---- | ----- |
| tps | 每秒处理的请求 |
| kB_read/s | 每秒的读数据量, 单位kB |
| kB_wrtn/s | 每秒的写数据量, 单位kB |
| kB_read | 监控时间内的总读数据量, 单位kB |
| kB_wrtn | 监控时间内的总写数据量, 单位kB |

```
[root@HADOOP-215 data1]# iostat -d -x /dev/sda 1 2
Linux 2.6.32-431.29.2.el6.x86_64 (HADOOP-215) 	2015年08月20日 	_x86_64_	(1 CPU)

Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz avgqu-sz   await  svctm  %util
sda               1.86     4.68    0.78    0.47    91.97    41.23   106.97     0.26  205.98   9.42   1.17

Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
```

```
rrqm/s: 每秒进行 merge 的读操作数目。即 delta(rmerge)/s
wrqm/s: 每秒进行 merge 的写操作数目。即 delta(wmerge)/s
r/s: 每秒完成的读 I/O 设备次数。即 delta(rio)/s
w/s: 每秒完成的写 I/O 设备次数。即 delta(wio)/s
rsec/s: 每秒读扇区数。即 delta(rsect)/s
wsec/s: 每秒写扇区数。即 delta(wsect)/s
rkB/s: 每秒读K字节数。是 rsect/s 的一半，因为每扇区大小为512字节。
wkB/s: 每秒写K字节数。是 wsect/s 的一半。
avgrq-sz: 平均每次设备I/O操作的数据大小 (扇区)。即 delta(rsect+wsect)/delta(rio+wio)
avgqu-sz: 平均I/O队列长度。即 delta(aveq)/s/1000 (因为aveq的单位为毫秒)。
await: 平均每次设备I/O操作的等待时间 (毫秒)。即 delta(ruse+wuse)/delta(rio+wio)
svctm: 平均每次设备I/O操作的服务时间 (毫秒)。即 delta(use)/delta(rio+wio)
%util: 一秒中有百分之多少的时间用于 I/O 操作，或者说一秒中有多少时间 I/O 队列是非空的。即 delta(use)/s/1000 (因为use的单位为毫秒)
```

### sar

* sar -d 可以观察每一块磁盘设备的IO.
* sar -b 可以监控IO速率, 类似iostat, 不过单位是block

```
[root@lab1 ~]# sar -d 1 1
Linux 2.6.32-431.el6.x86_64 (lab1) 	2015年08月17日 	_x86_64_	(1 CPU)

01时29分39秒       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
01时29分40秒    dev8-0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

平均时间:       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
平均时间:    dev8-0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
[root@lab1 ~]# sar -b 1 1
Linux 2.6.32-431.el6.x86_64 (lab1) 	2015年08月17日 	_x86_64_	(1 CPU)

01时29分48秒       tps      rtps      wtps   bread/s   bwrtn/s
01时29分49秒      0.00      0.00      0.00      0.00      0.00
平均时间:      0.00      0.00      0.00      0.00      0.00

```

```
rd_sec/s
     Number of sectors read from the device. The size of a sector is 512 bytes.
     每秒读取的sectors(每sector 512字节)
wr_sec/s
     Number of sectors written to the device. The size of a sector is 512 bytes.
     每秒写的sectors(每sector 512字节)
avgrq-sz
     The average size (in sectors) of the requests that were issued to the device.
     设备请求的平均size
avgqu-sz
     The average queue length of the requests that were issued to the device.

await
     The average time (in milliseconds) for I/O requests issued  to  the  device  to  be  served.  This
     includes the time spent by the requests in queue and the time spent servicing them.
     设备进行IO操作的平均等待时间(包含了IO队列的等待时间, 单位毫秒)
svctm
     The average service time (in milliseconds) for I/O requests that were issued to the device.
     设备进行IO操作的服务时间(真正做IO的时间, 单位毫秒)
%util
     Percentage  of CPU time during which I/O requests were issued to the device (bandwidth utilization
     for the device). Device saturation occurs when this value is close to 100%.  IO操作的时间百分比
```


- 正常情况下svctm小于await, 而svctm的大小和磁盘性能有关, cpu和内存的负载也会对svctm有影响.
- await的值, 是svctm加上IO队列等待的时间, 所以如果svctm与await非常接近, 说明IO队列几乎没有等待, 性能很好. 如果svctm和await相差比较大, 则说明IO队列等待的时间比较长, 可以做点优化了, 无论是应用层, 还是直接换硬件.
- %util也是衡量IO的一个重要指标, 这个值如果长期比较高, 表示IO存在瓶颈.

### 磁盘IO的一些建议

- 一般IO比较重的磁盘应用来做存储居多, 绝大部分会需要raid, 根据应用的不同, 选择合适的raid方式.
- 努力的使用cache, 尽可能的使用内存, 减少IO的次数.
- 读写分离, 轻重分离.

## 网络监控

### ping & telnet
检测网络连通性和端口

```
[root@lab1 ~]# ping -c 1 annhe.net
PING annhe.net (115.29.43.172) 56(84) bytes of data.
64 bytes from 115.29.43.172: icmp_seq=1 ttl=128 time=74.0 ms

--- annhe.net ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 164ms
rtt min/avg/max/mdev = 74.066/74.066/74.066/0.000 ms

[root@lab1 ~]# telnet annhe.net 80
Trying 115.29.43.172...
Connected to annhe.net.
Escape character is '^]'.
HEAD / HTTP/1.1
HOST:annhe.net

HTTP/1.1 301 Moved Permanently
Server: nginx
Date: Mon, 17 Aug 2015 03:39:06 GMT
Content-Type: text/html
Content-Length: 178
Connection: keep-alive
Location: http://www.annhe.net/
```

### netstat

获取网络基本情况

```
[root@lab1 ~]# netstat --help
usage: netstat [-veenNcCF] [<Af>] -r         netstat {-V|--version|-h|--help}
       netstat [-vnNcaeol] [<Socket> ...]
       netstat { [-veenNac] -I[<Iface>] | [-veenNac] -i | [-cnNe] -M | -s } [delay]

        -r, --route                display routing table
        -I, --interfaces=<Iface>   display interface table for <Iface>
        -i, --interfaces           display interface table
        -g, --groups               display multicast group memberships
        -s, --statistics           display networking statistics (like SNMP)
        -M, --masquerade           display masqueraded connections

        -v, --verbose              be verbose
        -n, --numeric              don't resolve names
        --numeric-hosts            don't resolve host names
        --numeric-ports            don't resolve port names
        --numeric-users            don't resolve user names
        -N, --symbolic             resolve hardware names
        -e, --extend               display other/more information
        -p, --programs             display PID/Program name for sockets
        -c, --continuous           continuous listing

        -l, --listening            display listening server sockets
        -a, --all, --listening     display all sockets (default: connected)
        -o, --timers               display timers
        -F, --fib                  display Forwarding Information Base (default)
        -C, --cache                display routing cache instead of FIB
        -T, --notrim               stop trimming long addresses
        -Z, --context              display SELinux security context for sockets

  <Iface>: Name of interface to monitor/list.
  <Socket>={-t|--tcp} {-u|--udp} {-S|--sctp} {-w|--raw} {-x|--unix} --ax25 --ipx --netrom
  <AF>=Use '-A <af>' or '--<af>'; default: inet
  List of possible address families (which support routing):
    inet (DARPA Internet) inet6 (IPv6) ax25 (AMPR AX.25) 
    netrom (AMPR NET/ROM) ipx (Novell IPX) ddp (Appletalk DDP) 
    x25 (CCITT X.25) 
```

### ethtool
获取网卡设备的信息

```
ethtool -i 获取网卡设备的信息
ethtool -d 获取网卡设备的注册信息
ethtool -r 重置网卡设备的统计信息
ethtool -S 查询网卡设备的收发包统计信息
ethtool -s [speed 10|100|1000] 设置网卡设备速率, 单位Mb
ethtool -s [duplex half|full] 设置网卡设备半双工|全双工
ethtool -s [autoneg on|off] 设置网卡设备是否自协商
```

### tcpdump

监听网络

tcpdump的语法, 是从pcap一脉相承下来的谓词语法过滤表达式, 再加了一些自己的命令行参数.

谓词语法, 简单来说就是"组合起来的一些简单条件", 具体的条件包括了: 类型(type)条件: host, port; 方向(dir)条件: src, dst; 协议(proto)条件: tcp, udp, ip, ip6等. 这些条件通过and, or和not就能组合起来, 形成一段过滤表达式.

tcpdump自己的命令行参数常用的有:

- -i, 指定网卡设备.
- -A, 以ascii码显示包内容.
- -x, -X, -xx, -XX, 以16进制显示包.

抓取192.168.60.129的icmp包

```
[root@lab1 ~]# tcpdump icmp and host 192.168.60.129
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
13:06:04.731830 IP 192.168.60.129 > lab1: ICMP echo request, id 4765, seq 1, length 64
13:06:04.731874 IP lab1 > 192.168.60.129: ICMP echo reply, id 4765, seq 1, length 64
^C
2 packets captured
2 packets received by filter
0 packets dropped by kernel
```

### sar

sar的n选项可以看到网络设备统计信息

```
[root@lab1 ~]# sar -h
用法: sar [ 选项 ] [ <时间间隔> [ <次数> ] ]
主选项和报告：
	-n { <关键词> [,...] | ALL }
		网络统计信息
		关键词可以是：
		DEV	网卡
		EDEV	网卡 (错误)
		NFS	NFS 客户端
		NFSD	NFS 服务器
		SOCK	Sockets (套接字)	(v4)
		IP	IP 流	(v4)
		EIP	IP 流	(v4) (错误)
		ICMP	ICMP 流	(v4)
		EICMP	ICMP 流	(v4) (错误)
		TCP	TCP 流	(v4)
		ETCP	TCP 流	(v4) (错误)
		UDP	UDP 流	(v4)
		SOCK6	Sockets (套接字)	(v6)
		IP6	IP 流	(v6)
		EIP6	IP 流	(v6) (错误)
		ICMP6	ICMP 流	(v6)
		EICMP6	ICMP 流	(v6) (错误)
		UDP6	UDP 流	(v6)
```

## 进程监控

### ps & pstree

ps

```
EXAMPLES
       To see every process on the system using standard syntax:
          ps -e
          ps -ef
          ps -eF
          ps -ely

       To see every process on the system using BSD syntax:
          ps ax
          ps axu

       To print a process tree:
          ps -ejH
          ps axjf

       To get info about threads:
          ps -eLf
          ps axms

       To get security info:
          ps -eo euser,ruser,suser,fuser,f,comm,label
          ps axZ
          ps -eM

       To see every process running as root (real & effective ID) in user format:
          ps -U root -u root u

       To see every process with a user-defined format:
          ps -eo pid,tid,class,rtprio,ni,pri,psr,pcpu,stat,wchan:14,comm
          ps axo stat,euid,ruid,tty,tpgid,sess,pgrp,ppid,pid,pcpu,comm
          ps -eopid,tt,user,fname,tmout,f,wchan

       Print only the process IDs of syslogd:
          ps -C syslogd -o pid=

       Print only the name of PID 42:
          ps -p 42 -o comm=
```

```
[root@lab1 ~]# ps aux |more
USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root          1  0.0  0.0  19232   444 ?        Ss   Aug14   0:02 /sbin/init
```

- USER：运行进程的账号
- PID ：该进程的进程ID号。
- %CPU：该进程使用掉的 CPU 资源百分比；
- %MEM：该进程所占用的物理内存百分比；
- VSZ ：该进程使用掉的虚拟内存量 (Kbytes)
- RSS ：该进程实际使用物理内存 (Kbytes) resident set size, the non-swapped physical memory that a task has used (in kiloBytes).(alias rssize, rsz).
- TTY ：该进程是在那个终端机上面运作，若与终端机无关，则显示 ?，另外， tty1-tty6 是本机上面的登入者程序，若为 pts/0 等等的，则表示为由网络连接进主机的程序。
- STAT：该程序目前的状态，主要的状态有：
    - R ：该程序目前正在运作，或者是可被运作；
    - S ：该程序目前正在睡眠当中 (可说是 idle 状态啦！)，但可被某些讯号(signal) 唤醒。
    - T ：该程序目前正在侦测或者是停止了；
    - Z ：该程序应该已经终止，但是其父程序却无法正常的终止他，造成 zombie (疆尸) 程序的状态
    - < ：高优先级
    - N ：低优先级
    - L ：有些页被锁进内存
    - s ：包含子进程
    - \+ ：位于后台的进程组；
    - l ：多线程，克隆线程  multi-threaded (using CLONE_THREAD, like NPTL pthreads do)
- START：该进程被触发启动的时间；
- TIME ：该进程实际使用 CPU 运作的时间。
- COMMAND：该程序的实际指令

pstree

```
[root@lab1 ~]# pstree -npu
init(1)─┬─udevd(347)─┬─udevd(1104)
        │            └─udevd(1105)
        ├─dhclient(880)
        ├─auditd(924)───{auditd}(925)
        ├─rsyslogd(940)─┬─{rsyslogd}(941)
        │               ├─{rsyslogd}(943)
        │               └─{rsyslogd}(944)
        ├─master(1065)─┬─qmgr(1098,postfix)
        │              └─pickup(41090,postfix)
        ├─crond(1073)
        ├─mingetty(1086)
        ├─mingetty(1088)
        ├─mingetty(1090)
        ├─mingetty(1092)
        ├─mingetty(1094)
        ├─mingetty(1096)
        ├─sshd(2576)───sshd(40107)───bash(40109)───pstree(41346)
        ├─memcached(12553)─┬─{memcached}(12554)
        │                  ├─{memcached}(12555)
        │                  ├─{memcached}(12556)
        │                  ├─{memcached}(12557)
        │                  └─{memcached}(12558)
        ├─nginx(17718)───nginx(35466,www)
        └─php-fpm(120690)─┬─php-fpm(120691,www)
                          └─php-fpm(120692,www)
```

### top

S列是进程状态

```
w: S  --  Process Status
  The status of the task which can be one of:
     ’D’ = uninterruptible sleep
     ’R’ = running
     ’S’ = sleeping
     ’T’ = traced or stopped
     ’Z’ = zombie
```

### watch
监控进程是否存在

```
nohup watch -n 2 'ps aux |grep php |grep -v grep >/tmp/php.log' &>/dev/null &
```

## 其他

- strace 查看系统调用
- valgrind 内存调试和检测

## 参考资料

```
[1]. Linux系统监控. http://www.gaccob.com/publish/tools/linux_monitor.pdf
[2]. 高俊峰. 高性能Linux服务器构建实战：运维监控、性能调优与集群应用[M]// 北京华章图文信息有限公司, 2012.
[3]. Linux tcpdump命令详解. http://www.cnblogs.com/ggjucheng/archive/2012/01/14/2322659.html
[4]. Linux工具快速教程. http://linuxtools-rst.readthedocs.org/zh_CN/latest/index.html
[5]. iostat命令详解. http://blog.csdn.net/wyzxg/article/details/3985221
```

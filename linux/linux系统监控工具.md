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

### vmstat

```
[root@HADOOP-215 ~]# vmstat
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0  79256  41724  23836  90836    0    0    29     6   77  122  1  0 98  0  0	
```

| ---- | ----- |
| proc - r | 运行和等待cpu时间片的进程数量，如果长时间大于0, 表示cpu不足 |
| proc - b | 等待资源（IO、memory）的进程数量，如果长时间大于0, 表示cpu不足 |
| cpu - us | 用户态时间，如果us + sy 大于80, 表示cpu不足 |
| cpu - sy | 系统态时间，如果us + sy 大于80, 表示cpu不足 |
| cpu - id | 系统空闲时间 |
| cpu - wa | 等待IO时间 |
| cpu - st | 非自愿等待时间（系统调度） |


### sar

需要安装sysstat

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


## 内存监控
### free

```
[root@HADOOP-215 sar]# free -m
             total       used       free     shared    buffers     cached
Mem:           474        429         45          0         15        197
-/+ buffers/cache:        216        258
Swap:         1023        173        850
```



## 参考资料

```
[1]. Linux系统监控. http://www.gaccob.com/publish/tools/linux_monitor.pdf
[2]
```

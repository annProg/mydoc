# MySQL异常Got error 134排查

## 现象

Discuz论坛一张表反复崩溃，导致帖子页无法打开，日志如下：

```
150729 23:24:17 [ERROR] /usr/local/mysql/libexec/mysqld: Incorrect key file for table './bbs/forum_threadaddviews.MYI'; try to repair it
150729 23:24:18 [ERROR] /usr/local/mysql/libexec/mysqld: Incorrect key file for table './bbs/forum_threadaddviews.MYI'; try to repair it
150729 23:24:24 [ERROR] /usr/local/mysql/libexec/mysqld: Incorrect key file for table './bbs/forum_threadaddviews.MYI'; try to repair it
150729 23:24:33 [ERROR] Got error 134 when reading table './bbs/forum_forumrecommend'
150729 23:24:36 [ERROR] /usr/local/mysql/libexec/mysqld: Incorrect key file for table './bbs/forum_threadaddviews.MYI'; try to repair it
...
150729 23:25:51 [ERROR] /usr/local/mysql/libexec/mysqld: Table './bbs/forum_threadaddviews' is marked as crashed and should be repaired
150729 23:25:53 [ERROR] /usr/local/mysql/libexec/mysqld: Table './bbs/forum_threadaddviews' is marked as crashed and should be repaired
150729 23:25:53 [ERROR] /usr/local/mysql/libexec/mysqld: Table './bbs/forum_threadaddviews' is marked as crashed and should be repaired
150729 23:25:55 [ERROR] Got error 134 when reading table './bbs/forum_forumrecommend'
150729 23:25:55 [ERROR] /usr/local/mysql/libexec/mysqld: Table './bbs/forum_threadaddviews' is marked as crashed and should be repaired
150729 23:25:56 [ERROR] /usr/local/mysql/libexec/mysqld: Table './bbs/forum_threadaddviews' is marked as crashed and should be repaired
150729 23:25:56 [ERROR] /usr/local/mysql/libexec/mysqld: Table './bbs/forum_threadaddviews' is marked as crashed and should be repaired
```

表`forum_threadaddviews`修复后，mysql日志仍然在刷ERROR错误：

```
[root@localhost log]# tail -f mysql.err 
150730  0:03:17 [ERROR] Got error 134 when reading table './bbs/forum_forumrecommend'
150730  0:05:29 [ERROR] Got error 134 when reading table './bbs/forum_forumrecommend'
150730  0:05:45 [ERROR] Got error 134 when reading table './bbs/forum_forumrecommend'
150730  0:06:34 [ERROR] Got error 134 when reading table './bbs/forum_forumrecommend'
150730  0:06:49 [ERROR] Got error 134 when reading table './bbs/forum_forumrecommend'
```

## 追查

通过MySQL错误日志，可以看到`Got error 134`在13年8月和15年7月集中爆发，符合论坛近期的表现

```
[root@localhost var]# grep "Got error 134" mysql.err |awk '{print $1}' |sort |uniq -c
   3450 130112
    213 130801
    325 130802
    266 130803
    214 130804
    216 130805
    212 130806
    271 130807
    178 130808
    170 130809
    188 130810
    194 130811
    120 130812
    136 130813
    207 130814
    185 130815
    160 130816
    181 130817
    137 130818
      1 150706
    749 150713
   1333 150714
   1551 150715
   1569 150716
   1569 150717
   1522 150718
   1557 150719
   1534 150720
   1508 150721
   1430 150722
   1406 150723
   1400 150724
   1414 150725
   1469 150726
   1343 150727
   1360 150728
   1529 150729
     44 150730
```

`Got error 134`的表，几乎都是 `forum_forumrecommend`

```
[root@localhost var]# grep "Got error 134" mysql.err | grep "^1507" |awk '{print $NF}' |sort |uniq -c
  24287 './bbs/forum_forumrecommend'
      1 './bbs/forum_threadaddviews'
```

`forum_threadaddviews`表情况，也差不多是13年8月和15年7月比较集中

```
[root@localhost var]# grep "forum_threadaddviews" mysql.err |awk '{print $1}' |sort |uniq -c
   8312 121222
   4857 130101
   4874 130112
  12810 130126
    264 130128
   4260 130129
   2873 130219
   5507 130222
  19385 130223
   6753 130224
    213 130801
    325 130802
    266 130803
    214 130804
    216 130805
    212 130806
    271 130807
    178 130808
    170 130809
    188 130810
    194 130811
    120 130812
    136 130813
    207 130814
    185 130815
    160 130816
    181 130817
    137 130818
  34149 150311
  16083 150312
   3944 150415
   5343 150515
   1491 150516
  21939 150519
    557 150625
  26084 150626
  22901 150629
  36339 150706
  84450 150713
  54706 150714
  43947 150715
   1086 150717
  42033 150718
  52414 150719
  77772 150720
  70164 150721
  73334 150723
  41844 150724
  40190 150725
  65812 150726
  27799 150727
  39230 150728
  23982 150729
[root@localhost var]# 
```

## Got error 134
> Even though the MyISAM table format is very reliable (all changes to a table made by an SQL statement are written before the statement returns), you can still get corrupted tables if any of the following events occur:
> 
> - The mysqld process is killed in the middle of a write.
> - An unexpected computer shutdown occurs (for example, the computer is turned off).
> - Hardware failures.
> - You are using an external program (such as myisamchk ) to modify a table that is being modified by the server at the same time.
> - A software bug in the MySQL or MyISAM code.
> 
> Typical symptoms of a corrupt table are:
> You get the following error while selecting data from the table:
> 
> - Incorrect key file for table: '...'. Try to repair it
> - Queries don't find rows in the table or return incomplete results.
> 
> 来自：http://dev.mysql.com/doc/refman/5.0/en/corrupted-myisam-tables.html
 
解决：

```
CHECK TABLE 表名
REPAIR TABLE 表名
```


## 修复
检查`forum_forumrecommend`，可以看到确实有错误

```
mysql> check table forum_forumrecommend;
+-----------------------------+-------+----------+-----------------------------------------------------------+
| Table                       | Op    | Msg_type | Msg_text                                                  |
+-----------------------------+-------+----------+-----------------------------------------------------------+
| bbs.forum_forumrecommend | check | warning  | 70 clients are using or haven't closed the table properly |
| bbs.forum_forumrecommend | check | error    | Record-count is not ok; is 192   Should be: 193           |
| bbs.forum_forumrecommend | check | warning  | Found 415 deleted space.   Should be 0                    |
| bbs.forum_forumrecommend | check | warning  | Found 1 deleted blocks       Should be: 0                 |
| bbs.forum_forumrecommend | check | error    | Corrupt                                                   |
+-----------------------------+-------+----------+-----------------------------------------------------------+
```

修复`forum_forumrecommend`

```
mysql> repair table forum_forumrecommend;
+-----------------------------+--------+----------+----------------------------------------+
| Table                       | Op     | Msg_type | Msg_text                               |
+-----------------------------+--------+----------+----------------------------------------+
| bbs.forum_forumrecommend | repair | warning  | Number of rows changed from 193 to 192 |
| bbs.forum_forumrecommend | repair | status   | OK                                     |
+-----------------------------+--------+----------+----------------------------------------+
2 rows in set (0.01 sec)

mysql> check table forum_forumrecommend;
+-----------------------------+-------+----------+----------+
| Table                       | Op    | Msg_type | Msg_text |
+-----------------------------+-------+----------+----------+
| bbs.forum_forumrecommend | check | status   | OK       |
+-----------------------------+-------+----------+----------+
1 row in set (0.00 sec)
```

## 再次追查

看message，时间和上述问题比较吻合，因此可能是系统oom killer杀掉mysqld进程导致上述问题。

```
[root@localhost log]# grep -i "out of mem" messages* |grep mysqld
messages-20150705:Jun 29 04:21:21 localhost kernel: Out of memory: Kill process 14957 (mysqld) score 118 or sacrifice child
messages-20150705:Jun 29 04:29:02 localhost kernel: Out of memory: Kill process 4169 (mysqld) score 35 or sacrifice child
messages-20150705:Jun 29 21:17:52 localhost kernel: Out of memory: Kill process 5172 (mysqld) score 78 or sacrifice child
messages-20150705:Jun 29 21:21:36 localhost kernel: Out of memory: Kill process 14353 (mysqld) score 32 or sacrifice child
messages-20150705:Jun 29 21:21:39 localhost kernel: Out of memory: Kill process 14567 (mysqld) score 32 or sacrifice child
messages-20150705:Jun 30 01:44:37 localhost kernel: Out of memory: Kill process 15232 (mysqld) score 74 or sacrifice child
messages-20150705:Jul  1 00:11:28 localhost kernel: Out of memory: Kill process 31564 (mysqld) score 90 or sacrifice child
messages-20150705:Jul  1 17:32:53 localhost kernel: Out of memory: Kill process 9870 (mysqld) score 86 or sacrifice child
messages-20150712:Jul  7 01:23:53 localhost kernel: Out of memory: Kill process 18756 (mysqld) score 91 or sacrifice child
messages-20150712:Jul  7 01:23:54 localhost kernel: Out of memory: Kill process 3854 (mysqld) score 91 or sacrifice child
messages-20150712:Jul 11 01:06:10 localhost kernel: Out of memory: Kill process 4237 (mysqld) score 110 or sacrifice child
messages-20150712:Jul 11 01:06:10 localhost kernel: Out of memory: Kill process 16005 (mysqld) score 110 or sacrifice child
messages-20150719:Jul 13 10:19:33 localhost kernel: Out of memory: Kill process 16306 (mysqld) score 121 or sacrifice child
messages-20150726:Jul 22 21:58:46 localhost kernel: Out of memory: Kill process 29585 (mysqld) score 107 or sacrifice child
messages-20150726:Jul 22 22:12:49 localhost kernel: Out of memory: Kill process 10021 (mysqld) score 50 or sacrifice child
messages-20150726:Jul 24 16:51:24 localhost kernel: Out of memory: Kill process 12025 (mysqld) score 95 or sacrifice child
messages-20150726:Jul 24 16:51:24 localhost kernel: Out of memory: Kill process 21597 (mysqld) score 95 or sacrifice child
```


## 参考资料

```
[1]. http://blog.sina.com.cn/s/blog_4550f3ca0100x7kf.html
[2]. http://blog.csdn.net/hjue/article/details/1957256
```
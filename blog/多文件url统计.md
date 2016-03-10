# 多文件URL统计

来源于一道面试题，有多个文件格式如下：

```
http://www.annhe.net 3
```

即第一列为url，第二列为count，要求统计多个文件中url的总的count及url出现的位置。

## php实现

```
<?php
/**
 * Usage:
 * File Name: count_url_sogou.php
 * Author: annhe  
 * Mail: i@annhe.net
 * Created Time: 2015-08-27 01:11:25
 **/


$url = array();
for($i=1;$i<$argc;$i++) {
	$filename = $argv[$i];
	
	if(file_exists($filename)) {
		$arr = file($filename);
		$n_arr[$filename] = array();
		foreach($arr as $k => $v) {
			$tmp = explode(" ", $v);
			if(array_key_exists('1', $tmp)) {
				$n_arr[$filename]["$tmp[0]"] = trim($tmp[1]);
				array_push($url, $tmp[0]);
			}
		}
	}
}

$url = array_unique($url);
print_r($url);

$count = array();
foreach($url as $k => $v) {
	$sum = 0;
	$location = array();
	for($i=1;$i<$argc;$i++) {
		$filename = $argv[$i];
		if(array_key_exists("$v", $n_arr[$filename])) {
			$sum += $n_arr[$filename][$v];
			array_push($location, $filename);
		}
	}
	$str_location = implode(",", $location);
	$tmp = array('url' => $v, 'count' => $sum, 'location' => $str_location);
	array_push($count, $tmp);
}

print_r($count);
```


结果：

```
[root@HADOOP-215 sogou]# php count_url_sogou.php a.txt b.txt c.txt 
Array
(
    [0] => http://baidu.com
    [1] => http://tecbbs.com
    [2] => http://annhe.net
    [3] => http://qq.com
    [4] => http://bb.com
    [5] => http://www.baidu.com
    [6] => http://www.360.cn
    [7] => http://stu.baidu.com
    [8] => http://www.google.com
    [15] => http://shiyanlou.com
    [17] => http://aliyun.com
    [18] => http://sina.com
)
Array
(
    [0] => Array
        (
            [url] => http://baidu.com
            [count] => 6
            [location] => a.txt,c.txt
        )

    [1] => Array
        (
            [url] => http://tecbbs.com
            [count] => 8
            [location] => a.txt,c.txt
        )

    [2] => Array
        (
            [url] => http://annhe.net
            [count] => 14
            [location] => a.txt,c.txt
        )

    [3] => Array
        (
            [url] => http://qq.com
            [count] => 342
            [location] => a.txt,b.txt,c.txt
        )

    [4] => Array
        (
            [url] => http://bb.com
            [count] => 324
            [location] => a.txt,c.txt
        )

    [5] => Array
        (
            [url] => http://www.baidu.com
            [count] => 3
            [location] => b.txt
        )

    [6] => Array
        (
            [url] => http://www.360.cn
            [count] => 4
            [location] => b.txt
        )

    [7] => Array
        (
            [url] => http://stu.baidu.com
            [count] => 7
            [location] => b.txt
        )

    [8] => Array
        (
            [url] => http://www.google.com
            [count] => 12
            [location] => b.txt,c.txt
        )

    [9] => Array
        (
            [url] => http://shiyanlou.com
            [count] => 22
            [location] => c.txt
        )

    [10] => Array
        (
            [url] => http://aliyun.com
            [count] => 56
            [location] => c.txt
        )

    [11] => Array
        (
            [url] => http://sina.com
            [count] => 7
            [location] => c.txt
        )

)
```


抽样验证：

```
[root@HADOOP-215 sogou]# for id in http://tecbbs.com http://qq.com http://baidu.com ;do cat *.txt |grep -w $id |awk '{sum+=$2}END{print sum}';done 
8
342
6
```

可以看到结果正确

## shell实现

```
#!/bin/bash

#-----------------------------------------------------------
# Usage: 多文件ul统计
# $Id: count_url_sogou.sh  i@annhe.net  2015-08-27 02:40:30 $
#-----------------------------------------------------------
argc=$#
[ $argc -lt 1 ] && exit 1

argv=()
for ((i=0;i<$argc;i++));do
	argv[$i]=$1
	shift
done


echo > tmp
for ((i=0;i<$argc;i++));do
	filename=${argv[$i]}
	[ ! -f $filename ] && exit 1
	cat $filename | sed '/^$/d' | awk '{print $1" ""'$filename'"}' >> tmp
done

cat tmp |awk '{print $1}' |sort |uniq |sed '/^$/d'> tmp2 
for url in `cat tmp2`;do
	location=`grep -w $url tmp |awk '{print $2}'`
	location=`echo $location | tr -s ' ' ','`
	cat ${argv[*]} | grep -w $url |awk '{sum+=$2}END{print $1" "sum" ""'$location'"}'
done
```

结果：

```
[root@HADOOP-215 sogou]# ./count_url_sogou.sh a.txt b.txt c.txt 
http://aliyun.com 56 c.txt
http://annhe.net 14 a.txt,c.txt
http://baidu.com 6 a.txt,c.txt
http://bb.com 324 a.txt,c.txt
http://qq.com 342 a.txt,b.txt,c.txt
http://shiyanlou.com 22 c.txt
http://sina.com 7 c.txt
http://stu.baidu.com 7 b.txt
http://tecbbs.com 8 a.txt,c.txt
http://www.360.cn 4 b.txt
http://www.baidu.com 3 b.txt
http://www.google.com 12 b.txt,c.txt
```

和php的执行结果一致

## awk

```
[root@HADOOP-215 sogou]# awk '/^.+$/{a[$1]+=$2;file[$1]=FILENAME","file[$1]}END{for (i in a){print i,a[i],file[i]}}' a.txt b.txt c.txt
http://shiyanlou.com 22 c.txt,
http://tecbbs.com 8 c.txt,a.txt,
http://www.360.cn 4 b.txt,
http://sina.com 7 c.txt,
http://www.baidu.com 3 b.txt,
http://annhe.net 14 c.txt,a.txt,
http://baidu.com 6 c.txt,a.txt,
http://www.google.com 12 c.txt,b.txt,
http://stu.baidu.com 7 b.txt,
http://bb.com 324 c.txt,a.txt,
http://qq.com 342 c.txt,b.txt,a.txt,
http://aliyun.com 56 c.txt,
```

顺便说一下，这道题本来是考awk的，不会，于是用shell写，吭哧吭哧半天写出个不怎么完善的，在让用php写，没百度Google都下不了手，于是面试就华丽丽的挂了。。

## 参考资料

```
[1]. php5 array函数. http://www.w3school.com.cn/php/php_ref_array.asp
[2]. php5 string函数. http://www.w3school.com.cn/php/php_ref_string.asp
[3]. php5 filesystem函数. http://www.w3school.com.cn/php/php_ref_filesystem.asp
[4]. awk数组处理两个文件的例子. http://www.360doc.com/content/10/1229/15/3818039_82334835.shtml
```
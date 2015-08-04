# Python2 print不换行

##
上一次[猎豹面试](http://www.annhe.net/article-3368.html)的一道题，shell或者Python打印

```
0
0 1
0 1 2
0 1 2 3
0 1 2 3 4
0 1 2 3 4 5
```

回来总结时用的是Python3，今天面试又提起这个，并且直接电脑上写代码，环境是Python2，print不换行就遇到问题了。。

当时想的是help(print)看一下，结果报语法错误

```
[root@HADOOP-215 interview]# python2.6 
Python 2.6.6 (r266:84292, Jan 22 2014, 09:42:36) 
[GCC 4.4.7 20120313 (Red Hat 4.4.7-4)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> help(print)
  File "<stdin>", line 1
    help(print)
             ^
SyntaxError: invalid syntax

```

原因是[1]

> help是一个内置函数，所谓内置函数，就是在Python中被自动加载的函数，任何时候都可以用。参数分两种：  
> 
- 如果传一个字符串做参数的话，它会自动搜索以这个字符串命名的模块，方法，等。
- 如果传入的是一个对象，就会显示这个对象的类型的帮助。
> 
> 比如输入help(’print’)，它就会寻找以’print’为名的模块，类，等，找不到就会看到提示信息。而print在python里是一个保留字，和pass,return同等，而非对象，所以help(print)也会出错((kkkkkkk))。

查看帮助，不换行 `ends with a comma`

```
>>> help('print')
...
A ``'\n'`` character is written at the end, unless the ``print``
statement ends with a comma.  This is the only action if the statement
contains just the keyword ``print``.
...
```

Python3的print帮助

```
[root@HADOOP-215 interview]# python
Python 3.4.3 (default, Jul  1 2015, 16:14:34) 
[GCC 4.4.7 20120313 (Red Hat 4.4.7-11)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> type(print)
<class 'builtin_function_or_method'>   # Python3 中print是个函数，因此可以直接help(print)

>>> help(print)

Help on built-in function print in module builtins:

print(...)
    print(value, ..., sep=' ', end='\n', file=sys.stdout, flush=False)
    
    Prints the values to a stream, or to sys.stdout by default.
    Optional keyword arguments:
    file:  a file-like object (stream); defaults to the current sys.stdout.
    sep:   string inserted between values, default a space.
    end:   string appended after the last value, default a newline.
    flush: whether to forcibly flush the stream.

```

附代码

```
#!/usr/bin/env python2.6
# -*- coding:utf-8 -*-

#-----------------------------------------------------------
# Usage: use python2
# $Id: baidu.py  i@annhe.net  2015-08-03 17:56:10 $
#-----------------------------------------------------------

#输出如下形式的数字
# 0
# 0 1
# 0 1 2
# ...
# 现场使用Python2


def func1(x):
	for i in range(x):
		for j in range(i+1):
			print j,
		print ''

def func2(x):
	list = []
	for i in range(x):
		list.append(str(i))
		print ' '.join(list)

n = input("input a number: ")
print "Func1 %s" % n
func1(n)

print "\n\nFunc2 %s" % n
func2(n)
```

执行：

```
[root@HADOOP-215 interview]# ./baidu.py 
input a number: 7          
Func1 7
0 
0 1 
0 1 2 
0 1 2 3 
0 1 2 3 4 
0 1 2 3 4 5 
0 1 2 3 4 5 6 


Func2 7
0
0 1
0 1 2
0 1 2 3
0 1 2 3 4
0 1 2 3 4 5
0 1 2 3 4 5 6
```

## 参考资料

```
[1]. http://www.blogjava.net/shaofan/archive/2007/06/05/122036.html
```
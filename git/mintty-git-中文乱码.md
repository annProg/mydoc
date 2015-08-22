# git mintty中文乱码

## 环境

MinGW+msys+mintty，msys配置过中文显示与输入，详见[此文](http://www.annhe.net/article-1407.html)。

mintty配置为默认编码，ls等命令正常显示

```
$ ls linux/
ansible  iptables笔记.md  linux系统监控工具.md  salt
essay    linux系统监控工具.html   nagios    shell
```

## git on mintty

安装git后，将git bin目录加入环境变量，直接在mintty中使用git。中文会显示为Unicode码

```
$ git status -s
AM "git/mintty-git-\344\270\255\346\226\207\344\271\261\347\240\201.md"
```

参考网上文章，设置quotepath值为false：

```
[i18n]
	logoutputencoding = gbk
[core]
	quotepath = false
```

之后显示为utf-8

```
$ git status -s
AM git/mintty-git-涓枃涔辩爜.md
```

如果将mintty编码设置为utf-8，则git status显示正常，但是ls等命令会乱码，因此考虑将git status输出结果用 `iconv` 转换为gbk。

## alias设置

编辑 `/etc/profile` ，添加alias设置：

```
alias gitstat="git status |iconv -f utf-8 -t gbk"
alias gitadd="git add -A |iconv -f utf-8 -t gbk"
```

效果：

```
$ gitstat
On branch master
Your branch is up-to-date with 'origin/master'.

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        new file:   git/mintty-git-中文乱码.md

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   git/mintty-git-中文乱码.md
```

还可以直接写脚本放在 /bin/ 目录下完成类似操作。




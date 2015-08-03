# ansible学习记录

## 配置ssh密钥登录

expect脚本

```
#!/usr/bin/expect -f

set ip [lindex $argv 0]
set user [lindex $argv 1]
set passwd [lindex $argv 2]

set timeout 10

spawn ssh-copy-id -i /root/.ssh/id_rsa.pub $user@$ip

expect {
	"*password:" {send "$passwd\r"}
	"*yes/no*" {send "yes\r"}
}

expect off
```

shell调用expect脚本

```
#!/bin/bash

while read id;do
	ip=`echo $id | awk '{print $1}'`
	user=`echo $id | awk '{print $2}'`
	passwd=`echo $id | awk '{print $3}'`
	./copy-key.exp $ip $user $passwd
done <host.list
```

host.list格式

```
192.168.60.152 root root
192.168.60.155 root root
192.168.60.156 root root
192.168.60.110 root root
192.168.60.111 root root
192.168.60.100 root root
```

## 虚拟机同步时间
暂时使用脚本，后期可用crontab实现

```
#!/bin/bash
cmd="ntpdate -u time.windows.com"
cmd2="hwclock -w"
ansible annhe -m command -a "$cmd"
ansible annhe -m command -a "$cmd2"
ansible annhe -m command -a "date"
```

## 利用ansible更改salt master

```
#!/bin/bash
[ $# -lt 2 ] && echo "args error" && exit 1
oldmaster="192.168.60.10"
newmaster="192.168.60.100"
group=$1
saltgroup=$2
salt-key -d "$saltgroup"

ansible $group -m command -a "cp /etc/salt/minion /etc/salt/minion.bak"
ansible $group -m command -a "sed -i 's/$oldmaster/$newmaster/g' /etc/salt/minion"
ansible $group -m command -a "rm -f /etc/salt/pki/minion/minion_master.pub"
ansible $group -m command -a "/etc/init.d/salt-minion restart"
ansible $group -m command -a "/etc/init.d/salt-minion status"
ansible $group -m command -a "tail /var/log/salt/minion"
```

## copy文件
用ansible copy设置软件源的脚本并执行

```
ansible hadoop -m copy -a "src=/srv/salt/repo.sh dest=/tmp/repo.sh owner=root group=root mode=0755"
ansible hadoop -m command -a "ls -l /tmp/repo.sh"
ansible hadoop -m command -a "/tmp/repo.sh"
```

repo.sh用于设置软件源

```
#!/bin/bash

yumdir="/etc/yum.repos.d"
epel="$yumdir/epel.repo"
backup="$yumdir/backup"

[ ! -d $backup ] && mkdir $backup
mv -f $yumdir/*.repo $backup

rpm -qa |grep epel-release && rpm -e epel-release
rpm -Uvh http://mirrors.yun-idc.com/epel/6/x86_64/epel-release-6-8.noarch.rpm
#baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch
sed -i 's#download.fedoraproject.org/pub#mirrors.yun-idc.com#g' $epel
sed -i -E 's/^mirrorlist(.*)/#mirrorlist\1/g' $epel
sed -i -E 's/#baseurl(.*)/baseurl\1/g' $epel
curl -s http://mirrors.163.com/.help/CentOS6-Base-163.repo -o $yumdir/Base-163.repo
yum clean all
yum makecache
```

## ansible在Python3下的问题

开发机Python3，Python2并存，使用ansible有问题

```
[root@HADOOP-215 copy-key]# ansible all -m ping
  File "/usr/bin/ansible", line 203
    except errors.AnsibleError, e:
                              ^
SyntaxError: invalid syntax
```

查看ansible相关脚本

```
[root@HADOOP-215 copy-key]# head -n 1 /usr/bin/ansible*
==> /usr/bin/ansible <==
#!/usr/bin/python

==> /usr/bin/ansible-doc <==
#!/usr/bin/python

==> /usr/bin/ansible-galaxy <==
#!/usr/bin/python

==> /usr/bin/ansible-playbook <==
#!/usr/bin/python

==> /usr/bin/ansible-pull <==
#!/usr/bin/python

==> /usr/bin/ansible-vault <==
#!/usr/bin/python
```

替换为Python2.6

```
[root@HADOOP-215 copy-key]# sed -i 's|#!/usr/bin/python|#!/usr/bin/python2.6|g' /usr/bin/ansible
ansible           ansible-doc       ansible-galaxy    ansible-playbook  ansible-pull      ansible-vault     
[root@HADOOP-215 copy-key]# sed -i 's|#!/usr/bin/python|#!/usr/bin/python2.6|g' /usr/bin/ansible*
[root@HADOOP-215 copy-key]# head -n 1 /usr/bin/ansible*
==> /usr/bin/ansible <==
#!/usr/bin/python2.6

==> /usr/bin/ansible-doc <==
#!/usr/bin/python2.6

==> /usr/bin/ansible-galaxy <==
#!/usr/bin/python2.6

==> /usr/bin/ansible-playbook <==
#!/usr/bin/python2.6

==> /usr/bin/ansible-pull <==
#!/usr/bin/python2.6

==> /usr/bin/ansible-vault <==

```

执行成功

```
[root@HADOOP-215 copy-key]# ansible annhe -m ping
192.168.60.155 | success >> {
    "changed": false, 
    "ping": "pong"
}

192.168.60.152 | success >> {
    "changed": false, 
    "ping": "pong"
}
...
```
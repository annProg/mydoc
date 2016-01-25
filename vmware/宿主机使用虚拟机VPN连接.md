# 宿主机使用虚拟机VPN连接

## 需求
VMware虚拟机中跑Windows 7（下文称Guest），使用某客户端连接公司VPN，宿主机为Windows 10（下文称Host），未安装该VPN客户端。现需要在Guest中连接VPN，然后共享给Host使用。

## 实现

* Guest添加2块网卡，一个Host Only，一个桥接。网络编辑器中取消Host Only的DHCP功能
* Guest连接VPN
* Guest设置VPN网络适配器属性，将连接共享给Host Only网卡
* Guest的Host Only网卡IP将被设置为 192.168.131.1
* Host的VMnet1（Host Only网卡）指定一个和192.168.131.1同网段的IP
* Host管理员权限添加路由： route add 10.0.0.0 mask 255.255.255.0 192.168.137.1

## 参考资料

> So, the host has a public physical connection but it will be the private end of the ultimate configuration? The guest bridges to the host's NIC uses the available default route off the host's cabling (though the host doesn't have that route). The guest is XP, the host Linux. In this case I'd try hard to use NAT but, since the router is the guest, I'd probably use Windows ICS since it is so easy to forward on an interface of choice (the VPN one).

It will require two NICs, one for the host to guest (I'd use VMnet1 (host only) or add a host virtual adapter with no DHCP server on it) and one for the guest to physical cabling (bridged and the VPN client uses it - how it gets a routable IP to run the VPN over).

Enabling ICS on the guest for the NIC using VMnet1 will give it a static IP address (probably 192.168.0.1) and enable the DHCP server. If you disable the VMWare DHCP server on VMnet1 (or add another virtual adapter to the host, say VMnet2 and use it for the private NIC on the host) then just let it get an IP address via DHCP and ICS will assign it one. With this setup the host should have only one default route, it should be through the guest, via NAT and it should be over the VPN.

I've described it a bit briefly but it is not too weird or complicated.

Message was edited by:
        dmair
https://communities.vmware.com/thread/27120?start=0&tstart=0
	
> https://communities.vmware.com/thread/208756?start=0&tstart=0


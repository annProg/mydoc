# ������ʹ�������VPN����

## ����
VMware���������Windows 7�����ĳ�Guest����ʹ��ĳ�ͻ������ӹ�˾VPN��������ΪWindows 10�����ĳ�Host����δ��װ��VPN�ͻ��ˡ�����Ҫ��Guest������VPN��Ȼ�����Hostʹ�á�

## ʵ��

* Guest���2��������һ��Host Only��һ���Žӡ�����༭����ȡ��Host Only��DHCP����
* Guest����VPN
* Guest����VPN�������������ԣ������ӹ����Host Only����
* Guest��Host Only����IP��������Ϊ 192.168.131.1
* Host��VMnet1��Host Only������ָ��һ����192.168.131.1ͬ���ε�IP
* Host����ԱȨ�����·�ɣ� route add 10.0.0.0 mask 255.255.255.0 192.168.137.1

## �ο�����

> So, the host has a public physical connection but it will be the private end of the ultimate configuration? The guest bridges to the host's NIC uses the available default route off the host's cabling (though the host doesn't have that route). The guest is XP, the host Linux. In this case I'd try hard to use NAT but, since the router is the guest, I'd probably use Windows ICS since it is so easy to forward on an interface of choice (the VPN one).

It will require two NICs, one for the host to guest (I'd use VMnet1 (host only) or add a host virtual adapter with no DHCP server on it) and one for the guest to physical cabling (bridged and the VPN client uses it - how it gets a routable IP to run the VPN over).

Enabling ICS on the guest for the NIC using VMnet1 will give it a static IP address (probably 192.168.0.1) and enable the DHCP server. If you disable the VMWare DHCP server on VMnet1 (or add another virtual adapter to the host, say VMnet2 and use it for the private NIC on the host) then just let it get an IP address via DHCP and ICS will assign it one. With this setup the host should have only one default route, it should be through the guest, via NAT and it should be over the VPN.

I've described it a bit briefly but it is not too weird or complicated.

Message was edited by:
        dmair
https://communities.vmware.com/thread/27120?start=0&tstart=0
	
> https://communities.vmware.com/thread/208756?start=0&tstart=0


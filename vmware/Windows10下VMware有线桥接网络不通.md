# Windows10下VMware有线桥接网络不通

## 系统环境
Windows10， VMware Workstation 14， 网络为LAN

## 故障表现
可以获取IP地址及网关，但是无法ping通网关。使用WLAN则可以正常ping通网关

## 解决方案
1. 使用NAT，但是NAT下无法使用traceroute
2. 使用以下变通方案：

> Hell ya - Thanks BruceXiongBruceXiong that worked for me.
> 
> In laymen's terms...
> 
> Steps:
1. Open Virtual Network Editor \
2. Add Network "VMnet*" \
3. Choose "Host only", NOT "Bridged" \
4. Check Connect a host virtual adapter to this network \
5. Make DHCP unchecked \
- no need to write down the Subnet IP as it will be bridged to your physical adapter anyways. \
6. Open Windows Network panel \
6. Choose "VMware Network Adapter VMnet*" and your physical network card, right click, choose "Bridge" - How to Create a Network Bridge in Windows \
7 - YouTube (Same process in Win10TP) \
7. Wait for a moment, you will see a "Network Bridge" adapter \
8. Configure network in VM to same subnet/gateway as your hosts ipconfig network gateway. \
pings for everyone! No need to configure IPs anywhere other than the VM. \
> 
> 
> What we get for being early adopters...

## 参考资料
```
1. [Windows 10, Workstation 10, no LAN bridge] https://communities.vmware.com/message/2483101#2483101
2. [为什么在VMWare的NAT模式下无法使用traceroute] http://blog.csdn.net/dog250/article/details/52194975
```
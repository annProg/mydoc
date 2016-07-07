# 基于iTop的CMDB设计与实现

iTop使用面向对象的方式对现实世界的资源及配置项进行建模，易于理解，同时提供一套扩展机制定义类的属性和行为，使得CMDB建模变得简单并且可依赖。完全可以重写自带的配置管理模块，以适应不同的运维环境。另外，iTop还有强大的编辑功能，高效的导入导出工具，直观的依赖关系图，以及可以使用OQL查询语言REST/JSON接口。无论是简单的手工编辑，还是与其他系统集成，都比较出色。

## 自定义CMDB

### 类图

iTop自带的配置管理模块并不适合我所在部门的业务，因此对其进行了比较彻底的修改，修改的结果如图：

![](https://raw.githubusercontent.com/annProg/itop-extensions/master/le-itop.png)

删除了用不到的类，新增了适应本部门的类

### 属性约束
用DoCheckToWrite函数实现写入前的校验，比如下面的代码校验某些属性，保证其唯一性。还可以在写入前进行简单的校验，例如限制登录用户只能编辑自己link的Person。

```
public function DoCheckToWrite()
				{
					parent::DoCheckToWrite();
					$finalclass = $this->Get('finalclass');
					
					// friendlyname of FunctionalCI has to be unique! Currently it' not possible to define this in datamodel (xml)
					$nameSpec = MetaModel::GetNameSpec(get_class($this));
					$sFormat = preg_replace('/%[1-9]\$s/', '%s', $nameSpec['0']);
					$sArg = $nameSpec['1'];
					$oArg = array();
					
					/*
					 * 如果组成friendlyname的所有attribute都没有发生变化，那么不进行检查
					 * 如果不监听变化就进行检查，将导致对象无法更新
					 * server不适用name作为friendlyname，如果finalclass是Server，同时检查name和friendlyname
					 */
					$aChanges = $this->ListChanges();
					if($finalclass == "Server" && array_key_exists('name', $aChanges))
					{
						$sServer = $aChanges['name'];
						$oSearch = DBObjectSearch::FromOQL_AllData("SELECT Server WHERE name=:name");
						$oSet = new DBObjectSet($oSearch, array(), array('name' => $sServer));
						if ($oSet->Count() > 0)
						{
							$this->m_aCheckIssues[] = Dict::Format("Class:".$finalclass."/Error:".$finalclass."MustBeUnique", $sServer);
						}			
					}
					$isChanges = false;
					foreach($sArg as $value) {
						array_push($oArg, $this->Get($value));
						if(array_key_exists($value, $aChanges))
							$isChanges = true;
					}
					$sFunctionalCI = vsprintf("$sFormat", $oArg);
					
					if($isChanges) {
						$oSearch = DBObjectSearch::FromOQL_AllData("SELECT $finalclass WHERE friendlyname=:friendlyname");
						$oSet = new DBObjectSet($oSearch, array(), array('friendlyname' => $sFunctionalCI));
						if ($oSet->Count() > 0)
						{
							$this->m_aCheckIssues[] = Dict::Format("Class:".$finalclass."/Error:".$finalclass."MustBeUnique", $sFunctionalCI);
						}					
					}
				}
```		

### 翻译
iTop的翻译也可以作为单独的扩展添加，不需要为了更改翻译去修改不同的扩展。<https://github.com/annProg/itop-extensions/tree/master/zh-language>
		
## 单点登录
iTop集成了LDAP登录。但是很多公司用SSO。iTop可以通过扩展实现不同类型的登录方式，SSO登录实现的方式参见 <http://www.annhe.net/article-3553.html>。

## 公共接口

已经实现部分接口，github链接：<https://github.com/annProg/cmdbApi>

### 业务联系人查询
可以作为报警联系人接口，以zabbix为例，这样就不用在zabbix中维护一套用户信息，简化zabbix的配置工作量。

### 服务器用户权限查询
基于 lnkContactToFunctionalCI，查询到链接至Server的Person，此Person默认有登录及sudo权限。新建一个类用于记录临时新增的权限：

```
server_id, user_id, issudo, expiration
服务器, 用户, sudo权限, 过期时间
```

服务器上起一个定时任务去检查用户并增删本机用户权限。

## 参考资料
```
1. https://wiki.openitop.org
2. https://github.com/ec-europa/iTopApi
```
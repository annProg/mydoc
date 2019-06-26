# iTop集成SSO登录

## 基本思路
新建一个authent-sso扩展，除默认文件外在新建一个login.php用于充当sso回调url。基本流程为：用户选择SSO登录(或者系统判断用户为SSO用户，自动跳转)，跳转到SSO登录页面，登录成功后带着token返回authent-sso/login.php，login.php中调用model.authent-sso.php的CheckCredentials函数，CheckCredentials中完成用户登录校验，用户信息获取，添加用户，登录等流程。

## 代码实现

### 触发sso验证
sso登录成功后，带着token回调`login.php`，如 
```
请求sso
https://sso/login.php?next=http://cmdb/env-production/authent-sso/login.php
sso登录成功后
http://cmdb/env-production/authent-sso/login.php?token=xxxxx
```

为了在 `login.php` 触发`authent-sso`的 `CheckCredentials` 函数，需要添加一个专门用于SSO登录的账号，可以在module配置里设置，也可以定义常量。另外还需要SSO登录成功后的默认Profile及Organization：

```
define('SSOUSER','sso_login_use');
define('PROFILEID_SSOUSER',102);  //自定义profile 研发，只能编辑自己contactid的Person实例，默认使用此角色
define('ORGSSO','SSO登录用户');
```

### 登录逻辑

```
UserLeSSO::addSSOUser(SSOUSER);
$appRootUrl = UserLeSSO::getAppRootUrl();

if(isset($_SESSION['auth_user']) || !isset($_GET['token']))
{
	header("Location: $appRootUrl");
}else if(isset($_GET['token']))
{
	//需要有一个UserLeSSO类型的用户来调用 UserLeSSO 的 CheckCredentials
	if(UserRights::CheckCredentials(SSOUSER,'') === true)
	{
		header("Location: $appRootUrl");
	}else
	{
		die("Login Failed!");
	}
}else
{
	die("Access Denied");
}
```

在 `CheckCredentials` 函数里做登录校验及用户信息获取，添加用户，登录的操作：

```
public function CheckCredentials($sPassword)
{
	if(!isset($_GET['token'])) {
		self::getM_TK();
	}
	$this->token = $_GET['token'];
	
	//SSO配置
	$sCheckURL = trim(MetaModel::GetModuleSetting('authent-sso', 'check_url', 'http://localhost'));
	$sKey = trim(MetaModel::GetModuleSetting('authent-sso', 'key', 'key'));
	$sInfoURL = trim(MetaModel::GetModuleSetting('authent-sso', 'info_url', 'http://localhost'));
	//部分打码..略
	
	//验证SSO登录
	$checkSign = xxx签名算法打码

	$ch = curl_init($sCheckURL . "?$checkSign");  
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); // 获取数据返回  
	curl_setopt($ch, CURLOPT_BINARYTRANSFER, true); // 在启用 CURLOPT_RETURNTRANSFER 时候将获取数据返回  
	$checkResult = curl_exec($ch);
	$checkArr = json_decode($checkResult, true);
	
	if($checkArr['respond']['code'] == 0) {
		//获取用户信息
		//部分打码..略
		$userName = explode(xxx打码);
		$checkUserSign = xxx签名算法打码;
		
		$ch = curl_init($sInfoURL . "?$checkUserSign");  
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); // 获取数据返回  
		curl_setopt($ch, CURLOPT_BINARYTRANSFER, true); // 在启用 CURLOPT_RETURNTRANSFER 时候将获取数据返回  
		$userInfoResult = curl_exec($ch);
		$userInfoArr = json_decode($userInfoResult, true);
		$nickName = $userInfoArr['objects']['nickname'];
		
		self::addSSOUser($userName, $nickName);
		$_SESSION['auth_user'] = $userName;
		$_SESSION['login_mode'] = 'form';
		return true;
	}else
	{
		die($checkResult);
	}
	return false;
}
```

### CheckCredentials 用到的功能函数

```
private static function GetOrgID($org=ORGSSO)
{
	$sOrg = MetaModel::GetObjectByColumn("Organization",'name', $org, false);
	if(!$sOrg)
	{
		$oOrg = new Organization();
		$oOrg->Set("name", $org);
		$oOrg->DBWrite();
		return $oOrg->GetKey();
	}else
	{
		return $sOrg->GetKey();
	}
	
}

private function GetPersonID($login, $nickName="")
{
	$sEmail = $login . "@xxx.com";
	//$sPerson = MetaModel::GetObjectByColumn('Person', 'email', $sEmail,false);
	$sPerson = MetaModel::GetObjectFromOQL('SELECT Person WHERE email=:email', array('email'=>$sEmail));
	//if($login != SSOUSER)
		//die($sPerson);
	if(!$sPerson)
	{
		if($login == SSOUSER)
		{
			return 0;
		}else
		{
			$encoding = trim(MetaModel::GetConfig()->GetDBCharacterSet());
			//die($nickName);
			$first_name = mb_substr($nickName,0,1,$encoding);
			$name = mb_substr($nickName,1,4,$encoding);
			$oPerson = new Person();
			$oPerson->Set("name", $name);
			$oPerson->Set("first_name", $first_name);
			$oPerson->Set("org_id", self::GetOrgID());
			$oPerson->Set("email", $sEmail);
			$oPerson->DBWrite();
			return $oPerson->GetKey();
		}
	}
	return $sPerson->GetKey();
}

static public function addSSOUser($login, $nickName="", $profile=PROFILEID_SSOUSER)
{
	$sUser = MetaModel::GetObjectByColumn('User','login',$login,false);
	$sPersonID = self::GetPersonID($login, $nickName);
	
	if(!$sUser)
	{
		$oUser = new UserLeSSO();
		$oUser->Set("login", $login);
		$oUser->Set("language", "ZH CN");
		$oUser->Set("contactid", $sPersonID);
		
		$oProfilesSet = DBObjectSet::FromScratch('URP_UserProfile');
		$oProfile = new URP_UserProfile();
		$oProfile->Set("userlogin",$login);
		$oProfile->Set("profileid",$profile);
		$oProfilesSet->AddObject($oProfile);
		
		$oUser->Set('profile_list', $oProfilesSet);
		$oUser->DBWrite();
	}else
	{
		$currentID = $sUser->Get("contactid");
		//if($login != SSOUSER)
			//die($sUser);
			//die($currentID . " " . $sPersonID);
		if($currentID != $sPersonID)
		{
			$sUser->Set("contactid", $sPersonID);
			$sUser->DBWrite();
		}
	}
}

static public function getAppRootUrl()
{
	return trim(MetaModel::GetConfig()->Get('app_root_url')) . "pages/UI.php";
}

static private function getM_TK()
{
	$sAppRootUrl = trim(MetaModel::GetConfig()->Get('app_root_url'));
	$loginPage = "env-production/authent-sso/login.php";
	$sLoginURL = trim(MetaModel::GetModuleSetting('authent-sso', 'login_url', 'http://localhost'));

	header("Location: ". $sLoginURL . "?next=" . $sAppRootUrl . $loginPage);
}
```


## iTop配置

为了保留多种类型的用户，不强制跳转到SSO登录页，因此需要在iTop登录页醒目的标明 如 ”SSO用户点此登录“ 的链接，可以通过语言文件实现：

```
'UI:Login:IdentifyYourself' => '<a href="https://sso/login.php?next=http://cmdb/env-production/authent-sso/login.php"><span style="color:red;font-size:18px">SSO用户点此登录</font></a>',
```

## 优化登录
2016.7.20更新

由于绝大多数用户都通过sso登录，因此决定未认证用户之间重定向至sso以提高用户体验。只需要在model.authent-sso.php中class定义的外面判断是否登录，未登录的跳转去sso（注意请求uri为toolkit和setup时不要跳转到sso，否则将导致这两个功能不可用）。

```
//cron任务忽略sso认证
if(isset($_SERVER['REQUEST_URI']))
{
	//如果访问 toolkit 或者 setup 等工具页面，则不跳转到sso
	$isToolPage = false;
	if(preg_match('/^\/toolkit\/|^\/webservices\/|^\/setup\//i',$_SERVER['REQUEST_URI']))
	{
		$isToolPage = true;
	}
	if(!isset($_SESSION['auth_user']) && !$isToolPage)
	{
		UserLeSSO::getM_TK(base64_encode($_SERVER['REQUEST_URI']));
	}
}
```

其中参数 `$_SERVER['REQUEST_URI']` 用于认证通过后重定向至登录前的链接。具体流程为记录用户登录前打开的`request_uri`, 作为url参数加到sso的next URL里，然后login.php就可以获取到这个uri，认证成功后直接重定向至该request_uri。

`getM_TK()`函数修改为：

```
static public function getM_TK($uri="")
{
	$sAppRootUrl = trim(MetaModel::GetConfig()->Get('app_root_url'));
	$loginPage = "env-production/authent-sso/login.php";
	$sLoginURL = trim(MetaModel::GetModuleSetting('authent-sso', 'login_url', 'http://localhost'));
	$next = $sAppRootUrl . $loginPage . "?uri=" . $uri;
	
	header("Location: ". $sLoginURL . "?next=" . $next);
}
```

接下来在login中处理

```
$appRootUrl = UserLeSSO::getAppRootUrl(false);
....
....

if(UserRights::CheckCredentials(SSOUSER,'') === true)
{
	$location = $appRootUrl . base64_decode($_GET['uri']);
	header("Location: $location");
}
```

为了取到不带URI的app_root_url，`getAppRootUrl()`函数修改为：

```
static public function getAppRootUrl($with_uri=true)
{
	if($with_uri)
	{
		return trim(MetaModel::GetConfig()->Get('app_root_url')) . "pages/UI.php";
	}
	else
	{
		$root_url = trim(MetaModel::GetConfig()->Get('app_root_url'));
		return preg_replace("/\/$/","",$root_url);
	}
}
```

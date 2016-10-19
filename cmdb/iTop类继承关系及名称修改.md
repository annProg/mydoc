# iTop类继承关系及名称修改

## 场景

一开始规划不好，Database继承自FunctionalCI，由于自建数据库会使用某个Server，还有一个lnkDatabaseToServer类。后来又有了管理消息队列的需求，跟Database很类似，也需要lnk到Server，为了减少代码重复，考虑新增一个抽象类Middleware，Database及MessageQueue都从Middleware派生。并修改lnkDatabaseToServer为lnkMiddlewareToServer。

## 修改步骤
1. 定义新类，并修改Database的继承关系
2. 修改lnkDatabaseToServer为lnkMiddlewareToServer，注意数据表名称也需要修改，并且Server中的_list名称及impact关系也需要改
3. 修改数据库

## 数据库修改
一开始想先导出数据，更新完数据模型在导入，但是考虑到有很多Database和工单以及ApplicationSolution有链接，导出导入会很麻烦。因此采用直接修改数据库的方法。

由于Database改为继承Middleware并且所有的fields移到Middleware去定义，所以database表可以直接重命名为middleware表：

```
rename table itop_v1_database to itop_v1_middleware;
```

lnkdatabasetoserver表可以改列名之后重命名。

然后toolkit更新数据模型，会自动新建database表，这时候database表数据为空，需要导入原来的id

```
insert into itop_v1_database(id) select id from itop_v1_middleware;
``` 

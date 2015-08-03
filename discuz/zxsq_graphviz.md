GraphViz for Discuz!实现了在Discuz!论坛将dot源码渲染为图形。graphviz是贝尔实验室开发的一个开源的工具包，它使用一个特定的DSL(领域特定 语言):dot作为脚本语言，然后使用布局引擎来解析此脚本，并完成自动布局。可以用于程序结构图、流程图、网络图、数据结构图、UML图、状态机图等。

## 插件信息

| -------- | -------- |
| 插件名称 | Graphviz for Discuz! |
| 插件ID | zxsq_graphviz |
| 插件功能 | 在Discuz!论坛使用Graphviz |
| 插件URL | <http://addon.discuz.com/?@zxsq_graphviz.plugin> |
| 支持网站 | <http://graphviz.tecbbs.com> |

## 使用方法
本插件不提供编辑器按钮，请直接输入代码

```
[gv] put your dot code here [/gv]

gv接受一个参数，表示dot解析引擎，可选引擎：dot,neato,fdp,sfdp,twopi,circo
如 [gv=neato]put your dot code here[/gv] 表示用neato引擎画无向图

不带参数时，默认解析引擎为 dot
即 [gv] [/gv] 等同于 [gv=dot] [/gv]
```

## 插件截图


## 补充说明
本插件默认使用的 自建Graphviz API （http://api.annhe.net/gv/api.php）  和Google Graphviz API代理（http://api.annhe.net/gv/chart.php）， 不保证该API的可用性 ，但是提供搭建API的方法，详见

API搭建对比

| API | 中文支持 | 搭建最低条件 |
| ----- | -----| ----| 
| 自建API | 是 | 需要服务器（VPS，云主机等） |
| Google API代理 | 否 | 需要国外虚拟主机 |

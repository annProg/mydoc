# [原创]选择Python科学计算发行版
最近重装Python，看了一下Python科学计算发行版，打算多玩一下数据处理和数值计算。

Python用于科学计算的一些常用工具和库
------------------------------------

------------------------------------------------------------------------

-   IPython-增强的交互环境：支持变量自动补全，自动缩进，支持 bash shell
    命令，内置了许多很有用的功能和函数
-   Spyder、Wing IDE或Eclipse/Pydev：集成开发环境
-   NumPy-数学计算基础库：N维数组、线性代数计算、傅立叶变换、随机数等。
-   SciPy-数值计算库：线性代数、拟合与优化、插值、数值积分、稀疏矩阵、图像处理、统计等。
-   SymPy-符号运算
-   Pandas-数据分析库：数据导入、整理、处理、分析等。
-   matplotlib-会图库：绘制二维图形和图表
-   Chaco-交互式图表
-   OpenCV-计算机视觉库
-   TVTK-数据的三维可视化
-   Cython-Python转C的编译器：编写高效运算扩展库的首选工具
-   BioPython-生物科学

  

Python科学计算发行版
--------------------

------------------------------------------------------------------------

-   [Python(x,y)](https://code.google.com/p/pythonxy/)  
     当前最新版本:2.7.6.1 (05/30/2014)<span
    style="font-size: 13.63636302948px; line-height: 19.0909080505371px;">，支持Windows和Python2.7.6</span>。  

    [其库索引](https://code.google.com/p/pythonxy/wiki/StandardPlugins)列出了所支持的170+Python27库。
-   [WinPython](http://winpython.sourceforge.net/)  
     当前最新版本:2.7.6.4和3.3.5.0
    (04/2014)，支持Windows和Python2.7.6、3.3.5。  

    [其库索引](http://sourceforge.net/p/winpython/wiki/PackageIndex_27/)列出了所支持的60+Python27库。  

    [其库索引](http://sourceforge.net/p/winpython/wiki/PackageIndex_33/)列出了所支持的60+Python33库。
-   [Enthought Canopy（Enthought Python
    Distribution）](https://store.enthought.com/)  
     当前最新版本:1.4.1 (06/11/2014)，支持Linux, Windows,
    Mac平台和Python2.7.6。  

    [其库索引](https://www.enthought.com/products/canopy/package-index/)列出了所支持的150+测试过的Python库。
-   [Anaconda](https://store.continuum.io/cshop/anaconda/)  
     当前最新版本:2.0.1 (06/12/2014)，支持Linux, Windows,
    Mac平台和Python 2.6、2.7、3.3、3.4。  

    [其库索引](http://docs.continuum.io/anaconda/pkg-docs.html)列出了所支持的195+流行Python库。

  

[Sage](http://sagemath.org/)不是Python发行版，而是一个由Python和Cython实现的开源数学软件系统，将很多已有的（C
、C++、Fortran和Python编写的）数学软件包集成到一个通用接口（记事本文档接口和IPython命令行界面），用户只需了解Python，就可以通过接口或包装器(wrapper)使用NumPy、SciPy、matplotlib、Sympy、Maxima、GAP、
FLINT、R和其他已有软件包（具体信息见[组件列表](http://www.sagemath.org/links-components.html)），完成代数、组合数学、计算数学和微积分等计算。其最初的目标是创造一个“Magma、Maple、Mathematica和MATLAB的开源替代品”。当前最新版本:6.3
(08/10/2014)，支持Linux, Windows, Mac平台和Python2.x。

  

我的选择和推荐
--------------

------------------------------------------------------------------------

Python(x,y)和WinPython都是开源项目，其项目负责人都是Pierre
Raybaut。按Pierre自己的说法是“WinPython不是试图取替Python(x,y)，而是出于不同动机和理念：更灵活、易于维护、可移动、对操作系统侵略性更小，但是用户友好性更差、包更少、没有同Windows资源管理器集成。”。[参考1](http://blog.csdn.net/rumswell/article/details/8927603)<span
style="font-size: 13.63636302948px; line-height: 19.0909080505371px;">里面说Python(x,y)不是很稳定，此外看它目前的更新不是很频繁，确实有可能Pierre后来的工作重心放在WinPython上了。</span>

  

Canopy和Anaconda是公司推的，带免费版和商业版/插件。这两款发行版也牵扯到一个人，那就是[Travis
Oliphant](/in/teoliphant)。Travis是SciPy的原始作者，同时也是NumPy的贡献者。Travis在2008年以副总裁身份加入Enthought，2012年以总裁的身份离开，创立了一个新公司continuum.io，并推出了Python的科学计算平台Anaconda。Anaconda相对Canopy支持Python的版本更多，对Python新版本支持跟的很紧（[Sage](http://sagemath.org/)不支持Python3.x的理由是因为其依赖的SciPy还不支持Python3，而Anaconda却实现了支持Python3.3和3.4，这就说明问题了），此外其在Linux平台下（通过conda管理）安装更方便。  
  

不言而喻，我最后选择了安装科学计算发行版Anaconda:)  
  
参考
----

------------------------------------------------------------------------

1.  [目前比较流行的Python科学计算发行版](http://blog.csdn.net/rumswell/article/details/8927603)
2.  《Python科学计算》 清华大学出版社
3.  [Re-packaged
    Python](http://blog.csdn.net/stereohomology/article/details/19750083)
4.  [Scientific computing with
    Python](http://www.scientificpython.net/index.html)


## 原文
http://blog.sina.com.cn/s/blog_72ef7bea0101imaj.html

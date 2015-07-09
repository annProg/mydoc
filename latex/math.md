# MathJax公式总结

## 基本用法
### 行内公式

```
$math$或 \(math\)
$f(x) = 3x + 7$ 和 \(f(x) = 3x + 7\) 效果是一样的  
```

### 跨行公式
```
\[math\] 或  $$math$$
```

## 字符  
普通字符在数学公式中含义一样，除了 \# \$ \% \& \~ \_ \^ \{ \}；
若要在数学环境中表示这些符号，需要分别表示为\\# \\$ \\% \\& \\_ \\{ \\}，即在个字符前加上\\。

## 上标和下标  
用 ^ 来表示上标，用 \_ 来表示下标，看一简单例子：

```
$$\sum_{i=1}^n a_i=0$$  
$$f(x)=x^{x^x}$$
```
效果:
$$\sum_{i=1}^n a_i=0$$  
$$f(x)=x^{x^x}$$

这里有更多的[LaTeX上标下标的设置](http://blog.sina.com.cn/s/blog_5e16f1770100fs7f.html)

## 希腊字母  

```
$$\alpha　A　\beta　B　\gamma　\Gamma　\delta　\Delta　\epsilon　E \\\\
\varepsilon　　\zeta　Z　\eta　H　\theta　\Theta　\vartheta \\\\
\iota　I　\kappa　K　\lambda　\Lambda　\mu　M　\nu　N \\\\
\xi　\Xi　o　O　\pi　\Pi　\varpi　　\rho　P \\\\
\varrho　　\sigma　\Sigma　\varsigma　　\tau　T　\upsilon　\Upsilon \\\\
\phi　\Phi　\varphi　　\chi　X　\psi　\Psi　\omega　\Omega $$
```
效果：
$$\alpha　A　\beta　B　\gamma　\Gamma　\delta　\Delta　\epsilon　E \\\\
\varepsilon　　\zeta　Z　\eta　H　\theta　\Theta　\vartheta \\\\
\iota　I　\kappa　K　\lambda　\Lambda　\mu　M　\nu　N \\\\
\xi　\Xi　o　O　\pi　\Pi　\varpi　　\rho　P \\\\
\varrho　　\sigma　\Sigma　\varsigma　　\tau　T　\upsilon　\Upsilon \\\\
\phi　\Phi　\varphi　　\chi　X　\psi　\Psi　\omega　\Omega $$

## 分数及开方
 
```
$$\frac{1}{4}$$
表示开平方:$$\sqrt{x^4}$$
表示开 n 次方: $$\sqrt[4]{(a+b)^4}$$
```

效果：
$$\frac{1}{4}$$
表示开平方:$$\sqrt{x^4}$$
表示开 n 次方: $$\sqrt[4]{(a+b)^4}$$

##矢量

```
$$\vec{a} \cdot \vec{b}=0$$
```
效果：
$$\vec{a} \cdot \vec{b}=0$$

## 累乘

```
$$\prod_{i=0}^n \frac{1}{i^2}$$
```
$$\prod_{i=0}^n \frac{1}{i^2}$$

## 省略号（3个点）  
\ldots 表示跟文本底线对齐的省略号；\cdots表示跟文本中线对齐的省略号，

比如：
```
$$f(x\_1,x\_x,\ldots,x\_n) = x\_1^2 + x\_2^2 + \cdots + x\_n^2$$
```

效果：
$$f(x_1,x_x,\ldots,x_n) = x_1^2 + x_2^2 + \cdots + x_n^2$$

## 括号和分隔符  
() 和 [ ] 和 ｜ 对应于自己；  
{} 对应于 \{ \}；  
|| 对应于 \|。  
当要显示大号的括号或分隔符时，要对应用 \left 和 \right，如：

```
$$\[f(x,y,z) = 3y^2 z \left( 3 + \frac{7x+5}{1 + y^2}\right).\]$$
```

效果：
$$f(x,y,z) = 3y^2z \left( 3 + \frac{7x+5}{1 + y^2}\right)$$

\left. 和 \right. 只用与匹配，本身是不显示的，比如，要输出：  

则用 $$\left.\frac{du}{dx} \right|_{x=0}$$


## 多行的数学公式  
```
$$
\begin{eqnarray*}
\cos 2\theta & = & \cos^2 \theta - \sin^2 \theta \\\\
& = & 2 \cos^2 \theta - 1.
\end{eqnarray*}
$$
```
效果：
$$
\begin{eqnarray*}
\cos 2\theta & = & \cos^2 \theta - \sin^2 \theta \\\\
& = & 2 \cos^2 \theta - 1.
\end{eqnarray*}
$$

其中&是对其点，表示在此对齐。  
\*使latex不自动显示序号，如果想让latex自动标上序号，则把\*去掉


## 矩阵
```
The characteristic polynomial $\chi(\lambda)$ of the $3 \times 3$~matrix  
$$ 
\left( \begin{array}{ccc}  
a & b & c \\\\
d & e & f \\\\
g & h & i \end{array} \right)
$$
is given by the formula
$$
\chi(\lambda) = \left| \begin{array}{ccc}  
\lambda - a & -b & -c \\\\
-d & \lambda - e & -f \\\\
-g & -h & \lambda - i \end{array} \right|.
$$
```
The characteristic polynomial $\chi(\lambda)$ of the $3 \times 3$~matrix  
$$ 
\left( \begin{array}{ccc}  
a & b & c \\\\
d & e & f \\\\
g & h & i \end{array} \right)
$$
is given by the formula
$$
\chi(\lambda) = \left| \begin{array}{ccc}  
\lambda - a & -b & -c \\\\
-d & \lambda - e & -f \\\\
-g & -h & \lambda - i \end{array} \right|.
$$

c表示向中对齐，l表示向左对齐，r表示向右对齐。  


## 导数(Derivatives)

```
$\frac{du}{dt} $ and $\frac{d^2 u}{dx^2}$
```

效果：$\frac{du}{dt} $ and $\frac{d^2 u}{dx^2}$

respectively. The mathematical symbol $\partial$ is produced using \partial.

```
$$\frac{\partial u}{\partial t}  
= h^2 \left( \frac{\partial^2 u}{\partial x^2}  
+ \frac{\partial^2 u}{\partial y^2}  
+ \frac{\partial^2 u}{\partial z^2}\right)$$
```
效果：
$$\frac{\partial u}{\partial t}  
= h^2 \left( \frac{\partial^2 u}{\partial x^2}  
+ \frac{\partial^2 u}{\partial y^2}  
+ \frac{\partial^2 u}{\partial z^2}\right)$$

## 极限(Limits)
```
$$\lim_{x \to +\infty}, \inf_{x > s} , \sup_K$$
$$ \lim_{x \to 0} \frac{3x^2 +7x^3}{x^2 +5x^4} = 3.$$
```
效果：

$$\lim_{x \to +\infty}, \inf_{x > s} , \sup_K$$
$$ \lim_{x \to 0} \frac{3x^2 +7x^3}{x^2 +5x^4} = 3.$$

## 求和（Sum）

```
$$\sum_{i=1}^{2n}.$$
$$\sum_{k=1}^n k^2 = \frac{1}{2} n (n+1).$$
```
效果：
$$\sum_{i=1}^{2n}.$$
$$\sum_{k=1}^n k^2 = \frac{1}{2} n (n+1).$$

## 积分（Integrals）

```
$$\int_a^b f(x)\,dx.$$
```
效果：
$$\int_a^b f(x)\,dx.$$

The integral sign is typeset using the control sequence \int, and the
limits of integration (in this case a and b are treated as a subscript and a superscript on the integral sign.  

Most integrals occurring in mathematical documents begin with an
integral sign and contain one or more instances of d followed by another (Latin or Greek) letter, as in dx, dy and dt. To obtain the correct appearance one should put extra space before the d, using \\,. 

```
$$ \int_0^{+\infty} x^n e^{_x} \,dx = n!.$$  
$$ \int \cos \theta \,d\theta = \sin \theta.$$  
$$ \int_{x^2 + y^2 \leq R^2} f(x,y)\,dx\,dy  = \int_{\theta=0}^{2\pi} \int_{r=0}^R  
f(r\cos\theta,r\sin\theta) r\,dr\,d\theta.$$
$$ \int_0^R \frac{2x\,dx}{1+x^2} = \log(1+R^2).$$
```

效果：
$$ \int_0^{+\infty} x^n e^{_x} \,dx = n!.$$  

$$ \int \cos \theta \,d\theta = \sin \theta.$$  

$$ \int_{x^2 + y^2 \leq R^2} f(x,y)\,dx\,dy  = \int_{\theta=0}^{2\pi} \int_{r=0}^R  
f(r\cos\theta,r\sin\theta) r\,dr\,d\theta.$$

$$ \int_0^R \frac{2x\,dx}{1+x^2} = \log(1+R^2).$$

In some multiple integrals (i.e., integrals containing more than one
integral sign) one finds that LaTeX puts too much space between the
integral signs. The way to improve the appearance of of the integral is to use the control sequence \\! to remove a thin strip of unwanted
space. 

## 特殊字符
### 关系运算符
$\pm$：\\pm

$\times$：\\times

$\div$：\\div

$\mid$：\\mid

$\nmid$：\\nmid

$\cdot$：\\cdot

$\circ$：\\circ

$\ast$：\\ast

$\bigodot$：\\bigodot

$\bigotimes$：\\bigotimes

$\bigoplus$：\\bigoplus

$\leq$：\\leq

$\geq$：\\geq

$\neq$：\\neq

$\approx$：\\approx

$\equiv$：\\equiv

$\sum$：\\sum

$\prod$：\\prod

$\coprod$：\\coprod


### 集合运算符
$\emptyset$：\\emptyset

$\in$：\\in

$\notin$：\\notin

$\subset$：\\subset

$\supset$：\\supset

$\subseteq$：\\subseteq

$\supseteq$：\\supseteq

$\bigcap$：\\bigcap

$\bigcup$：\\bigcup

$\bigvee$：\\bigvee

$\bigwedge$：\\bigwedge

$\biguplus$：\\biguplus

$\bigsqcup$：\\bigsqcup


### 对数运算符
$\log$：\\log

$\lg$：\\lg

$\ln$：\\ln


### 三角运算符
$\bot$：\\bot

$\angle$：\\angle

30∘：30^$\circ$：\\circ

$\sin$：\\sin

$\cos$：\\cos

$\tan$：\\tan

$\cot$：\\cot

$\sec$：\\sec

$\csc$：\\csc


### 微积分运算符
$\prime$：\\prime

$\int$：\\int

$\iint$：\\iint

$\iiint$：\\iiint

$\iiiint$：\\iiiint

$\oint$：\\oint

$\lim$：\\lim

$\infty$：\\infty

$\nabla$：\\nabla


### 逻辑运算符
$\because$：\\because

$\therefore$：\\therefore

$\forall$：\\forall

$\exists$：\\exists

$\not=$：\\not=

$\not>$：\\not>

$\not\subset$：\\not\subset


### 戴帽符号
$\hat{y}$：\\hat{y}

$\check{y}$：\\check{y}

$\breve{y}$：\\breve{y}


### 连线符号
$\overline{a+b+c+d}$：\\overline{a+b+c+d}

$\underline{a+b+c+d}$：\\underline{a+b+c+d}

$\overbrace{a+\underbrace{b+c}_{1.0}+d}^{2.0}$：\\overbrace{a+\underbrace{b+c}_{1.0}+d}^{2.0}


### 箭头符号
$\uparrow$：\\uparrow

$\downarrow$：\\downarrow

$\Uparrow$：\\Uparrow

$\Downarrow$：\\Downarrow

$\rightarrow$：\\rightarrow

$\leftarrow$：\\leftarrow

$\Rightarrow$：\\Rightarrow

$\Leftarrow$：\\Leftarrow

$\longrightarrow$：\\longrightarrow

$\longleftarrow$：\\longleftarrow

$\Longrightarrow$：\\Longrightarrow

$\Longleftarrow$：\\Longleftarrow



## 已知问题

** 由于和discuz代码冲突，下文discuz代码均加了反斜杠 **

## Discuz代码冲突

discuz可视化编辑器会自动给链接加bbcode代码，由此会带来一些问题

- 可视化编辑器会识别图片，将图片链接加上\[img\]标签，将链接加\[url\]标签
- 纯文本会将所有链接加\[url\]（不区分图片）

插件已经对此做了处理，保证输出不会有问题。但是再次编辑帖子时看到的链接被discuz加了bbcode。

建议在后台设置默认编辑器为纯文本编辑器，以减少错误。还可以考虑禁用img, audio, flash等标签

更彻底的解决办法，可以修改discuz源代码来解决

### url相关标签
编辑 `static/js/common.js` ，找到 `parseurl` 函数

```
//str = str.replace(/([^>=\]"'\/]|^)....部分略..=\?%\-&~`@':+!]*)+\.(swf|flv))/ig, '$1\[flash\]$2\[\/flash\]');
//str = str.replace(/([^>=\]"'\/]|^)....(+[\w\.\/=\?%\-&~`@':+!]*)+\.(mp3|wma))/ig, '$1\[audio\]$2\[\/audio\]');
//str = str.replace(/([^>=\]"'\/@]|^)((((https?|ftp|gopher|ed2k|thunder|qqdl|synacast):....' : '$1\[url\]$2\[\/url\]');
//str = str.replace(/([^\w>=\]"'\/@]|^)((www\.)([\w\-]+\.)....' : '$1\[url\]$2\[\/url\]');
//str = str.replace(/([^\w->=\]:"'\.\/]|^)(([\-\.\w]+@[\.\-\w]... '$1\[email\]$2\[\/email\]');
````

### img标签
img标签可以通过后台禁用img标签来解决，但是这样会造成img标签发的图片变成一个链接。

修改源码 `static/js/forum.js` 及 `static/js/bbcode.js`，查找 `\[img\]` ，注释掉有 `replace` 函数的行

forum.js

```
theform.message.value = theform.message.value; //.replace(/([^>=\]"'\/]|^)((((https?|ftp):\/\/)|www\.)([\w\-]+\.)*[\w\-\u4e00-
\u9fa5]+\.([\.a-zA-Z0-9]+|\u4E2D\u56FD|\u7F51\u7EDC|\u516C\u53F8)((\?|\/|:)+[\w\.\/=\?%\-&~`@':+!]*)+\.(jpg|gif|png|bmp))/ig, '$1\[img\]$2\[\/img\]');
```

bbcode.js，有两处

```
//str = str.replace(/([^>=\]"'\/]|^)((((https?|ftp):\/\/)|www\.)([\w\-]+\.)*[\w\-\u4e00-\u9fa5]+\.([\.a-zA-Z0-9]+|\u4E2
D\u56FD|\u7F51\u7EDC|\u516C\u53F8)((\?|\/|:)+[\w\.\/=\?%\-&~`@':+!]*)+\.(jpg|gif|png|bmp))/ig, '$1\[img\]$2\[\/img\]');
````

## 表情冲突
建议修改默认的表情代码，或者直接关闭
# iTop导出中文PDF

iTop版本2.2.1，默认状态下导出PDF中文字符会显示为方框。解决方法为

1. 为tcpdf增加支持UTF-8 Unicode的字体（例如[droidsansfallback](https://sourceforge.net/projects/hawebs/files/Assistance/PHP/)）。也可以使用lib/tcpdf/tools目录下的`tcpdf_addfont.php`脚本来生成字体
2. 标题正常显示中文：`sed -i 's/dejavusans/droidsansfallback/g' application/pdfpage.class.inc.php`
3. impact图正常显示中文：`sed -i 's/dejavusans/droidsansfallback/g' core/displayablegraph.class.inc.php`
4. 列表中文正常显示: `sed -i 's/dejavusans/droidsansfallback/g' pages/ajax.render.php`

## 参考资料
```
1. https://sourceforge.net/p/itop/discussion/922361/thread/86dac901/
```
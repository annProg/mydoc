#!/bin/bash
#抓取文章，生成markdown

[ $# -lt 1 ] && echo "./getpost.sh url ofilename" && exit 1
tmp=tmp
[ ! -d tmp ] && mkdir tmp

url=$1

function BlogSina()
{
	url=$1
	start="articalContent"
	end="class=\"shareUp"
	title="titName\ SG_txta"
	file=`date +%s`
	file=$tmp/post-$file.html
	curl -s $url -o $file
	title=`grep "$title" $file |awk -F '[>|<]' '{print $3}' |sed 's/\&nbsp;/-/g' | sed 's/\&amp;/\&/g'`
	ofile="`echo $title | iconv -f utf-8 -t gbk`.md"
	title="# $title"
	sed -i -n "/$start/,/$end/p" $file
	sed -i '1d;$d' $file
	
	pandoc $file -o "$ofile" -t markdown_strict
	sed -i "1 i $title" $ofile
	sed -i '$ a ## 原文' $ofile
	sed -i "\$ a $url" $ofile
}

function Douban()
{
	url=$1
	start="note-header\ note-header-container"
	end="class=\"note-ft\""
	file=`date +%s`
	file=$tmp/post-$file.html
	curl -s $url -o $file
	title=`sed -n '/<title>/,/<\/title>/p' $file |sed '1d;$d' |tr -d ' '`
	ofile="`echo $title | iconv -f utf-8 -t gbk`.md"
	title="# $title"
	sed -i -n "/$start/,/$end/p" $file
	sed -i '1d;$d' $file
	
	pandoc $file -o "$ofile" -t markdown_strict
	#sed -i "1 i $title" $ofile
	sed -i '$ a ## 原文' $ofile
	sed -i "\$ a $url" $ofile
}

domain=`echo $url |awk -F '/' '{print $3}'`

case $domain in
	www.douban.com) Douban $url ;;
	blog.sina.com.cn) BlogSina $url ;;
	*) ;;
esac

rm -f $tmp/*
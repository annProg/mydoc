#!/bin/bash
#抓取文章，生成markdown

[ $# -lt 1 ] && echo "./getpost.sh url ofilename" && exit 1
tmp=tmp
[ ! -d tmp ] && mkdir tmp

url=$1
file=`date +%s`
file=$tmp/post-$file.html

function Pandoc()
{
	ofile="`echo $title | iconv -f utf-8 -t gbk`.md"
	title="# $title"
	sed -i -n "/$start/,/$end/p" $file
	sed -i '1d;$d' $file
	
	pandoc $file -o "$ofile" -t markdown_strict
	sed -i '$ a ## 原文' $ofile
	sed -i "\$ a $url" $ofile
}

function BlogSina()
{
	start="articalContent"
	end="class=\"shareUp"
	title="titName\ SG_txta"
	curl -s $url -o $file
	title=`grep "$title" $file |awk -F '[>|<]' '{print $3}' |sed 's/\&nbsp;/-/g' | sed 's/\&amp;/\&/g'`
	
	Pandoc
	sed -i "1 i $title" $ofile
	
}

function Douban()
{
	start="note-header\ note-header-container"
	end="class=\"note-ft\""
	curl -s $url -o $file
	title=`sed -n '/<title>/,/<\/title>/p' $file |sed '1d;$d' |tr -d ' '`
	
	Pandoc
}

function SegmentFault()
{
	start="class=\"article\ fmt\""
	end="taglist--inline\ pull-left"
	curl -s $url -o $file
	title=`grep articleTitle $file | awk -F '[>|<]' '{print $5}' |tr -d ' '`
	
	Pandoc
	sed -i "1 i $title" $ofile
}

domain=`echo $url |awk -F '/' '{print $3}'`

case $domain in
	www.douban.com) Douban ;;
	blog.sina.com.cn) BlogSina ;;
	segmentfault.com) SegmentFault ;;
	*) ;;
esac

rm -f $tmp/*

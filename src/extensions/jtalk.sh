#!/bin/bash
## male
HV=/usr/share/hts-voice/nitech-jp-atr503-m001
## female
# HV=/root/src/jtalk_mei/MMDAgent_Example-1.3.1/Voice/mei_happy
 
tempfile="/tmp/$1.wav"
echo $tempfile
option="-td $HV/tree-dur.inf \
  -tf $HV/tree-lf0.inf \
  -tm $HV/tree-mgc.inf \
  -md $HV/dur.pdf \
  -mf $HV/lf0.pdf \
  -mm $HV/mgc.pdf \
  -dm $HV/mgc.win1 \
  -dm $HV/mgc.win2 \
  -dm $HV/mgc.win3 \
  -df $HV/lf0.win1 \
  -df $HV/lf0.win2 \
  -df $HV/lf0.win3 \
  -dl $HV/lpf.win1 \
  -ef $HV/tree-gv-lf0.inf \
  -em $HV/tree-gv-mgc.inf \
  -cf $HV/gv-lf0.pdf \
  -cm $HV/gv-mgc.pdf \
  -k $HV/gv-switch.inf \
  -s 16000 \
  -p 75 \
  -a 0.03 \
  -u 0.0 \
  -jm 1.0 \
  -jf 1.0 \
  -jl 1.0 \
  -x /var/lib/mecab/dic/open-jtalk/naist-jdic \
  -ow $tempfile"
 
if [ -z "$1" ] ; then
  open_jtalk $option
else 
  if [ -f "$1" ] ; then
    open_jtalk $option $1
  elif [ ! -f "$tempfile" ] ; then
    echo "$1" | open_jtalk $option
  fi
fi
 
aplay -q "$tempfile"
rm $tempfile

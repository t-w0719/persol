#!/bin/bash
## male
#HV=/usr/share/hts-voice/nitech-jp-atr503-m001
## female
# HV=/root/src/jtalk_mei/MMDAgent_Example-1.3.1/Voice/mei_happy
#HV=/usr/share/hts-voice/mei
echo $1 
tempfile=/tmp/$1.wav
echo $tempfile
echo "$1" | open_jtalk \
-m /usr/share/hts-voice/mei/mei_normal.htsvoice \
-x /var/lib/mecab/dic/open-jtalk/naist-jdic \
-ow $tempfile && \ 
aplay --quiet $tempfile
rm -f $tempfile

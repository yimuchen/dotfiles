#!/bin/sh

alias -- imgbrowse='find . -name '\''*.pdf'\'' -o -name '\''*.png'\'' -o -name '\''*.jpg'\'' | fzf --preview '\''fzf_img_preview {}'\'' --preview-window=right,65%'

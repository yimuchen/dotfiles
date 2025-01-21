#!/bin/bash

function _pdf_to_png() {
  $NIX_EXEC_GS -sDEVICE=png256 -o %stdout -r144 -dBATCH -dNOPAUSE -dQUIET "$1"
}

function _icat() {
  $NIX_EXEC_KITTEN icat "$@"
}

function fzf_img_preview() {
  file=$1
  type=$(file --brief --dereference --mime -- $file)
  realpath_msg="Full path: [$(realpath $file)]"
  dim=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}
  if [[ ! "$type" =~ image/ ]]; then
    if [[ "$type" =~ "application/pdf" ]]; then
      echo $realpath_msg
      _pdf_to_png $file | _icat --clear --transfer-mode=stream --unicode-placeholder --place="$dim@0x0" | sed '$d' | sed $'$s/$/\e[m/'
      exit
    elif [[ "$type" =~ =binary ]]; then
      echo "Omitting binary file preview"
      echo $realpath_msg
      file "$1"
      exit
    fi
    cat "$file"
    exit
  else
    echo "$realpath_msg"
    _icat --clear --transfer-mode=stream --unicode-placeholder --stdin=no --place="$dim@0x0" $file | sed '$d' | sed $'$s/$/\e[m/'
  fi
}

alias -- imgbrowse='find . -name '\''*.pdf'\'' -o -name '\''*.png'\'' -o -name '\''*.jpg'\'' | fzf --preview '\''fzf_img_preview {}'\'' --preview-window=right,65%'

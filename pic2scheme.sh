pic2swatch() {
  fname=$1
  if [[ -z "$fname" ]]; then
    echo "usage: pic2swatch <filename> [<number of colors>]"
    return
  fi
  ncolors=$2
  if [[ -z "$ncolors" ]]; then
    ncolors=16
  fi

  ts=$(date +%s)
  tempfname="temp_$ts""_""$RANDOM"
  i=0
  convert "$fname" +dither -colors 16 "$tempfname.png"
  identify -verbose "$tempfname.png" | awk '
    p == 1 && $0 !~ /^ *[0-9]+:/ {
      p = 0;
    }

    p == 1 {
      print $1, $3;
    }

    / *Histogram: *$/ {
      p = 1;
    }
  ' | sed 's/://g' | sort -h | awk '{print $2;}' |\
  while read -r line; do
    convert -size 64x64 canvas:"$line" "$tempfname""_swatch_$i.png"
    ((i++))
    echo $line
  done

  montage *_swatch_*.png -tile 8x -geometry +0+0 "swatch$ts.png"

  rm "$tempfname"_swatch_*.png
  rm "$tempfname.png"
}

pic2scheme() {
  tempts=$(date +%s)
  tempoutputname="temp_$tempts""_""$RANDOM.txt"
  pic2swatch $1 > "$tempoutputname"
  ruby rel_lum.rb "$tempoutputname" > "contrast_$tempts.csv"
  rm "$tempoutputname"
}

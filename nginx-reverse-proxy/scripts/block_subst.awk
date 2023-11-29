#! /usr/bin/env -S awk -f
#
NR==FNR {
    rec[++numLines] = $0
    next
}

s = index($0, block) {
    indent = sprintf("%*s",s-1,"")
    for (lineNr=1; lineNr<=numLines; lineNr++) {
        print indent rec[lineNr]
    }
    next
}

{ print }

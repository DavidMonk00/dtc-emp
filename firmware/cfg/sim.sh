#!/bin/bash
f="../src/l1tf/common/firmware/hdl/trackerGeometry.vhd"
#old="constant dtcId: natural := 0"
old=$(sed -n '11p' < $f)
for iDTC in `seq 0 215`;
#for iDTC in `seq 0 0`;
do
    new="constant dtcId: natural := "$iDTC";"
    sed -i s/"$old"/"$new"/ $f
    n="FEDTC_"$iDTC
    rm -rf $n
    sed -n '11p' < $f
    ipbb proj create sim $n dtc: -t 'sim.dep' &> tmp
    #ipbb proj create sim $n dtc: -t 'sim.dep'
    cd $n
    ipbb sim make-project &> tmp
    #ipbb sim make-project
    cd ..
    sed -i s/"$new"/"$old"/ $f
done
rm tmp

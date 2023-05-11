#! /bin/bash
subDwiPath=derivatives/sfprep/sub-BNU888/dwi
numOfdwi=`find $subDwiPath -name *_dwi.mif | wc -l`
if [ $numOfdwi -gt 1 ]
then
    echo "More than a run."
    # singularity exec $SIMGMRTRIX3 mrcat $subDwiPath/*.mif $subDwiPath/dwi.mif
else
    # only have one run of dwi
    echo "Only a run."
    for i in `find $subDwiPath -name *_dwi.mif`
    do
        echo $i
        # cp $i $subDwiPath/dwi.mif
    done
fi
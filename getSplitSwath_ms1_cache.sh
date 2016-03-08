#!/bin/bash

[ $# -eq 0 ] && echo "usage: $0 file (with 2cloumns samplename newname)" && exit 1

cat $1 | while read line
do
	samplename=$(echo $line|awk '{print $1}')
	newname=$(echo $line|awk '{print $2}')

	bsub -q pub.8h -n 2 -R "rusage[getdata=2,scratch=10000]" <<EOF
set -e
trap "echo JOB $samplename FAILED; exit 1" EXIT

echo JOB $samplename STARTED
samplecode=\$(searchms -m $samplename)
getdataset -v -o /cluster/scratch_xl/shareholder/imsb_ra/datasets -r /dev/null \$samplecode
mzXML_to_swathmzMLgz.sh -i /cluster/scratch_xl/shareholder/imsb_ra/datasets/\$samplecode/*.gz -o \$TMPDIR -t 2

if [ "$newname" != "" ]
then
	mv \$TMPDIR/split_*_ms1scan.mzML.gz \$TMPDIR/${newname}_ms1.mzML.gz
	[ ! -d "$newname" ] && mkdir "$newname"
	cp -v \$TMPDIR/*_ms1.mzML.gz ./$newname
	gunzip ./$newname/*.gz
else
	cp -v \$TMPDIR/*.mzML.gz ./
fi

trap - EXIT
echo JOB $samplename SUCESSFULLY FINISHED
EOF

done

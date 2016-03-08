#!/bin/bash

[ $# -eq 0 ] && echo "usage: $0 file (with 2cloumns samplename newname)" && exit 1

cat $1 | while read line
do
	samplename=$(echo $line|awk '{print $1}')
	newname=$(echo $line|awk '{print $2}')

	bsub -q pub.8h -n 8 -R "rusage[getdata=2,scratch=10000]" <<EOF
set -e
trap "echo JOB $samplename FAILED" EXIT

echo JOB $samplename STARTED
getdataset -v \$(searchms -m $samplename) -o \$TMPDIR -r /dev/null
mzXML_to_swathmzMLgz.sh -i \$TMPDIR/*/*.gz -o \$TMPDIR -t 8

trap - EXIT
echo JOB $samplename SUCESSFULLY FINISHED
EOF

done

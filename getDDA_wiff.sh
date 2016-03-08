#!/bin/bash

[ $# -eq 0 ] && echo "usage: $0 file (with 2cloumns samplename newname)" && exit 1

cat $1 | while read line
do
	samplename=$(echo $line|awk '{print $1}')
	newname=$(echo $line|awk '{print $2}')

	bsub -R "rusage[scratch=5000]" <<EOF
set -e
trap "echo JOB $samplename FAILED" EXIT

echo JOB $samplename STARTED
getmsdata -v \$(searchms -r $samplename) -o \$TMPDIR -r /dev/null

if [ "$newname" != "" ]
then
	mv -v \$(ls \$TMPDIR/*/*.wiff) $newname.wiff
else
	mv -v \$(ls \$TMPDIR/*/*.wiff) ./
fi

trap - EXIT
echo JOB $samplename SUCESSFULLY FINISHED
EOF

done
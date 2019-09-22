#! /bin/bash

outfile=vmstats.txt

while true
do
    date +%s >> ${outfile}
    docker stats --no-stream --format  "{\"container\":\"{{ .Container }}\", \"name\":\"{{ .Name }}\",\"memory\":{\"raw\":\"{{ .MemUsage }}\",\"percent\":\"{{ .MemPerc }}\"},\"cpu\":\"{{ .CPUPerc }}\",  \"network\": \"{{.NetIO}}\", \"blockio\":\"{{.BlockIO}}\"}" >> ${outfile}
    sleep 1
done   
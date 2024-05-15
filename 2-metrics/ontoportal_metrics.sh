#! /bin/bash

if [[ $# -ne 3 ]]; then
	echo "Requires 3 arguments: repoFolder metricsFolder repoPattern"
	exit 1
fi

repoFolder=$1
metricsFolder=$2
repoPattern=$3

# Verify that the folder has been provided as an argument.
if [[ ! -d ${repoFolder} ]]; then
    echo "Please provide a valid folder to read downloaded ontologies."
    exit 1
fi

if [[ ! -d ${metricsFolder} ]]; then
    echo "Please provide a valid working directory to save metrics."
    exit 1
fi


iname=("-iname" "${repoPattern}")


while read workDir;
do
 echo "workDir = ${workDir}";

 # Copy subdirectory structure from repoFolder to metricsFolder. If subdirectory in metricsFolder exists then it will be removed before it is created.
 find "${repoFolder}" -mindepth 1 -maxdepth 1 -type d "${iname[@]}" | sed -e "s?${repoFolder}?${metricsFolder}?" | while read line; do echo "${line}/output created." ;rm -r ${line} ; mkdir -p "${line}/output" ;  done

 workPath="${metricsFolder}/${workDir}"
 outputPath="${workPath}/output"
 # Output file with the ontology metric list
 metric_list="${outputPath}/metric_list.csv"
 # OQUARE Log file
 output_oquare_log="${outputPath}/output_oquare.log"
 # Huron Log file
 output_huron_log="${outputPath}/output_huron.log"

# echo "workPath=${workPath}"
# echo "outputPath=${outputPath}"
# echo "metric_list=${metric_list}"
# echo "output_oquare_log=${output_oquare_log}"
# echo "output_huron_log=${output_huron_log}"

 echo "Repository,OQUARE.xml,OQUARE.ttl,HURON_long.tsv,HURON_wide.tsv,HURON.ttl,OntologyFilename" >> ${metric_list}

 while read ontoFile;
 do

#	echo "ontoFile=${ontoFile}"
	ontoFilename=$(echo  "${ontoFile##*/}")
 	onto=$(echo "${ontoFilename}" | awk -F "__" '{print $1}' | rev | cut -d"-" -f3- | rev)
 	declare has{OquareXml,OquareTtl,HuronLongTsv,HuronWideTsv,HuronTtl}="F"

 	java -Djava.io.tmpdir=/home/jredondo/datos-jredondo/tmp  -Xmx12g -jar ./lib/oquare-versions-0.0.5.jar --ontology ${ontoFile} --outputFileXML ${workPath}/${onto}__oquare.xml --outputFileRDF ${workPath}/${onto}__oquare.ttl 2>&1 | tee -a "${output_oquare_log}"

	if $(ls  "${workPath}" | grep -q -e ^${onto}__oquare.xml); then hasOquareXml="T"; fi
	if $(ls  "${workPath}" | grep -q -e ^${onto}__oquare.ttl); then hasOquareTtl="T"; fi

	java -Djava.io.tmpdir=/home/jredondo/datos-jredondo/tmp -Xmx8g -jar ./lib/huron-0.0.6.jar --input ${ontoFile} --output-long ${workPath}/${onto}__huron_long.tsv --output-wide ${workPath}/${onto}__huron_wide.tsv --output-summary-rdf ${workPath}/${onto}__huron.ttl -t4 2>&1 | tee -a "${output_huron_log}"

	if $(ls "${workPath}" | grep -q -e ^${onto}__huron_long.tsv); then hasHuronLongTsv="T"; fi
       if $(ls "${workPath}" | grep -q -e ^${onto}__huron_wide.tsv); then hasHuronWideTsv="T"; fi
	if $(ls "${workPath}" | grep -q -e ^${onto}__huron.ttl); then hasHuronTtl="T"; fi


	echo "${workDir},${hasOquareXml},${hasOquareTtl},${hasHuronLongTsv},${hasHuronWideTsv},${hasHuronTtl},${ontoFilename}" >> ${metric_list}

 done < <(find "${repoFolder}/${workDir}" -mindepth 1 -maxdepth 1 -type f)

done < <(find "${repoFolder}" -mindepth 1 -maxdepth 1 -type d "${iname[@]}" | sed -e "s?${repoFolder}/??")

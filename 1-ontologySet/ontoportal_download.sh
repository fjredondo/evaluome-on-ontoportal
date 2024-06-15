#! /bin/bash

if [[ $# -ne 2 ]]; then
	echo "Please provide two arguments a csv file path and download folder path."
	exit 1
fi

repo_list=$1
folder=$2

# Verify that the csv file has been provided as an argument.
if [[ ! -f ${repo_list} ]]; then
    echo "Please provide the csv file as an argument with this header: Repository,APIKey."
    exit 1
fi

if [[ ! -d ${folder} ]]; then
    echo "Please provide a valid folder to download ontologies."
    exit 1
fi

# Output file with the list of ontologies
ontology_list="${folder}/ontology_list.csv"
# Download error file
download_err="${folder}/ontology_err.csv"
# Log file
output_log="${folder}/output.log"

rm -f "${ontology_list}"
rm -f "${download_err}"
rm -f "${output_log}"
{

    echo "Repository,Ontology,CreationDate,Format,Filename,Length,URL" >> ${ontology_list}
    echo "Repository,Ontology,CreationDate,Format,HTTPResponse,URL" >> ${download_err}
    IFS=, read -r -a header

    while IFS=, read -r "${header[@]}" ; do
        repo="https://${Repository}"
        auth="Authorization: apikey token=${APIKey}"
	rm -rf "${folder}/${Repository}"
	mkdir "${folder}/${Repository}"

        while read submission
	do
		ontoFormat=$(echo "$submission" | jq -r '.hasOntologyLanguage')
		proposedExtension=$(echo "$ontoFormat" | awk '{print tolower($0)}')
  		urlSub=$(echo "$submission" | jq -r '."@id"')
		creationDate=$(echo "$submission" | jq -r '.creationDate[0:10]' | sed 's/-//g')
		ontoName=$(echo "$urlSub"|cut -d '/' -f 5)
		fn=$(echo "${ontoName}-${creationDate}-${ontoFormat}" | awk '{print tolower($0)}')
		urlDownload=$(echo "$urlSub/download")
		filePath=$(echo "${folder}/${Repository}/${fn}")

		wgetOut=$(wget --server-response -q --content-disposition --trust-server-names -P "${folder}/${Repository}" --header "${auth}" "$urlDownload"  2>&1| tee -a "${output_log}" | egrep "HTTP|Length|Content-Disposition:")

		httpResponse=$(echo "${wgetOut}" | grep "HTTP/" | awk '{print $2}')
		length=$(echo "${wgetOut}" | grep "Content-Length" | awk '{print $2}')
		serverFilename=$(echo "${wgetOut}" | grep "Content-Disposition:" | tail -1 | awk -F"filename=" '{print $2}')
		serverFilename=$(echo "${serverFilename:1:-1}")
		echo "serverFilename = ${serverFilename}"
		# Remove blank, apostrophe, and replace underscore with dash in the serverFileName
		parsedFilename=$(echo "${serverFilename}" | sed s/\'// | sed s/_/-/g | tr -d ' ' | tr -d '()')
		echo "parsedFilename = ${parsedFilename}"
		#If missing add extension
		if $(echo "${parsedFilename}" | grep -q -v -e "\."); then
			parsedFilename=$(echo "${parsedFilename}.${proposedExtension}");
			echo "parsedFilenameExt = ${parsedFilename}"
		fi
		finalFilename=$(echo "${fn}__${parsedFilename}")
		echo "finalFilename = ${finalFilename}"
		echo "${folder}/${Repository}/${parsedFilename} - ${urlDownload}"

		if [ $httpResponse == "200" ]; then
			echo "${folder}/${Repository}/${serverFilename} --> ${folder}/${Repository}/${finalFilename}"
			mv "${folder}/${Repository}/${serverFilename}" "${folder}/${Repository}/${finalFilename}"
			echo "${Repository},${ontoName},${creationDate},${ontoFormat},${finalFilename},${length},${urlSub}" >> ${ontology_list}
		else
			echo "${Repository},${ontoName},${creationDate},${ontoFormat},${httpResponse},${urlSub}" >> ${download_err}
		fi


	done < <(curl --location "$repo/submissions?display=hasOntologyLanguage%2Cstatus%2CcreationDate%2Cversion%2CsubmissionId&display_links=false&display_context=false" \
               --header 'Content-Type: application/json' \
               --header 'Accept: application/json' \
               --header "$auth" | jq -c '.[] | select(.status=="production") | {hasOntologyLanguage,"@id",creationDate}')


    done
} < ${repo_list}

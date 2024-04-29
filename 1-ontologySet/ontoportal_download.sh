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

rm -f "${ontology_list}"

{

    echo "Repository,Ontology,CreationDate,Format,URL" >> ${ontology_list}
    IFS=, read -r -a header

    while IFS=, read -r "${header[@]}" ; do
        repo="https://data.${Repository}"
        auth="Authorization: apikey token=${APIKey}"
	rm -rf "${folder}/${Repository}"
	mkdir "${folder}/${Repository}"

        while read submission
	do
		ontoFormat=$(echo "$submission" | jq -r '.hasOntologyLanguage')
  		urlSub=$(echo "$submission" | jq -r '."@id"')
		creationDate=$(echo "$submission" | jq -r '.creationDate[0:10]' | sed 's/-//g')
		ontoName=$(echo "$urlSub"|cut -d '/' -f 5)
		fn=$(echo "$ontoName-$creationDate.${ontoFormat}" | awk '{print tolower($0)}')
		urlDownload=$(echo "$urlSub/download")
		filePath=$(echo "${folder}/${Repository}/${fn}")

  		echo "${folder}/${Repository} - ${filePath} - ${urlDownload}"
		echo "${Repository},${ontoName},${creationDate},${ontoFormat},${urlSub}" >> ${ontology_list}

		wget -O "${filePath}" -P "${folder}/${Repository}" --header "${auth}" "$urlDownload"

	done < <(curl --location "$repo/submissions?display=hasOntologyLanguage%2Cstatus%2CcreationDate%2Cversion%2CsubmissionId&display_links=false&display_context=false" \
               --header 'Content-Type: application/json' \
               --header 'Accept: application/json' \
               --header "$auth" | jq -c '.[] | select(.status=="production") | {hasOntologyLanguage,"@id",creationDate}')


    done
} < ${repo_list}

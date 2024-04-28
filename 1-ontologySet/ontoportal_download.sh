#! /bin/bash

{
    IFS=, read -r -a header

    while IFS=, read -r "${header[@]}" ; do
        repo="https://data.${Repository}"
        auth="Authorization: apikey token=${APIKey}"
	rm -rf "./${Repository}"
	mkdir "./${Repository}"

        while read submission
	do
		ontoFormat=$(echo "$submission" | jq -r '.hasOntologyLanguage')
  		urlSub=$(echo "$submission" | jq -r '."@id"')
		creationDate=$(echo "$submission" | jq -r '.creationDate[0:10]' | sed 's/-//g')
		ontoName=$(echo "$urlSub"|cut -d '/' -f 5)
		fn=$(echo "$ontoName-$creationDate.${ontoFormat}" | awk '{print tolower($0)}')
		urlDownload=$(echo "$urlSub/download")
		filePath=$(echo "./${Repository}/${fn}")

  		echo "$Repository - $filePath - ${urlDownload}"

		wget -O "$filePath" -P "$Repository" --header "$auth" "$urlDownload"

	done < <(curl --location "$repo/submissions?display=hasOntologyLanguage%2Cstatus%2CcreationDate%2Cversion%2CsubmissionId&display_links=false&display_context=false" \
               --header 'Content-Type: application/json' \
               --header 'Accept: application/json' \
               --header "$auth" | jq -c '.[] | select(.status=="production") | {hasOntologyLanguage,"@id",creationDate}')


    done
} < repo_list.csv

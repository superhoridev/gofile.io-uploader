#!/bin/bash

function get_best_eu_server() {
  eu_servers=$(curl -s -X GET 'https://api.gofile.io/servers' | jq -r '.data.servers[] | select(.zone == "eu").name')
  best_server=$(echo "$eu_servers" | head -n1) 
  echo "$best_server"
}

GOFILE_TOKEN="your_token"

while getopts ":f:" opt; do
  case ${opt} in
    f )
      FILES_DIR=$OPTARG
      ;;
    \ )
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    : ) 
      echo "-f requires an argument (the directory to upload)." >&2
      exit 1
      ;;
  esac
done

if [[ -z "$FILES_DIR" ]]; then
  echo "Error: You must provide a directory to upload using the -f option." >&2
  exit 1
fi

folder_id="your_folder"  

for file in "$FILES_DIR"/*; do
  if [[ -f "$file" ]]; then
    echo "Uploading $file..."

    server=$(get_best_eu_server)

    if [[ -z "$server" ]]; then
      echo "Error: Failed to get a valid EU server."
      exit 1
    fi

    upload_response=$(curl -s -X POST "https://$server.gofile.io/contents/uploadfile" \
                      -H "Authorization: Bearer $GOFILE_TOKEN" \
                      -F "file=@$file" \
                      -F "folderId=$folder_id")

    if [[ $upload_response =~ "status\":\"ok" ]]; then
        download_page=$(echo $upload_response | jq -r '.data.downloadPage')
        echo "Upload successful. Extracted Download Page: $download_page"
    else
      echo "Upload failed. Unexpected response format."
    fi

    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    if [[ -n "$download_page" ]]; then
      echo "$timestamp - Upload successful: $download_page ($file)" >> upload.log
    else
      echo "$timestamp - Upload failed. Response: $upload_response ($file)" >> upload.log
    fi
  fi
done

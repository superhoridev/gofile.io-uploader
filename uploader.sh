#!/bin/bash

function get_best_eu_server() {
  eu_servers=$(curl -s -X GET 'https://api.gofile.io/servers' | jq -r '.data.servers[] | select(.zone == "eu").name')
  best_server=$(echo "$eu_servers" | head -n1) 
  echo "$best_server"
}

GOFILE_TOKEN="your_token"  # Replace with your actual token, leave blank for anonymous account

while getopts ":f:d:" opt; do
  case ${opt} in
    f )
      FILE_TO_UPLOAD=$OPTARG
      ;;
    d )
      DIR_TO_UPLOAD=$OPTARG
      ;;
    \ )
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    : ) 
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ -n "$FILE_TO_UPLOAD" && -n "$DIR_TO_UPLOAD" ]]; then
  echo "Error: Please use either -f for a single file or -d for a directory." >&2
  exit 1
fi

if [[ -z "$FILE_TO_UPLOAD" && -z "$DIR_TO_UPLOAD" ]]; then
  echo "Error: You must provide either a file (-f) or directory (-d) to upload." >&2
  exit 1
fi

folder_id="your_folder_id"  #Replace with your folder id

function upload_file() {
  local file=$1

  echo "Uploading $file..."
  server=$(get_best_eu_server)

  if [[ -z "$server" ]]; then
    echo "Error: Failed to get a valid EU server."
    exit 1
  fi

  echo "Server Selected: $server"

  upload_response=$(curl -s -X POST "https://$server.gofile.io/contents/uploadfile" \
                    -H "Authorization: Bearer $GOFILE_TOKEN" \
                    -F "file=@$file" \
                    -F "folderId=$folder_id")

  if [[ $upload_response =~ "status\":\"ok" ]]; then
    download_page=$(echo $upload_response | jq -r '.data.downloadPage')
    echo "Upload successful. Download Page: $download_page"
  else
    echo "Upload failed. Unexpected response format."
  fi

  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  if [[ -n "$download_page" ]]; then
    echo "$timestamp - Upload successful: $download_page ($file)" >> upload.log
  else
    echo "$timestamp - Upload failed. Response: $upload_response ($file)" >> upload.log
  fi
}

function upload_directory() {
  local dir=$1

  for file in "$dir"/*; do
    if [[ -f "$file" ]]; then
      upload_file "$file"
    fi
  done
}

if [[ -n "$FILE_TO_UPLOAD" ]]; then
  if [[ -f "$FILE_TO_UPLOAD" ]]; then 
    upload_file "$FILE_TO_UPLOAD"
  else
    echo "Error: $FILE_TO_UPLOAD is not a valid file." >&2
    exit 1
  fi
elif [[ -n "$DIR_TO_UPLOAD" ]]; then
  if [[ -d "$DIR_TO_UPLOAD" ]]; then 
    upload_directory "$DIR_TO_UPLOAD"
  else 
    echo "Error: $DIR_TO_UPLOAD is not a valid directory." >&2
    exit 1
  fi
fi

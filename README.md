# GoFile.io Uploader

This is my custom made uploader, uses ``curl`` and ``jq``

> [!CAUTION]
> This is still under development and dosen't work correctly with many 

## Installation

```
sudo apt install curl jq

#I recommend in downloading it in /root or user root (For example: /home/user) directory
cd ~

#actually downloading the files and giving perms
curl -L -o uploader.sh https://raw.githubusercontent.com/superhoridev/gofile.io-uploader/main/uploader.sh
chmod +x uploader.sh
```

## Usage
> [!NOTE]
> Dosen't work fully with many file types, i recommend archiving your files into a tar.gz before uploading 

```
./uploader.sh -f /path/to/file

./uploader.sh -d /path/to/directory
```

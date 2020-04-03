# Apache and php5.6 with pdo_oci included + self signed ssl (php56-posca)

Image for running php5.6 based application with oracleDB connection and self signed SSL certificate

## Requirement

- instantclient-basic-linux.x64-11.2.0.4.0.zip, and
- instantclient-sdk-linux.x64-11.2.0.4.0.zip

You can download from this link [Oracle Instant Client For Linux x86-64](https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html)

apache php5.6 ssl pdo-oci
php56-posca

## How To Build

Download the requirements above and run
`docker build -t <your tagname> .`


## Usage

To run the container then type
`docker run -d -p 8080:80 <your image tagname>`

or if you want to attach volume you can use
`docker run -d -p 8080:80 -v $PWD/public_html:/var/www/html <your image tagname>`

then you can open browser and visit `127.0.0.1:8080`. if all going well then you will see phpinfo page.
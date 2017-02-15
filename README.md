# self-signed-server-certs-with-ca
Scripts for generating a self signed CA and self signed X509 certificates signed by the CA. Generates PEM-files, PKCS12 and JKS for multi purposes such as Java servers.

#Quick start

1. First run ./generate-ca.sh to create a root CA
2. Then run generate-server-certs-from-ca.sh with the server's common name as argument, example ./generate-server-certs-from-ca.sh test.mytrustedsite.org

#Serial numbers

All certificates generated and signed by the CA are issued a serial number based on the serial number counter stored in serialno.dat.
The serialno.dat will be created if it doesn't exist. 
If you remove the serialno.dat the counter will restart and you might get serial number collissions.

#Trust store

The ca-truststore.jks can be used for trusting all certificates generated from the ROOT CA

#More info

More about creating self signed certificates with your own self-signed CA: http://web.archive.org/web/20120509214649/http://www.tc.umn.edu/~brams006/selfsign.html


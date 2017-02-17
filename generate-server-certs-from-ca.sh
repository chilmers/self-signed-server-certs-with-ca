#!/bin/sh

# Copyright 2017 Christian Hilmersson
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ "$#" -lt 1 ]
then
	echo 'Usage: generate-server-certs-from-ca.sh [server common name]'
    echo 'Example: generate-server-certs-from-ca.sh www.chilmers.se'
else
    # Check prerequisites
    if [ ! -f "./ca.crt.pem" ] || [ ! -f "./ca.key.pem" ] ; then
        echo 'Missing required ./ca.crt.pem or ./ca.key.pem'
        echo 'First run generate-ca.sh since since the script requires the generated ca.key.pem and ca.crt.pem'
        exit -1
    fi
    
    # Create a workspace
    if [ -d "./$1" ] ; then
        echo "./$1 already exists"
        exit -1
    fi
    mkdir ./$1
        
    # Generate a server key
    echo "-- Generating Server Private Key"
    openssl genrsa -out ./$1/$1.key.pem 1024

    # Get next serial number
    # if we don't have a file, start at zero
    if [ ! -f "./serialno-counter-do-not-delete.dat" ] ; then
      value=0
    # otherwise read the value from the file
    else
      value=`cat ./serialno-counter-do-not-delete.dat`
    fi
    # increment the value
    value=`expr ${value} + 1`
    # show it to the user
    echo "serialno: ${value}"
    # and save it for next time
    echo "${value}" > ./serialno-counter-do-not-delete.dat

    # Generate a server certificate signing request
    echo "-- Generating Server Certificate Signing Request"
    openssl req -verbose -new -subj "/CN=$1/OU=IT Dept/O=Fictive Certificed Organization/ST=GBG/C=SE" -key ./$1/$1.key.pem -out ./$1/$1.csr.pem

    # Sign the certificate request with the CA
    echo "-- Signing the certificate request with the CA"
    openssl x509 -req -days 365 -in ./$1/$1.csr.pem -CA ./ca.crt.pem -CAkey ./ca.key.pem -set_serial ${value} -out ./$1/$1.crt.pem

    # Collect in PKCS12
    openssl pkcs12 -export -in ./$1/$1.crt.pem -inkey ./$1/$1.key.pem \
                   -out ./$1/$1-cert-and-key.p12 -name $1 \
                   -CAfile ./ca.crt.pem -caname root \
                   -password pass:password

    # Generate a trust store for trusting only this certificate, not all certificates issued by the ca
    keytool -importcert -alias $1 -file ./$1/$1.crt.pem -v -trustcacerts -noprompt -keystore ./$1/$1-only-not-entire-ca-truststore.jks -storepass password

    # Add PKCS12 content to JKS 
    keytool -importkeystore \
            -deststorepass password -destkeypass password -destkeystore ./$1/$1-server.jks \
            -srckeystore ./$1/$1-cert-and-key.p12 -srcstoretype PKCS12 -srcstorepass password \
            -alias $1

    ls -latr ./$1/
fi
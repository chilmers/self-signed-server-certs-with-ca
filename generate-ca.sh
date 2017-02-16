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

# Generate a non encrypted private key for the CA (add -des3 for encryption)
# Output: ca.key.pem
echo "-- Generating CA Private Key"
openssl genrsa -out ./ca.key.pem 1024

# Generate a CA cert using the CA's private key
# Output: ca.crt.pem
echo "-- Generating CA Certificate"
openssl req -verbose -new -x509 -nodes -set_serial 998877 -subj "/CN=TheCA/OU=NOT FOR PRODUCTION/O=Fictive Certification Authority/ST=GBG/C=SE" -days 7300 -key ./ca.key.pem -out ./ca.crt.pem

keytool -importcert -alias ca -file ./ca.crt.pem -v -trustcacerts -noprompt -keystore ./ca-truststore.jks -storepass password

ls -latr

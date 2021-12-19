# scomp

Script that takes a cipher name as input and outputs useful information on that cipher.

Example
<pre>
./scomp.rb AES128-SHA
</pre>

Outputs:
<pre>
code: [0x2f]
openssl_name: AES128-SHA
iana_name: TLS_RSA_WITH_AES_128_CBC_SHA
kex: RSA
enc_algo: AES
enc_algo_bits: 128
hash_algorithm: SHA
tls_version: ["TLS1.0", "TLS1.1", "TLS1.2"]
security: weak
mozilla_classification: old
</pre>

Details are gathered from the following sources:
- https://ciphersuite.info/ (through their API)
- https://ssl-config.mozilla.org/guidelines/5.6.json
- https://testssl.sh/openssl-iana.mapping.html

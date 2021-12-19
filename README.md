# scomp

Script that takes a cipher name as input and outputs useful information on that cipher.

Example
<pre>
./scomp.rb TLS_AES_128_CCM_8_SHA256
</pre>

Outputs:
<pre>
code: [0x1305]
openssl_name: TLS_AES_128_CCM_8_SHA256
iana_name: TLS_AES_128_CCM_8_SHA256
kex: ECDH
enc_algo: AESCCM8
enc_algo_bits: 128
hash_algorithm: SHA256
tls_version: ["TLS1.3"]
security: secure
mozilla_classification: modern
</pre>

Details are gathered from the following sources:
- https://ciphersuite.info/ (through their API)
- https://ssl-config.mozilla.org/guidelines/5.6.json
- https://testssl.sh/openssl-iana.mapping.html

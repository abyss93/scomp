#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'

CIPHERS_TABLE = 'https://testssl.sh/openssl-iana.mapping.html'.freeze
CODE_INDEX = 0
OPENSSL_NAME_INDEX = 1
IANA_NAME_INDEX = 5
KEX_INDEX = 2
ENC_INDEX = 3
BITS_INDEX = 4

cipher_name = ARGV[0]
ciphers = {}

ciphers_site_parsed = Nokogiri::HTML.parse(URI.open(CIPHERS_TABLE))
ciphers_rows = ciphers_site_parsed.css('tr')
ciphers_rows.to_a.filter { |row| row.css('th').empty? == true }.each do |cipher_row_parsed|
  cipher_row = cipher_row_parsed.css('td').to_a

  openssl_name = cipher_row[OPENSSL_NAME_INDEX].text.strip unless cipher_row[OPENSSL_NAME_INDEX].nil?
  iana_name = cipher_row[IANA_NAME_INDEX].text.strip unless cipher_row[IANA_NAME_INDEX].nil?
  kex = cipher_row[KEX_INDEX].text.strip unless cipher_row[KEX_INDEX].nil?
  enc_algo = cipher_row[ENC_INDEX].text.strip unless cipher_row[ENC_INDEX].nil?
  bits = cipher_row[BITS_INDEX].text.strip unless cipher_row[BITS_INDEX].nil?

  ciphers[cipher_row[CODE_INDEX].text] = {
    'openssl_name' => openssl_name,
    'iana_name' => iana_name,
    'kex' => kex,
    'enc_algo' => enc_algo,
    'bits' => bits
  }
end

match = ciphers.filter { |code, info| info['openssl_name'] == cipher_name || info['iana_name'] == cipher_name }.first
puts match unless match.nil?



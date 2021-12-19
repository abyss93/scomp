#!/usr/bin/env ruby
require 'net/http'
require 'nokogiri'
require 'json'

TESTSSL_URL = URI('https://testssl.sh/openssl-iana.mapping.html').freeze
MOZILLA_URL = 'https://ssl-config.mozilla.org/guidelines/5.6.json'.freeze
CIPHERSUITE_INFO_API_URL = 'https://ciphersuite.info/api/cs/'.freeze
CODE_INDEX = 0
OPENSSL_NAME_INDEX = 1
IANA_NAME_INDEX = 5
KEX_INDEX = 2
ENC_INDEX = 3
BITS_INDEX = 4

def get_cipher_property(cipher_detail, property_index)
  property_text = cipher_detail[property_index]
  return property_text.text.strip unless property_text.nil?

  ''
end

def display(cipher_details)
  cipher_details.each do |k, v|
    puts "#{k}: #{v}"
  end
end

cipher_name = ARGV[0]
results = {}

testssl_parsed = Nokogiri::HTML.parse(Net::HTTP.get(TESTSSL_URL))
ciphers_list = testssl_parsed.css('tr')
ciphers_list.to_a.filter { |cipher| cipher.css('th').empty? == true }.each do |cipher|
  cipher_detail = cipher.css('td').to_a

  cipher_code = get_cipher_property(cipher_detail, CODE_INDEX)
  openssl_name = get_cipher_property(cipher_detail, OPENSSL_NAME_INDEX)
  iana_name = get_cipher_property(cipher_detail, IANA_NAME_INDEX)
  kex = get_cipher_property(cipher_detail, KEX_INDEX)
  enc_algo = get_cipher_property(cipher_detail, ENC_INDEX)
  bits = get_cipher_property(cipher_detail, BITS_INDEX)

  results[cipher_code] = {
    'code' => cipher_code,
    'openssl_name' => openssl_name,
    'iana_name' => iana_name,
    'kex' => kex,
    'enc_algo' => enc_algo,
    'enc_algo_bits' => bits
  }
end

# find the searched cipher filtering the list by name
matches = results.filter { |_code, info| info['openssl_name'] == cipher_name || info['iana_name'] == cipher_name }

# enrichment from mozialla.org and ciphersuite.info
if matches != {}
  mozilla_configs = JSON.parse(Net::HTTP.get(URI(MOZILLA_URL)))

  matches.each do |_code, info|
    cipher_suite_url = "#{CIPHERSUITE_INFO_API_URL}#{info['iana_name']}/"
    cipher_info = JSON.parse(Net::HTTP.get(URI(cipher_suite_url)))
    info['hash_algorithm'] = cipher_info[info['iana_name']]['hash_algorithm']
    info['tls_version'] = cipher_info[info['iana_name']]['tls_version']
    info['security'] = cipher_info[info['iana_name']]['security']

    mozilla_configs['configurations'].each do |config_type, config_details|
      config_details['ciphers']['openssl'].each do |cipher_name|
        next unless cipher_name == info['openssl_name']
        # In case the cipher is not TLS1.3 the config is either Old or Intermediate
        info['mozilla_classification'] = config_type
        if info['tls_version'].include?('TLS1.3')
          # why? https://wiki.openssl.org/index.php/TLS1.3#Ciphersuites and https://ssl-config.mozilla.org/guidelines/5.6.json
          # TLS1.3 only supports ephemeral diffie-hellman key exchange algo: https://www.a10networks.com/blog/key-differences-between-tls-1-2-and-tls-1-3/
          # and https://blog.cloudflare.com/rfc-8446-aka-tls-1-3/
          #
          # Ciphers like TLS_AES_128_CCM_8_SHA256 and TLS_AES_128_CCM_SHA256 are supported by TLS1.3 but not considered 'modern' by Mozilla
          EXLUDED_CIPHERS = %w[TLS_AES_128_CCM_8_SHA256 TLS_AES_128_CCM_SHA256]
          info['mozilla_classification'] = 'modern' unless EXLUDED_CIPHERS.include?(info['openssl_name'])
        end
      end
      # some ciphers are considered for both Old and Intermediate configs, breaking here is considering the cipher intermediate
      break if info.key?('mozilla_classification')
    end

    display(info)
  end
end





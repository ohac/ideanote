#!/usr/bin/ruby
require 'digest/md5'
require 'json'

accounts = []
messages = {}
Dir.glob('public/*') do |fn|
  bn = File.basename(fn)
  json = File.open(fn, 'rb') do |fd|
    JSON.parse(fd.read)
  end
  secret_cur, message, fn_prev, fn_next, proof_of_work = json
  difficulty = 4
  raise fn unless Digest::MD5.hexdigest(secret_cur) == bn
  raise fn unless Digest::MD5.hexdigest(json.join('')).index('0' * difficulty) == 0
  messages[bn] = json
  accounts << bn unless fn_prev
end

accounts.each do |bn|
  puts "Account ID: %s" % bn
  json = messages[bn]
  loop do
    secret_cur, message, fn_prev, fn_next, proof_of_work = json
    fn_prev = '0' * 6 unless fn_prev
    puts "%s %s %s %s" % [bn[0, 6], fn_prev[0, 6], fn_next[0, 6], message]
    bn = fn_next
    json = messages[bn]
    break unless json
  end
end

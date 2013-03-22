#!/usr/bin/ruby
require 'digest/md5'
require 'json'

messages = {}
Dir.glob('public/*') do |fn|
  bn = File.basename(fn)
  json = File.open(fn, 'rb') do |fd|
    JSON.parse(fd.read)
  end
  secret_cur, message, fn_next, proof_of_work = json
  difficulty = 4
  raise fn unless Digest::MD5.hexdigest(secret_cur) == bn
  raise fn unless Digest::MD5.hexdigest(json.join('')).index('0' * difficulty) == 0
  messages[bn] = json
end

messages.each do |id, msg|
  puts "%s %s %s" % [id[0, 6], msg[2][0, 6], msg[1]]
end

#!/usr/bin/ruby
require 'digest/md5'
require 'json'

accounts = []
messages = {}
difficulty_min = 4
zeros = '0' * difficulty_min
Dir.glob('public/*') do |fn|
  next if fn.index('.html')
  bn = File.basename(fn)
  json = File.open(fn, 'rb') do |fd|
    JSON.parse(fd.read)
  end
  secret_cur, message, fn_prev, fn_next, difficulty_next, proof_of_work = json
  raise fn unless Digest::MD5.hexdigest(secret_cur) == bn
  messages[bn] = json
  accounts << bn unless fn_prev
end

accounts.each do |bn|
  File.open("public/#{bn}.html", 'w') do |fd|
    puts "Account ID: %s" % bn
    fd.puts "<html><head><title>#{bn}</title></head><body>"
    fd.puts "Account ID: %s<br>" % bn
    json = messages[bn]
    difficulty_next = difficulty_min
    loop do
      raise bn unless Digest::MD5.hexdigest(json.join('')).index(zeros) == 0
      secret_cur, message, fn_prev, fn_next, difficulty_next, proof_of_work = json
      fn_prev = '0' * 6 unless fn_prev
      zeros = '0' * difficulty_next
      puts "%s %s %s %s" % [bn[0, 6], fn_prev[0, 6], fn_next[0, 6], message]
      fd.puts "%s %s %s %s<br>" % [bn[0, 6], fn_prev[0, 6], fn_next[0, 6], message]
      bn = fn_next
      json = messages[bn]
      break unless json
    end
  end
end

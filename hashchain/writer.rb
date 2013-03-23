#!/usr/bin/ruby
require 'fileutils'
require 'digest/md5'
require 'json'

FileUtils.mkdir_p('public')
FileUtils.mkdir_p('secret')

prev_fn = ARGV[1]
secret_cur = nil
secret_next = nil
fn_cur = nil
fn_next = nil
if prev_fn
  prev = File.open(prev_fn, 'rb') do |fd|
    JSON.parse(fd.read)
  end
  fn_cur = prev[2]
  cur = File.open(File.join('secret', fn_cur), 'rb') do |fd|
    JSON.parse(fd.read)
  end
  secret_cur = cur[0]
else
  secret_cur = rand.to_s
  fn_cur = Digest::MD5.hexdigest(secret_cur)
end
path = File.join('public', fn_cur)
raise 'already exist' if File.exist?(path)
secret_next = rand.to_s
fn_next = Digest::MD5.hexdigest(secret_next)
message = ARGV[0] || 'no message'
message = message.to_json
json = [secret_cur, message, fn_next]
difficulty = 4
zeros = '0' * difficulty
proof_of_work = nil
loop do
  json[3] = rand.to_s
  str = Digest::MD5.hexdigest(json.join(''))
  break if str.index(zeros) == 0
end
proof_of_work = json[3]
json = [secret_cur, message, fn_next, proof_of_work]
File.open(path, 'wb') do |fd|
  fd.puts(json.to_json)
end
json = [secret_next]
File.open(File.join('secret', fn_next), 'wb') do |fd|
  fd.puts(json.to_json)
end

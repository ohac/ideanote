#!/usr/bin/ruby
require 'fileutils'
require 'digest/md5'
require 'json'

FileUtils.mkdir_p('public')
FileUtils.mkdir_p('secret')

fn_prev = nil
fn_myid = 'myid'
if File.exist?(fn_myid)
  fn_prev = File.open(fn_myid, 'rb') do |fd|
    fd.read
  end
  fn_prev = File.join('public', fn_prev.chomp)
  # TODO
  loop do
    json = File.open(fn_prev, 'rb') do |fd|
      JSON.parse(fd.read)
    end
    fn_next = json[3]
p fn_next
    break unless fn_next
    fn_next = File.join('public', fn_next)
    break unless File.exist?(fn_next)
    fn_prev = fn_next
  end
end
secret_cur = nil
secret_next = nil
fn_cur = nil
fn_next = nil
if fn_prev
  prev = File.open(fn_prev, 'rb') do |fd|
    JSON.parse(fd.read)
  end
  fn_prev = File.basename(fn_prev)
  fn_cur = prev[3]
  cur = File.open(File.join('secret', fn_cur), 'rb') do |fd|
    JSON.parse(fd.read)
  end
  secret_cur = cur[0]
else
  secret_cur = rand.to_s
  fn_cur = Digest::MD5.hexdigest(secret_cur)
  puts "Your ID is %s" % fn_cur
  File.open(fn_myid, 'wb') do |fd|
    fd.puts(fn_cur)
  end
end
path = File.join('public', fn_cur)
raise 'already exist' if File.exist?(path)
secret_next = rand.to_s
fn_next = Digest::MD5.hexdigest(secret_next)
message = ARGV[0] || 'no message'
message = message.to_json
json = [secret_cur, message, fn_prev, fn_next]
difficulty = 4
zeros = '0' * difficulty
proof_of_work = nil
loop do
  json[4] = rand.to_s
  str = Digest::MD5.hexdigest(json.join(''))
  break if str.index(zeros) == 0
end
proof_of_work = json[4]
File.open(path, 'wb') do |fd|
  fd.puts(json.to_json)
end
json = [secret_next]
File.open(File.join('secret', fn_next), 'wb') do |fd|
  fd.puts(json.to_json)
end

#!/usr/bin/ruby
def checkpointid(filename, lineno)
  filename.each_byte.inject(lineno){|a,b|a^b} & 0xff
end

def crc16(ptn)
  crc = 0
  ptn.each do |c|
    8.times do
      a = c
      a += 1 if (crc & 1) == 1
      crc >>= 1
      crc ^= 0xa001 if (a & 1) == 1
      c >>= 1
    end
  end
  crc
end

files = Dir.glob('*.c')
checkpoints = {}
files.each do |filename|
  body = File.open(filename, 'r'){|fd|fd.read}
  body.split("\n").each_with_index do |line, l|
    if /crctrace\(\);/ === line
      id = checkpointid(filename, l + 1)
      checkpoints[id] = "#{filename}:#{l + 1}:1:"
    end
  end
end

ucheckpoints = checkpoints.keys.uniq
if checkpoints.size != ucheckpoints.size
  puts 'error: not unique'
  exit
end

5.times do
  (1..6).each do |len|
    u = ucheckpoints * len
    try = ucheckpoints.size * len * 100
    try.times do
      ptn = u.take(len)
      if crc16(ptn) == 0xfbc3 # TODO
        puts "found: %s" % ptn.join(', ')
        ptn.each do |id|
          puts checkpoints[id]
        end
        exit
      end
      u.shuffle!
    end
  end
end

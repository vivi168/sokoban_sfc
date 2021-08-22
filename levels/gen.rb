#!bin/ruby

path = File.expand_path(File.dirname(__FILE__))
files = Dir.glob('level*.txt', base: path).sort

puts "default_level_count:         .db #{files.size.to_s(16).rjust(2, '0')}"
puts "level_bank:                  .db 81"

files.each do |file|
  label = File.basename(file, '.txt')

  puts "#{label}: .incbin levels/#{file}"
  puts '         .db 00'
end

puts "level_lut:"

files.each do |file|
  label = File.basename(file, '.txt')
  puts "         .db @#{label}"
end

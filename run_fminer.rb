require 'yaml'
require 'set'

ENV['FMINER_SMARTS'] = '1'
#ENV['FMINER_SILENT'] = '1'

$fminer_file=File.expand_path(File.dirname(__FILE__)) + "/fminer.rb"

begin
  require $fminer_file
rescue Exception
  puts File.new(__FILE__).path + ": file '#{$fminer_file}' not found!"
  exit false
end
$myFminer=RubyFminer.new()

# Fminer/BBRC
if ARGV.size < 3 or !File.exist?(ARGV[0])
  puts "Argument error: \"<input_file> <endpoint> <output_file>\""
  puts "      endpoint: comma-separated values in one string"
  exit 1
end

$input_file=ARGV[0]
$endpoint=ARGV[1]
$output_file=ARGV[2]

table=nil
begin
  table=read_csv($input_file)
rescue Exception=>e
  puts e.message
  puts e.backtrace
end

fsm_with_classes=true
output=$myFminer.run_fminer(table, $endpoint, {:min_freq => 4, :fsm => fsm_with_classes})

patterns=YAML::load(output)

all_smarts=Set.new
occ_smarts=Hash.new

patterns.each { |p|
  smarts=p[0]
  all_smarts = all_smarts.add smarts; 
  occ_pos=p[2]; occ_neg=p[3]
  occs = (occ_pos << occ_neg).flatten.sort
  occs.each { |o|
    if occ_smarts[o].nil?
      occ_smarts[o]=Hash.new
    end
    occ_smarts[o][smarts] = 1
  }
}

header = ["CAS"]
header << all_smarts.to_a
header.flatten!
header_str = "\"" << header.join("\",\"") << "\""

final_table = []
occ_smarts.each { |o,v|
  line=Array.new
  line << o
  (1..(header.size-1)).each {|i|
    line << (v.has_key?(header[i]) ? 1 : 0)
  } 
  final_table << line
}

csv_str = ""
final_table.each { |line|
  csv_str << line.join(',') << "\n"
}

File.open($output_file, 'w') do |f|
  f.puts header_str
  f.puts csv_str
end



require 'yaml'
require 'set'

ENV['FMINER_SMARTS'] = '1'
#ENV['FMINER_SILENT'] = '1'

$fminer_file=File.expand_path(File.dirname(__FILE__)) + "/fminer.rb"
$output_file=File.expand_path(File.dirname(__FILE__)) + "/fminer-output.csv"

begin
  require $fminer_file
rescue Exception
  puts File.new(__FILE__).path + ": file '#{$fminer_file}' not found!"
  exit false
end
$myFminer=RubyFminer.new()

# Fminer/BBRC
if ARGV.size < 2 or !File.exist?(ARGV[0])
  puts "Argument error."
  exit 1
end

$csv_file=ARGV[0]
$endpoint=ARGV[1]

table=nil
begin
  table=read_csv($csv_file)
rescue Exception=>e
  puts e.message
  puts e.backtrace
end

output=$myFminer.run_fminer(table, $endpoint,2)
#File.open($output_file,"w"){|f|f.puts output}

patterns=YAML::load(output)
puts output.class
puts output.size

all_smarts=Set.new
occ_smarts=Hash.new

patterns.each { |p|
  smarts=p[0]; all_smarts = all_smarts.add smarts; occ_pos=p[2]; occ_neg=p[3]
  occs = (occ_pos << occ_neg).flatten.sort
  occs.each { |o|
    if occ_smarts[o].nil?
      occ_smarts[o]=Hash.new
    end
    occ_smarts[o][smarts] = 1
  }
}

final_table = []
header = ["CAS"]
header << all_smarts.to_a
header.flatten!
final_table << header

occ_smarts.each { |o,v|
  line=Array.new
  line << o
  (1..(header.size-1)).each {|i|
    line << (v.has_key?(header[i]) ? 1 : 0)
  } 
  final_table << line
}

CSV.open('csvfile.csv', 'w') do |writer|
  final_table.each { |line|
    writer << line
  }
end

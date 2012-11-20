require 'yaml'
require 'set'

do_debug=false
ENV['FMINER_SMARTS'] = '1'
ENV['FMINER_SILENT'] = '1' if do_debug


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
puts "AM: table size: #{table.length}"  if do_debug 
puts



min_freq=50
fsm=true



all_cas=table.collect { |row| row["CAS"] } # collect results later: use occ-1 to access all_cas index
puts "AM: #{all_cas.join(', ')}" if do_debug 
puts "AM: #{all_cas.length}" if do_debug 
puts


output=$myFminer.run_fminer(table, $endpoint, {:min_freq => min_freq, :fsm => fsm})
patterns=YAML::load(output)
all_smarts=Set.new
occ_smarts=(1..all_cas.length).to_a.inject({}) { |h,idx|
  h[idx]=Hash.new
  h
}


puts "AM: #{occ_smarts.inspect}" if do_debug
puts "AM: #{occ_smarts.length}" if do_debug
puts

patterns.each { |p|
  smarts=p[0]
  all_smarts = all_smarts.add smarts; 
  occ_pos=p[2]; occ_neg=p[3] # Assumes only two classes
  occs = (occ_pos + occ_neg).sort
  occs.each { |o|
    occ_smarts[o.to_i][smarts] = 1
  }
}
#puts "AM: #{occ_smarts.inspect}" if do_debug

puts
puts "AM: --- #{occ_smarts[0].inspect}" if do_debug
puts "AM: #{occ_smarts[1].inspect}" if do_debug
puts "AM: #{occ_smarts[2].inspect}" if do_debug
puts "AM: --- #{occ_smarts[3].inspect}" if do_debug
puts

#puts
#puts "AM: --- #{occ_smarts[259].inspect}" if do_debug
#puts "AM: #{occ_smarts[260].inspect}" if do_debug
#puts "AM: #{occ_smarts[261].inspect}" if do_debug
#puts "AM: #{occ_smarts[262].inspect}" if do_debug
#puts "AM: --- #{occ_smarts[263].inspect}" if do_debug
#puts
#puts "AM: #{occ_smarts.length}" if do_debug
#puts


header = ["CAS"]
header << all_smarts.to_a # This will give order of features for filling table
header.flatten!
header_str = "\"" << header.join("\",\"") << "\""

final_table = []
(1..all_cas.length).to_a.each { |occ_idx|
  line=Array.new
  line<<all_cas[occ_idx-1]
  (1..(header.size-1)).each { |i|
    line << (occ_smarts[occ_idx].has_key?(header[i]) ? 1 : 0)
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



require 'yaml'

ENV['FMINER_LAZAR'] = ''
ENV['FMINER_SMARTS'] = '1'
ENV['FMINER_SILENT'] = '1'

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

output=$myFminer.run_fminer($csv_file, $endpoint,2)
File.open($output_file,"w"){|f|f.puts output}

require 'csv'

def read_csv file
  csv_data = CSV.read file
  headers = csv_data.shift.map {|i| i.to_s }
  string_data = csv_data.map {|row| row.map {|cell| cell.to_s } }
  array_of_hashes = string_data.map {|row| Hash[*headers.zip(row).flatten] }
end

#file="q_bmbf_loel_5_kreuztabelle_oral_inhalation_am.txt"
#contents=read_csv file

# re-implementation of fminer in ruby with integrated last-utils
# args: smi, class 
# TODO mode, minfreq

begin
  require File.dirname(__FILE__) + "/lib/bbrc.so"
  require File.dirname(__FILE__) + "/lib/csv.rb"
rescue
  puts "bbrc or csv library not found!"
  exit false
end

class RubyFminer

  def initialize
    @myFminer = Bbrc::Bbrc.new()
  end

  # Fminer/BBRC re-implementation in Ruby
  # @param[String] the SMI-File holding the molecules
  # @param[String] the CLASS-File holding the activities
  # @param[Integer] minimum frequency
  # @param[Boolean] aromatic perception

  def run_fminer(csv_file, endpoint, min_freq, arom=true, regr=false)
    # Adjust settings
    @myFminer.Reset
    @myFminer.SetConsoleOut(false)
    @myFminer.SetMinfreq(min_freq.to_i)
    @myFminer.SetAromatic(arom)
    @myFminer.SetRegression(regr)

    begin
      table=read_csv(csv_file)
    rescue Exception=>e
      puts e.message
      puts e.backtrace
    end

    # Read data
    smi_class_hash = {} 
    table.each { |row|
      smi_class_hash[row["SMILES"]]=row[endpoint.to_s].to_f
    }
    if table.size != smi_class_hash.size
      puts "Error reading CSV data."
      return 1
    end

    # Feed Fminer
    i=1
    smi_class_hash.each { |k,v|
      v>0 ? v=1.0 : v=0.0
      @myFminer.AddCompound(k, i)
      @myFminer.AddActivity(v, i)
      i+=1
    }

    # gather results for every root node in vector instead of immediate output
    result_str = ""
    (0 .. @myFminer.GetNoRootNodes()-1).each do |j|
      result = @myFminer.MineRoot(j)
      result.each do |res|
        result_str+=res+"\n"
      end
    end
    result_str

  end
end



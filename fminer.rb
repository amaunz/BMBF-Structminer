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
  # @param[String] CSV-File holding all structures and assays
  # @param[String] c-separated list of endpoints
  # @param[Integer] minimum frequency
  # @param[Boolean] aromatic perception

  def run_fminer(table, endpoints, min_freq=2, arom=true, regr=false)
    # Adjust settings
    @myFminer.Reset
    @myFminer.SetConsoleOut(false)
    @myFminer.SetMinfreq(min_freq.to_i)
    @myFminer.SetAromatic(arom)
    @myFminer.SetRegression(regr)

    # Read data
    smi_class_hash = {} 
    smi_cas_hash = {} 
    table.each { |row|
      cluster_endpoint=0.0
      endpoints.split(',').each { |endpoint|
        endpoint=row[endpoint].to_f
        endpoint>0 ? endpoint=1.0 : endpoint=0.0
        cluster_endpoint+=endpoint
      }
      cluster_endpoint>=endpoints.split(',').size.to_f/2 ? cluster_endpoint=1 : cluster_endpoint=0
      smi_class_hash[row["SMILES"]]=cluster_endpoint
      smi_cas_hash[row["SMILES"]]=row["CAS"].to_i
    }
    if table.size != smi_class_hash.size
      puts "Error reading CSV data."
      return 1
    end

    # Feed Fminer
    index=1
    nr_pos=0
    smi_class_hash.each { |k,v|
      if (@myFminer.AddCompound(k, smi_cas_hash[k]))
        @myFminer.AddActivity(v, smi_cas_hash[k])
        v==1.0 ? nr_pos+=1 : nr_pos=nr_pos
        index+=1
      end
    }
    puts "Balance: #{nr_pos} / #{index} = #{(100*nr_pos.to_f/index).round/100.to_f}" if (index>0)

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


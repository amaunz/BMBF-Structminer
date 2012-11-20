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
  # @param[String] endpoint

  def run_fminer(table, endpoint, options={})
    min_freq = options[:min_freq]
    fsm = options[:fsm]

    # Adjust settings
    @myFminer.Reset
    @myFminer.SetConsoleOut(false)
    @myFminer.SetMinfreq(min_freq.to_i)
    if fsm
      @myFminer.SetDynamicUpperBound(false)
      @myFminer.SetBackbone(false)
      @myFminer.SetChisqSig(0.0)
    end

    table.each_with_index { |row,idx|
      @myFminer.AddCompound(row["SMILES"],idx+1)
      @myFminer.AddActivity(row[endpoint].to_f,idx+1)
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


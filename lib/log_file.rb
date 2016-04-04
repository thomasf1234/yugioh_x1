class LogFile
  COLOUR_CODES = {
      red: 31,
      green: 32,
      yellow: 33,
  }

  def initialize(file_name="log/#{ENV['ENV']}.log")
    @file = File.new(file_name, 'a+')
  end

  def puts(message, colour=nil)
    if colour.nil?
      @file.puts "[#{DateTime.now}]" + message
    else
      @file.puts "[#{DateTime.now}]" + colorize(message, colour)
    end

    @file.flush
  end

  def close
    @file.close
  end

  private
  def colorize(string, colour=nil)
    "\e[#{COLOUR_CODES[colour]}m#{string}\e[0m"
  end
end

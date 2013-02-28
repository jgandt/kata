class ParseWeather

  attr_accessor :file, :weather_data

  def initialize(weather_file_name)
    @file = File.open( weather_file_name, 'r' )
    @weather_data = WeatherCollection.new
  end

  def file_data
    file.read.gsub(/.*<pre>.*\n\n(.*)\n( )+mo.*<\/pre>.*/m, '\1')
  end

  def parse_data
    file_data.split("\n").each do |line|
      parsed = parse_line( line )
      @weather_data << DayWeather.new( parsed[0], parsed[1], parsed[2] )
    end  
  end

  def parse_line( line )
    line.slice(0,14).split(' ').map{ |num| num.gsub(/[^0-9]+/, '')}.map(&:to_i)
  end

end

class WeatherCollection
  include Enumerable

  def initialize
    @collection_points = []
  end

  def <<(weather_obj)
    @collection_points << weather_obj
  end

  def each( &block )
    @collection_points.each{|member| block.call(member) }
  end

  def point_with_max_temperature_difference
    max{ |a,b| a.temperature_difference <=> b.temperature_difference }
  end

  def point_with_min_temperature_difference
    min{ |a,b| a.temperature_difference <=> b.temperature_difference }
  end
end

class DayWeather
  attr_accessor :number, :max_temp, :min_temp
  def initialize(init_number, init_max_temp, init_min_temp)
    @number = init_number
    @max_temp = init_max_temp
    @min_temp = init_min_temp
    validate
  end

  def temperature_difference
    @max_temp - @min_temp
  end
  
  def validate
    raise "Invalid Day Temperatures max:#{@max_temp}, min:#{@min_temp}" unless @max_temp >= @min_temp
  end
end

class Runner
  def self.run
    parser = ParseWeather.new('weather.dat')

    parser.parse_data

    weather_collection = parser.weather_data

    min_diff_point = weather_collection.point_with_min_temperature_difference
    puts "Day with minimum difference was: Day ##{min_diff_point.number} with a difference of #{min_diff_point.temperature_difference}"

    max_diff_point = weather_collection.point_with_max_temperature_difference
    puts "Day with maximum difference was: Day ##{max_diff_point.number} with a difference of #{max_diff_point.temperature_difference}"
  end
end

Runner.run if __FILE__ == $0

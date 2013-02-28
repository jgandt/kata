require 'rspec'
require './parse_weather'

describe ParseWeather do

  subject{ ParseWeather.new('weather.dat') }

  describe '#initialize' do
    it 'opens the passed in weather file' do
      File.should_receive(:open)
      subject
    end
    it 'assigns @file to an accessor' do
      subject.file.should be_kind_of File
    end
    it 'inits @data to a blank array' do
      subject.file.should be_kind_of File
    end
  end

  describe '#file_data' do
    it 'returns the data block in the file' do
      subject.file_data.should_not match /Unofficial.*Preliminary/
      subject.file_data.should_not match /AvSLP/
    end
  end

  describe '#parse_data' do
    it 'creates @data as an array of DayWeather objs' do
      subject.parse_data
      subject.weather_data.first.should be_kind_of DayWeather
    end
  end

  describe '#parse_line' do
    it 'grabs the first three numbers of a data line and returns them as an array of ints' do
      subject.parse_line('   1  5     10').should == [1,5,10]
    end
  end

end

describe WeatherCollection do
  subject{ WeatherCollection.new }

  describe '#initialize' do
    it 'instatiates @collection_points as []' do
      subject.instance_variable_get(:@collection_points).should == []
    end
  end
  describe '<<' do
    it 'injects the passed arg to @collection_points' do
      subject << 'DummyStringObject'
      subject.instance_variable_get(:@collection_points).should == ['DummyStringObject']
    end
  end

  context 'temperature comparison methods' do
    let(:smallest_diff){ DayWeather.new(1,5,2) }
    let(:middle_diff){ DayWeather.new(1,10,5) }
    let(:largest_diff){ DayWeather.new(1,100,50) }
    before do
      subject << largest_diff
      subject << smallest_diff
      subject << middle_diff
    end

    describe '#point_with_max_temperature_difference' do
      it 'returns the point with the maximum difference between min and max temps for all @collection_points' do
        subject.point_with_max_temperature_difference.should == largest_diff
      end
    end

    describe '#point_with_min_temperature_difference' do
      it 'returns the point with the minimium difference between min and max temps for all @collection_points' do
        subject.point_with_min_temperature_difference.should == smallest_diff
      end
    end
  end
end

describe DayWeather do
  subject{ DayWeather.new(1, 10, 5) }
  describe '#initialize' do
    it 'assigns the three main variables' do
      subject.number.should == 1
      subject.min_temp.should == 5
      subject.max_temp.should == 10
    end
  end

  describe '#temperature_difference' do
    it 'returns the difference between the max and min temperatures' do
      subject.temperature_difference.should == 5
    end
  end
  describe '#validate' do
    it 'does not raise an exception when max_temp >= min_temp' do
      lambda{ subject.validate }.should_not raise_exception
    end
    it 'raises an exception when !( max_temp >= min_temp)' do
      lambda do
        subject.max_temp = -1
        subject.validate
      end.should raise_exception
    end
  end
end

module Mock
  class MovingCoordinates

    STARTING_LATITUDE = 47.6155.freeze
    STARTING_LONGITUDE = -122.3411.freeze

    MAX_DISTRIBUTION_RANGE = 0.01.freeze

    # co-ordinate change per second
    WALKING_SPEED = 0.000005.freeze
    RUNNING_SPEED = 0.00001.freeze
    DRIVING_SPEED = 0.0001.freeze
    BIKING_SPEED  = 0.00003.freeze

    INT_TO_SPEED = {
      0 => WALKING_SPEED,
      1 => RUNNING_SPEED,
      2 => DRIVING_SPEED,
      3 => BIKING_SPEED
    }.freeze

    def initialize count=4
      @count = count
      
      @speed_array = []
      (1..count).each do
        speed = rand(4)
        @speed_array.push(INT_TO_SPEED[speed]) 
      end
      
      @latitude_array = [STARTING_LATITUDE]
      (2..count).each do
        deviation = MAX_DISTRIBUTION_RANGE/rand(100)
        lat = transform_coordinate deviation, STARTING_LATITUDE
        @latitude_array.push(lat) 
      end
      
      @longitude_array = [STARTING_LONGITUDE]
      (2..count).each do
        deviation = MAX_DISTRIBUTION_RANGE/rand(100)
        lng = transform_coordinate deviation, STARTING_LONGITUDE
        @longitude_array.push(lng)
      end

      @straight_line_distance = []
      (1..count).each do
        @straight_line_distance.push(rand(20))
      end

      @lat_step_operation = []
      (1..count).each do
        @lat_step_operation.push(rand(3))
      end

      @lng_step_operation = []
      (1..count).each do
        @lng_step_operation.push(rand(3))
      end
    end

    def transform_coordinate speed, x, operation=rand(3)
      case operation
      when 0
        x += speed
      when 1
        x -= speed
      end
      x
    end

    def transform_all
      @count.times do |i|
        speed = @speed_array[i]
        if @straight_line_distance[i] > 0
          @latitude_array[i] = transform_coordinate speed, @latitude_array[i], @lat_step_operation[i]
          @longitude_array[i] = transform_coordinate speed, @longitude_array[i], @lng_step_operation[i]
          @straight_line_distance[i] -= 1
        else
          @straight_line_distance[i] = rand(20)
          @lat_step_operation[i] = rand(3)
          @lng_step_operation[i] = rand(3)
        end
      end
    end

    def print_coordinates
      lat = @latitude_array.map { |l| l.round(5) }
      lng = @longitude_array.map { |l| l.round(5) }
      print "LAT = ", lat
      puts " "
      print "LNG = ", lng
      puts " "
      print "DST = ", @straight_line_distance
    end

    def execute
      print_coordinates
      loop do
        transform_all
        sleep(1)
        print_coordinates
      end
    end

  end
end

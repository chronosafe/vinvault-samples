require 'HTTParty'
module Decoder
  # URL of API
  URL = 'http://api.vinvault.com/api/decodes.json'
  # URL = 'http://localhost:3000/api/decodes.json'

  SAMPLE_KEY = 'RLBVPvj8riQmRuPzcT' # default key if none is passed.  Will always return the same VIN
  # Decode a vehicle using this class
  # key = VIN Vault auth_key
  # version = API version (defaults to nil which uses the most recent version)
  class Parser
    def initialize(key = SAMPLE_KEY, version = nil)
      @key = key
      @version = version
    end

    # Perform the actual data fetch and decode
    # vin = the vehicle vin you wish to decode
    # type = optional type of decode: 1 = basic, 2 = advanced
    # returns an array: [http status, Decode object], object is nil unless status is 201
    def decode(vin, type = nil)
      # assign the decode type if present
      type_str = ''
      type_str = "&type=#{type}" unless type == nil
      # Add the version header if present
      header = @version.nil? ? nil : {'Accept' => "application/vnd.vindata.v#{@version}"}
      @result = HTTParty.post(URL, headers: header, body: "vin=#{vin}&auth_token=#{@key}#{type_str}")
      if @result.code == 201 # a successful decode, return the decoded value
        return @result.code, Decode.new(@result.body)
      else
        return @result.code, nil # an unsuccessful decode, the status code will convery the reason
      end
    end
  end


  # Base class for all data classes
  # uses OpenStruct objects to return data
  # method_missing is overrided to return data as properties
  class DecodeStruct
    def initialize(data)
      @data = OpenStruct.new(data)
    end

    def method_missing(symbol, *args)
      @data.send(symbol)
    rescue
      super
    end

    # Returns the proper nested child class for each object
    # Uses reflection to determine the object type and properly
    # return an array of the data_class
    def subclass(obj, data_class)
      output = []
      output << data_class.new(obj) if obj.is_a? Hash
      obj.each {|o| output << data_class.new(o)} if obj.is_a? Array
      output
    end
  end

  # Decode object
  class Decode < DecodeStruct
    # Pass in a JSON string to create the classes
    def initialize(data)
      @data = OpenStruct.new(ActiveSupport::JSON.decode(data)['decode'])
    end

    def trims
      subclass(@data.trim, Trim)
    end
  end

  # Trim level object
  class Trim < DecodeStruct
    def items
      subclass(@data.data, Item)
    end
  end

  # Item (data) object
  class Item < DecodeStruct
    def options
      subclass(@data.option, Option)
    end
  end

  # Item Option object
  class Option < DecodeStruct; end

end
# VIN Vault Ruby Sample

Access to the VIN Vault API using Ruby can be readily implemented using the `Decoder.rb` module in this folder.  The module is self-contained (meaning the data classes are within the module), but does require the [HTTParty](https://github.com/jnunemaker/httparty) ruby gem.

Usage of the module is as follows:

```
decoder = Decoder::Parser.new(api_token, version = nil)
```
Where `api_token` is your VIN Vault API token and `version` is the version of the API you wish to use.  Passing no `version` will return data from the latest API version.

With the newly created `Decoder::Parser` object you can then proceed to call for a VIN to be decoded using the `decode` method:

```ruby
decoder = Decoder::Parser.new('your_api_token')

status, vehicle = decoder.decode('4T4BF3EK9AR060017')
vehicle.trims.first.items {|i| puts "#{i.category} => #{i.value}" }
```

Where `status` is the HTTP response code.  It will be `201 Created` for successful decodes, and other codes when unsuccessful:


|Code| Description|
|------|-------|
|401| Unauthorized|
|403| Unauthenticated|
|404| Vehicle not found|
|500| Serious server error|

The `vehicle` in the example above refers to the successfully decoded data stored in a `Decoder::Decode` class.  Each `Decode` contains the decoded data:

|Class|Data|Property|
|-------|-------|-------|
|`Decode`| Decode data|| 
|`Trim`| Vehicle trim| `Decode.trims` array
|`Item`| Trim equipment data| `Trim.items` array|
|`ItemOption`| Options for `Item` classes| `Item.options` array|

Note that the `Parser.decode` method has an optional second parameter of the type of decode you wish to have returned: 1 = Basic, 2 = Advanced.

## Decode Class

The `Decoder::Decode` class is the base data class for the module.  All other data classes are referenced from this class.

You can instantiate this class directly if you have JSON from VIN Vault (for example persisted from a database) by calling:

```ruby
vehicle = Decoder::Decode.new(json_string)
```

This will return a new `Decode` object.

Please refer to the VIN Vault documentation for more information on the data format.


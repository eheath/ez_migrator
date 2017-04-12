require 'json'
module EzMigrator
  class SchemaVersion
    def initialize config_obj: Config.new({env: 'test'})
      @config_obj = config_obj
      @datastore = File.read(config_obj[:schema_version])
    end

    def datastore
      @datastore
    end

    def all
      JSON.parse( @datastore ) rescue {}
    end
  end
end
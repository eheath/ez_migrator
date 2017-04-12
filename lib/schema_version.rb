require 'json'
module EzMigrator
  class SchemaVersion
    def initialize config_obj: Config.new({env: 'test'})
      @file_name  = config_obj.schema_version
      @env        = config_obj.env
    end

    def datastore
      @datastore ||= begin
        JSON.parse( File.read( @file_name ) )
      rescue
        { 'test' => [], 'dev' => [], 'qa' => [], 'prod' => [] }
      end
    end

    def current_versions
      byebug

      datastore[ @env ].map{ |k, v| k }
    end

    def update version: nil
      unless version.nil?
        datastore[ @env ] << { version => Time.now }
        File.open( @file_name, 'w' ) { |f| f.write( datastore ) }
      end
    end

    def rollback version: nil
      unless version.nil?
        File.open( @file_name, 'w' ) { |f| f.write datastore[ @env ].delete( version ) }
      end
    end

  end
end
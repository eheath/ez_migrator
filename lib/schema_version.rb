require 'json'
module EzMigrator
  class SchemaVersion

    attr_reader :file_name

    def initialize config_obj: Config.new({env: 'test'})
      @file_name  = config_obj.schema_version
      @env        = config_obj.env
    end

    def datastore
      @datastore ||= begin
        JSON.parse( File.read( @file_name ) )
      rescue
        { 'test' => {}, 'dev' => {}, 'qa' => {}, 'prod' => {} }
      end
    end

    def current_versions
      datastore[ @env ].map{ |k, v| k }
    end

    def update version: nil
      unless version.nil?
        datastore[ @env ][ version ] = Time.now
        File.open( @file_name, 'w' ) { |f| f.write( datastore.to_json ) }
      end
    end

    def rollback version: nil
      unless version.nil?
        datastore[ @env ].delete( version )
        File.open( @file_name, 'w' ) { |f| f.write datastore.to_json }
      end
    end

  end
end
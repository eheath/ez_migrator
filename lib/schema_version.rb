require 'json'
module EzMigrator
  class SchemaVersion

    attr_reader :file_name

    def initialize config_obj: Config.new({env: 'test'})
      @file_name  = config_obj.env + '.schema_version'
      @env        = config_obj.env
    end

    def current
      @current_version ||= read_current_version
    end

    def update version: nil
      unless version.nil?
        File.open(file_name, 'a+') { |f| f.write("#{version}\n")}
      end
    end

    def rollback version: nil
      # to do: get each migration,
      # apply the rollback
      # and delete from the version file
      if version.nil?
        current.delete(current.last)
      else
        current.delete( version )
      end
      File.open( file_name, 'w' ) { |f| f.puts current }
    end




    # def datastore
    #   @datastore ||= begin
    #     JSON.parse( File.read( @file_name ) )
    #   rescue
    #     { 'test' => {}, 'dev' => {}, 'qa' => {}, 'prod' => {} }
    #   end
    # end

    # def current_versions
    #   datastore[ @env ].map{ |k, v| k }
    # end




    private

      def read_current_version
        File.read(file_name).split("\n") rescue []
      end

  end
end
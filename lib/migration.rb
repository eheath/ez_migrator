module EzMigrator
  class Migration
    attr_reader :file_name

    def initialize file_name: nil, db_connection: DbConnection.new
      @file_name = file_name unless file_name.nil?
      @db_connection = db_connection unless db_connection.nil?
    end

    def generate file_name
      versioned_file_name = "#{DateTime.now.strftime('%Q')}_#{file_name}.sql"
      FileWriter.new.write_file(versioned_file_name, file_sample_contents)
    end

    def list_all
      Dir.glob("./migrations/*.sql")
    end

    def applied_migrations
      current_versions.map{|v| Dir.glob("./migrations/#{v}*.sql")}.flatten.compact
    end

    def current_versions
      @db_connection.exec('select * from schema_version').map{ |sv| sv['version'] }
    end

    def pending_migrations
      (list_all - applied_migrations).map{|pm| File.basename pm }
    end

    def file_sample_contents
      <<~HEREDOC
        -- UP START
        CREATE TABLE foo.bar(
          id integer,
          baz text
        );
        -- UP END


        -- ROLLBACK START
        DROP TABLE foo.bar;
        -- ROLLBACK END
      HEREDOC
    end

    def to_s
      file_name
    end

    def up_definition
      File.read("./migrations/#{file_name}")[/--\s*up start(.*?)--\s*up end/im, 1].strip
    end

    def apply
      @db_connection.exec(up_definition)
      update_db_version
    end

    def rollback
      @db_connection.exec(down_definition)
      rollback_db_version
    end

    def update_db_version
      @db_connection.exec("insert into public.schema_version values(#{version})")
    end

    def rollback_db_version
      @db_connection.exec("delete from public.schema_version where version = '#{version}'")
    end

    def version
      file_name.split('_')[0]
    end

    def down_definition
      File.read("./migrations/#{file_name}")[/--\s*down start(.*?)--\s*down end/m, 1].strip
    end

  end
end
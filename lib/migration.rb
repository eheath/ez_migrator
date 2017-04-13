module EzMigrator
  class Migration
    attr_reader :file_name, :schema_version

    def initialize file_name: nil, db_connection: DbConnection.new, config_obj: Config.new({env: 'test'})
      @file_name = file_name unless file_name.nil?
      @db_connection = db_connection unless db_connection.nil?
      @schema_version = SchemaVersion.new(config_obj: config_obj)
    end

    def generate file_name
      versioned_file_name = "#{DateTime.now.strftime('%Q')}_#{file_name}.sql"
      FileWriter.new.write_file(versioned_file_name, file_sample_contents)
    end

    def list_all
      Dir.glob("./migrations/*.sql").map{|f| File.basename f}
    end

    def applied_migrations
      applied_files = []
      if current_versions.count > 0
        migration_files = current_versions.map{|v| Dir.glob("./migrations/#{v}*.sql") }.flatten.compact
        if migration_files.count > 0
          applied_files = migration_files.map{|f| File.basename(f)}
        end
      end
      applied_files
    end

    def current_versions
      @schema_version.current_versions
    end

    def pending_migrations
      list_all - applied_migrations
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

    def apply
      @db_connection.exec(up_definition)
      @schema_version.update(version: version)
    end

    def rollback
      @db_connection.exec(down_definition)
      @schema_version.rollback(version: version)
    end

    def version
      file_name.split('_')[0]
    end

    def down_definition
      File.read("./migrations/#{file_name}")[/--\s*rollback start(.*?)--\s*rollback end/im, 1].strip
    end

    def up_definition
      File.read("./migrations/#{file_name}")[/--\s*up start(.*?)--\s*up end/im, 1].strip
    end

  end
end
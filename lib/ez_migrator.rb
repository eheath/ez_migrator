require "ez_migrator/version"
require 'Date'
require 'json'
require 'migration'

module EzMigrator
  class Worker

    def initialize(db_connection: DbConnection.new, config_obj: Config.new(env: 'test'))
      @db_connection = db_connection unless db_connection.nil?
      @config_obj = config_obj
    end

    def migration_obj
      @migration_obj ||= EzMigrator::Migration.new(db_connection: @db_connection)
    end

    def generate file_name
      migration_obj.generate file_name
    end

    def applied_migrations
      migration_obj.applied_migrations
    end

    def all_migrations
      migration_obj.list_all
    end

    def pending_migrations
      migration_obj.pending_migrations
    end

    def migrate
      if pending_migrations.count > 0
        pending_migrations.each do |file_name|
          puts "file_name: #{file_name}"
          migration = EzMigrator::Migration.new(file_name: file_name, db_connection: @db_connection)
          begin
            migration.apply
            puts "Migrated: #{migration.to_s}"
          rescue Exception => e
            puts e.message
            puts "FAILED: #{migration.to_s}"
          end
        end
      else
        puts "No pending migrations for #{@config_obj.env}"
      end
    end

    def rollback

    end

  end
end

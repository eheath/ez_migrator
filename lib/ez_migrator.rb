require "ez_migrator/version"
require 'Date'
require 'json'
require 'migration'

module EzMigrator
  class Worker
    attr_reader :db_connection

    def initialize(db_connection: DbConnection.new, migration_obj: nil)
      @db_connection = db_connection unless db_connection.nil?
      @migration_obj = migration_obj unless migration_obj.nil?
    end

    def migration_obj
      @migration_obj ||= EzMigrator::Migration.new
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
      newly_applied_migrations = []
      pending_migrations.each do |file_name|
        puts "file_name: #{file_name}"
        migration = EzMigrator::Migration.new(file_name: file_name, db_connection: db_connection)
        begin
          migration.apply
          newly_applied_migrations << file_name
          puts "Migrated: #{migration.to_s}"
        rescue Exception => e
          puts e.message
          puts "FAILED: #{migration.to_s}"
        end
      end
    end

    def rollback

    end

  end
end

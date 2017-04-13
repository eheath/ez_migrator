require "spec_helper"
require 'file_reader'

module EzMigrator
  describe Worker do
    let(:db_connection) { DbConnection.new }
    let(:migration_obj) { EzMigrator::Migration.new(db_connection: db_connection) }
    let(:ez_migrator){ EzMigrator::Worker.new(db_connection: db_connection, migration_obj: migration_obj) }

    before(:example) do
      cleanup db_connection
    end

    after(:example) do
      cleanup db_connection
    end


    it "has a version number" do
      expect(EzMigrator::VERSION).not_to be nil
    end

    it "generate" do
      expect(migration_obj).to receive(:generate).with(/foo/)
      ez_migrator.generate "foo"
    end

    it "all_migrations" do
      expect(migration_obj).to receive(:list_all)
      ez_migrator.all_migrations
    end

    it "applied_migrations" do
      expect(migration_obj).to receive(:applied_migrations)
      ez_migrator.applied_migrations
    end

    it "pending_migrations" do
      Migration.new.generate 'blue_tomato'
      expect(ez_migrator.pending_migrations.first).to match(/blue_tomato/)
    end

    it "migrate" do
      Migration.new.generate 'apply_this_migration'
      expect(ez_migrator.migrate.first).to match(/apply_this_migration/)
    end

  end
end

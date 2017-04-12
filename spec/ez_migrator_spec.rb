require "spec_helper"
require 'file_reader'

module EzMigrator
  describe Worker do
    before(:example) {
      allow_any_instance_of(EzMigrator::Migration).to receive(:applied_migrations).and_return({'foo.sql' => Time.now})
      allow_any_instance_of(EzMigrator::Migration).to receive(:generate).and_return(true)
      allow_any_instance_of(EzMigrator::Migration).to receive(:list_all).and_return( ['bar.sql', 'baz.sql', 'foo.sql'])
      allow_any_instance_of(EzMigrator::Migration).to receive(:up_definition).and_return('lorem ipsum')
    }
    let(:migration_obj) { EzMigrator::Migration.new }
    let(:db_connection) { double('db_connection', exec: true) }
    let(:ez_migrator){ EzMigrator::Worker.new(db_connection: db_connection, migration_obj: migration_obj) }

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
      expect(ez_migrator.pending_migrations).to eq(['bar.sql', 'baz.sql'])
    end

    it "migrate" do
      expect(db_connection).to receive(:exec).with('lorem ipsum').twice
      ez_migrator.migrate
    end

  end
end

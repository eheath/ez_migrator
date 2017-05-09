require 'spec_helper'
# require 'config'

module EzMigrator
  describe Migration do
    let(:config) { Config.new({env: 'test', file_name: 'config.yml'}) }
    let(:db_connection) { DbConnection.new(config)}
    let(:migration) { Migration.new(file_name: 'foo.sql')}

    before(:example) do
      cleanup db_connection
    end

    after(:example) do
      cleanup db_connection
    end

    it "file_name" do
      expect(migration.file_name).to eq('foo.sql')
    end

    it "to_s" do
      expect(migration.file_name.to_s).to eq('foo.sql')
    end

    it "generates a new migration" do
      expect(Migration.new.generate('a_new_migration')).to match(/CREATED/)
    end

    it "creates itself from a file on disk" do
      migration_file = Migration.new.generate('pre_existing_migration').split(' ')[1]
      expect(Migration.new(file_name: migration_file).file_name).to match(/pre_existing_migration/)
    end

    it 'up_definition' do
      file_name = Migration.new.generate('foo_bar').split(' ')[1]
      expect(Migration.new(file_name: file_name).up_definition).to match(/create table foo.bar/i)
    end

    it 'down_definition' do
      file_name = Migration.new.generate('foo_bar').split(' ')[1]
      expect(Migration.new(file_name: file_name).down_definition).to match(/drop table foo.bar/i)
    end

    it 'can migrate up and down' do
      file_name = Migration.new.generate('foo_bar').split(' ')[1]
      migration = Migration.new(file_name: file_name)
      migration.apply
      expect(migration.current_versions).to eq([file_name])
      migration.rollback
      expect(migration.current_versions.count).to eq(0)
    end

    it 'knows which migrations have been applied' do
      migration_1_filename = Migration.new.generate('create_foo_to_apply').split(' ')[1]
      Migration.new(file_name: migration_1_filename).apply
      unapplied_migration = Migration.new(file_name: 'create_bar')
      expect(Migration.new.applied_migrations).to eq(["#{migration_1_filename}"])
    end

    it 'knows which migrations are pending' do
      migration_1_filename = Migration.new.generate('create_foo').split(' ')[1]
      Migration.new(file_name: migration_1_filename).apply
      unapplied_migration = Migration.new.generate('create_bar').split(' ')[1]
      expect(Migration.new.pending_migrations).to eq(["#{unapplied_migration}"])
    end

  end
end
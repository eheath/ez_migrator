require 'spec_helper'
require 'config'
require 'fileutils'

module EzMigrator
  describe Migration do
    let(:config) { Config.new({env: 'test', file_name: 'config.yml'}) }
    let(:db_connection) { DbConnection.new(config)}
    let(:migration) { Migration.new(file_name: 'foo.sql')}
    let(:example_contents) { "--up start\ncreate table foo_bar ( baz text );\n-- up end\n-- down start\ndrop table foo_bar;\n--down end\n" }
    let(:clear_db) { db_connection.exec( "drop table if exists foo.bar; delete from public.schema_version;") }
    let(:clear_migrations) { FileUtils.rm Dir.glob('./migrations/*.sql') }

    before(:example) do
      clear_migrations
      clear_db
    end

    after(:example) do
      clear_migrations
      clear_db
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
      File.open("./migrations/#{file_name}", 'w'){ |f| f.write example_contents }
      expect(Migration.new(file_name: file_name).up_definition).to match(/create table foo_bar/)
    end

    it 'down_definition' do
      file_name = Migration.new.generate('foo_bar').split(' ')[1]
      File.open("./migrations/#{file_name}", 'w'){ |f| f.write example_contents }
      expect(Migration.new(file_name: file_name).down_definition).to match(/drop table foo_bar/)
    end

    it 'can migrate up and down' do
      file_name = Migration.new.generate('foo_bar').split(' ')[1]
      # File.open("./migrations/#{file_name}", 'w'){ |f| f.write example_contents }
      migration = Migration.new(file_name: file_name)
      migration.apply
      # expect(db_connection.exec("select * from public.schema_version where version like '%#{migration.version}%'").ntuples).to eq(1)
      expect(migration.current_versions).to eq(file_name.split('_')[0])

      migration.rollback
      # expect(db_connection.exec("select * from public.schema_version where version like '%#{migration.version}%'").ntuples).to eq(0)
      expect(migration.current_versions.count).to eq(0)
    end

    it 'knows which migrations have been applied' do
      migration_1_filename = Migration.new.generate('create_foo').split(' ')[1]
      Migration.new(file_name: migration_1_filename).apply
      unapplied_migration = Migration.new(file_name: 'create_bar')
      expect(Migration.new.applied_migrations).to eq(["./migrations/#{migration_1_filename}"])
    end

    it 'knows which migrations are pending' do
      migration_1_filename = Migration.new.generate('create_foo').split(' ')[1]
      Migration.new(file_name: migration_1_filename).apply
      unapplied_migration = Migration.new.generate('create_bar').split(' ')[1]
      expect(Migration.new.pending_migrations).to eq(["./migrations/#{unapplied_migration}"])
    end

  end
end
require 'spec_helper'
require 'file_reader'

module EzMigrator
  describe SchemaVersion do
    let(:db_connection) { DbConnection.new }
    let(:config_object) { EzMigrator::Config.new({env: 'test'}) }
    let(:schema_version) { EzMigrator::SchemaVersion.new({config_obj: config_object})}

    before(:each){
      cleanup db_connection
    }

    it '#current exists' do
      expect(schema_version).to respond_to(:current)
    end

    it '#current is an array' do
      expect(schema_version.current).to be_kind_of(Array)
    end

    it '#current returns an empty array when no migrations have been applied' do
      expect(schema_version.current).to eq([])
    end

    it '#current returns an array of currently applied migrations' do
      applied_migrations = ['foo.sql', 'bar.sql']
      File.open(schema_version.file_name, 'w') {|f| f.puts applied_migrations }
      expect(schema_version.current).to eq(['foo.sql', 'bar.sql'])
    end



  end
end
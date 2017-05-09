$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ez_migrator"
require 'byebug'
require 'db_connection'
# require_relative '../lib/db_connector.rb'
require_relative '../lib/file_writer.rb'
require_relative '../lib/file_reader.rb'
require_relative '../lib/config.rb'
require_relative '../lib/schema_version.rb'
require 'fileutils'

def cleanup db_connection
  db_connection.exec( "drop table if exists foo.bar;")
  FileUtils.rm Dir.glob('./migrations/*.sql')
  delete_schema_versions
end

def delete_schema_versions
  FileUtils.rm Dir.glob('*.schema_version')
end
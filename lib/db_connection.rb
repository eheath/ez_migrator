require 'pg'
require 'byebug'

module EzMigrator
  class DbConnection
    attr_reader :conn

    def initialize config_info=Config.new
      @conn = PG::Connection.new( host:     config_info.db_host,
                                  dbname:   config_info.db_name,
                                  user:     config_info.db_user,
                                  password: config_info.db_pass )
      @conn.exec('SET client_min_messages TO WARNING')
    end

    def exec sql
      @conn.exec(sql)
    end

  end
end
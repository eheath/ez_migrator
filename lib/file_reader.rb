module EzMigrator
  class FileReader
    def read file_name
      begin
        File.read("./migrations/#{file_name}")
      rescue
        nil
      end
    end
  end
end
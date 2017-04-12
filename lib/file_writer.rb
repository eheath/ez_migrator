module EzMigrator
  class FileWriter

    def write_file file_name, contents=nil
      File.open("./migrations/#{file_name}", 'w') { |f| f.write contents }
      confirm_file file_name
    end

    def confirm_file file_name
      ret_str = if was_written? file_name
        "CREATED: #{file_name}"
      else
        "FAILED: #{file_name}"
      end
      puts ret_str
      ret_str
    end

    def was_written? file_name
      Dir.glob("./migrations/#{file_name}").count > 0
    end

  end
end
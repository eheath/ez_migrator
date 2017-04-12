require 'yaml'
module EzMigrator
  class Config
    attr_reader :data, :env

    def initialize(opts={})
      @env      = opts[:env] ||= 'test'
      file_name  = opts[:file_name] ||= 'config.yml'
      @data = YAML::load_file(File.join('.', file_name))
      define_methods_for_environment(data[env].keys)
    end

    def define_methods_for_environment(names)
      names.each do |name|
        self.class.class_eval <<-EOS
          def #{name}
            data[env]['#{name}']
          end
        EOS
      end
    end

  end
end
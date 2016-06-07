module Protrack
  module Apiload
    # Configuration default values
    @defaults = {
      'email_delivery' => nil
    }

    @config = nil

    class << self
      # Valid options:
      # * <tt>:file</tt>: the configuration file to load (default: config/configuration.yml)
      # * <tt>:env</tt>: the environment to load the configuration for (default: Rails.env)
      def load(options={})
        filename = options[:file] || File.join(Rails.root, 'config', 'api_settings.yml')
        env = options[:env] || Rails.env

        @config = @defaults.dup

        if File.file?(filename)
          @config.merge!(load_from_yaml(filename, env))
        end

        @config
      end

      # Returns a configuration setting
      def [](name)
        load
        @config[name]
      end

      private

      def load_from_yaml(filename, env)
        yaml = nil
        begin
          yaml = YAML::load_file(filename)
        rescue ArgumentError
          $stderr.puts "Your ProTrack configuration file located at #{filename} is not a valid YAML file and could not be loaded."
          exit 1
        end
        conf = {}
        if yaml.is_a?(Hash)
          if yaml['default']
            conf.merge!(yaml['default'])
          end
          if yaml[env]
            conf.merge!(yaml[env])
          end
        else
          $stderr.puts "Your ProTrack configuration file located at #{filename} is not a valid ProTrack configuration file."
          exit 1
        end
        conf
      end

    end
  end
end
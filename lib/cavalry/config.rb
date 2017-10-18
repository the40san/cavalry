module Cavalry
  class Config
    # Defines validator definition path. files required with **/*.rb
    mattr_accessor :models_path

    # Defines validator definition path. files required with **/*.rb
    mattr_accessor :validators_path

    def load_models
      load_rb_files(models_path)
    end

    def load_validators
      load_rb_files(validators_path)
    end

    private

    def load_rb_files(path)
      return unless path
      files = Dir.glob(File.join("#{path}", "**/*.rb"))
      files.each { |f| require f }
    end
  end
end

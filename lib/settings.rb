class Settings
  class << self
    def app
      @app ||= ::YAML.load_file('config/application.yml', aliases: true, symbolize_names: true)[env]
    end

    def development?
      env == :development
    end

    private

    def env
      @env ||= (ENV['RACK_ENV'] || 'development').to_sym
    end
  end
end

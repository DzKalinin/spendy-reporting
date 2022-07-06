class Settings
  def self.app
    @app ||= ::YAML.load_file('config/application.yml', aliases: true, symbolize_names: true)[env]
  end

  def self.development?
    self.env == :development
  end

  private

  def self.env
    @env ||= (ENV['RACK_ENV'] || 'development').to_sym
  end
end

class LocalNames

  attr_accessor :local_names
  attr_accessor :yaml_file
  attr_accessor :logger
  attr_accessor :theme_name


  # Lots of nay-saying about singleton patterns be-damned.
  class << self
    def instance(theme)
      @instances = {} unless @instances
      unless @instances[theme]
        @instances[theme] = self.new(theme)
      end
      return @instances[theme]
    end
  end

  def initialize(theme  = APP_CONFIG[:theme] || 'default')
    self.theme_name = theme
    self.logger = Rails.logger
  end

  def load_names(path=File.join("config","local_names.yml"))
    self.yaml_file = File.join(RAILS_ROOT, path)
    config_data = []
    begin
      config_data = File.open(self.yaml_file, "r").read
      self.parse_yaml(config_data)
    rescue
      logger.warn("Can't read #{self.yaml_file}, no names defined");
    end
  end
  
  def parse_yaml(string)
    config = YAML::load(string)
    names = config[theme_name]
    unless names
      logger.warn("No 'names' specified in #{self.yaml_file}")
      self.local_names = {}
      return
    end
    unless names.kind_of? Hash
      logger.warn("no entry for #{self.theme_name} specified as Hash in #{self.yaml_file}")
      self.local_names = {}
      return
    end
    self.local_names = names
  end

  def local_name_for(thing,default=thing.class.name.underscore.humanize.titlecase)
    load_names unless self.local_names
    # self.local_names ||= {}
    key = "default_key"
    case thing
    when String
      # use the string itself as the key
      key = thing
    else
      # try to use the class name as the string
      key = thing.class.name
    end
    return self.local_names[key] || self.local_names[key.downcase] || default
  end
end

require 'yaml'

class Secrets

  attr_accessor :digital_ocean_key

  def initialize
    secrets = YAML.load_file("secrets.yaml")
    @digital_ocean_key = secrets["digital_ocean"]["key"]
  end

end

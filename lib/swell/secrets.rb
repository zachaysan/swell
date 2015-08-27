require 'yaml'

class Secrets

  attr_accessor :digital_ocean_key
  attr_reader :ssh_pub_key

  def initialize

    secrets = YAML.load_file("config/secrets.yaml")
    @digital_ocean_key = secrets["digital_ocean"]["key"]
    load_ssh_pub_key(secrets["ssh"]["pub_key_path"])

  end

  def load_ssh_pub_key(pub_key_path)
    @ssh_pub_key = File.read(pub_key_path)
  end

end

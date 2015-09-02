require 'yaml'

class Secrets

  attr_accessor :digital_ocean_key
  attr_reader :ssh_pub_key

  def initialize

    $logger.info "Loading swell secrets file"
    path = File.join(File.dirname(__FILE__),
                     "..",
                     "..",
                     "config",
                     "secrets.yaml")

    secrets = YAML.load_file(path)
    @digital_ocean_key = secrets["digital_ocean"]["key"]
    load_ssh_pub_key(secrets["ssh"]["pub_key_path"])

  end

  def load_ssh_pub_key(pub_key_path)
    @ssh_pub_key = File.read(pub_key_path)
  end

end

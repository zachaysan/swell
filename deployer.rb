class Deployer

  def initialize(droplet_manager)
    @droplet_manager = droplet_manager
  end

  def instruct_all(message)
    @droplet_manager.droplets.each do |droplet|
      host = "root@#{droplet.networks.v4.first.ip_address}"

      ssh_command = "ssh"

      puts `#{ssh_command} #{host} #{message}`
    end
  end

end

class Deployer

  def initialize(droplet_manager)
    @droplet_manager = droplet_manager
  end

  def instruct_all(message)
    $logger.info({text: "Instructing all droplets",
                  message: message})
    @droplet_manager.droplets.each do |droplet|
      host = "root@#{droplet.networks.v4.first.ip_address}"

      ssh_command = "ssh"

      $logger.info({text: "Command output",
                    output: `#{ssh_command} #{host} #{message}`.chomp})
    end
  end

end

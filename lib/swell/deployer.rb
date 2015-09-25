class Deployer

  attr_reader :droplet_manager

  def initialize(droplet_manager)
    @droplet_manager = droplet_manager
  end

  def instruct_all(message)
    $logger.info({text: "Instructing all droplets",
                  message: message})
    @droplet_manager.droplets.each do |droplet|
      self.instruct_droplet(droplet, message)
    end
  end

  def instruct(droplet_count,
               message)

    if @droplet_manager
      .droplets(wait_on_new_droplets=false)
      .count < droplet_count

      @droplet_manager.set_droplet_target droplet_count
    end

    @droplet_manager.droplets.each do |droplet|
      break if droplet_count < 1
      self.instruct_droplet droplet, message
    end
  end

  def instruct_droplet(droplet, message)
    host = "root@#{droplet.networks.v4.first.ip_address}"

    ssh_command = "ssh"

    $logger.info({text: "Command output",
                  output: `#{ssh_command} #{host} #{message}`.chomp})
  end
end

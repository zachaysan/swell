class Deployer

  def initialize(droplet_manager)
    @droplet_manager = droplet_manager
  end

  def instruct_all(message)
    @droplet_manager.droplets.each do |droplet|
      host = "root@#{droplet.networks.v4.first.ip_address}"

      # StrictHostKeyChecking=no means that we trust the first
      # SSH connection attempt, since we aren't going to check
      # anyway, but if there is a *change* in the key, then we
      # still want the command to fail.
      ssh_command = "ssh -o StrictHostKeyChecking=no"

      puts `#{ssh_command} #{host} #{message}`
    end
  end

end

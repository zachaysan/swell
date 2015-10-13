class Deployer

  attr_reader :droplet_manager

  def initialize(droplet_manager)
    @droplet_manager = droplet_manager
  end

  def rsync(droplet, filename, server_path=nil, log=true)
    host = "root@#{droplet.networks.v4.first.ip_address}"
    if log
      $logger.info({text: "Rsync droplet",
                    host: host,
                    filename: filename,
                    server_path: server_path})
    end

    server_path ||= "/root/"

    `rsync --rsh='ssh' -av --quiet #{filename} #{host}:#{server_path}`

  end

  def rsync_all(filename, server_path=nil)

    @droplet_manager.droplets.each do |droplet|
      self.rsync(droplet, filename, server_path, log=false)
    end
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

    command = "#{ssh_command} #{host} '#{message}'"
    output = `#{command}`.chomp
    $logger.info({text: "Command output",
                  server_command: message,
                  output: output})
  end
end

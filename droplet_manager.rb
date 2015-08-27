require "yajl"

$logger = Yajl.create_logger

require "securerandom"
require "yaml"
require "pp"

require_relative "known_host.rb"

class DropletManager

  def initialize(client, task, ssh_key)

    @client = client
    @task = task.to_s

    # NOTE: Task names are used extensively and accidental
    #       collision is possible. See #destroy_all_droplets.
    raise "6 letter task required" unless @task.size > 5

    raise "ssh_key required" if ssh_key.nil?
    @ssh_key = ssh_key

    @delay_until = 0
    self.increment_delay(2)

    @deleted_droplets = []
  end

  def delay
    sleep([@delay_until - Time.now.to_f, 0.0].max)
  end

  def increment_delay(amount)
    @delay_until = [@delay_until, Time.now.to_f + amount].max
  end

  def droplets(wait_on_new_droplets=true)
    self.delay

    droplets = @client.droplets.all.select do |droplet|
      deleted = @deleted_droplets.include?(droplet.name)
      droplet.name.start_with?(@task) && !deleted
    end

    return droplets unless wait_on_new_droplets

    if droplets.any? { |droplet| droplet.status == "new" }

      $logger.info({ text: "Waiting on droplet activation",
                     droplets: droplets
                       .map { |d| { name: d.name,
                                    status: d.status } }
                   })

      increment_delay(3)
      return self.droplets

    else

      $logger.info({ text: "Waiting on droplet activation",
                     droplets: droplets
                       .map { |d| { name: d.name,
                                    status: d.status } }
                   })

      droplets
    end
  end

  def destroy_all_droplets
    $logger.info "Destroying all droplets for task #{@task}"

    droplets = self.droplets(wait_on_new_droplets=false)

    unless droplets.size > 0
      $logger.info "No droplets to destroy"
      return
    end

    droplets.each do |droplet|
      $logger.info "Deleting #{droplet.name}"
      @client.droplets.delete( id: droplet.id )
      @deleted_droplets << droplet.name
    end

    self.increment_delay(2)
  end

  def set_droplet_target(count, update_known_hosts=true)
    known_hosts = []

    # 1% chance of collision after 10_000 generations.
    (self.droplets.length + 1).upto(count) do

      id = SecureRandom.hex(4)
      name = "#{@task}-#{id}"

      region = ["nyc1",
                "sfo1",
                "nyc2",
                "sgp1",
                "lon1",
                "nyc3",
                "ams3",
                "fra1"].sample

      $logger.info({ text: "Creating droplet",
                     name:  name,
                     region: region })

      password = SecureRandom.hex(20)

      loc = "/tmp/#{name}"

      e = "ssh-keygen -t ecdsa-sha2-nistp256 -f #{loc} -q -N \"\" -C \"\""

      system(e) or raise "Error generating ssh keys for new server"

      private_key = `base64 --wrap=0 #{loc}`.chomp
      public_key = `base64 --wrap=0 #{loc}.pub`.chomp


      known_host_key = File.read("#{loc}.pub")

      $logger.info({ known_host_key: known_host_key.chomp,
                     text: "Created key pair" })

      filename = File.join(File.expand_path("~"),
                           ".ssh",
                           "id_rsa.pub")

      master_public_key = File.open(filename).read()

      body = { "runcmd" => ["echo hi > /root/america",
                            "rm /etc/ssh/etc/ssh/ssh_host_ecdsa*",
                            "echo #{private_key} > /tmp/base64_pri && base64 --decode /tmp/base64_pri > /etc/ssh/ssh_host_ecdsa_key",
                            "echo #{public_key} > /tmp/base64_pub && base64 --decode /tmp/base64_pub > /etc/ssh/ssh_host_ecdsa_key.pub",
                            "chmod 600 /etc/ssh/ssh_host_ecdsa_key",
                            "chmod 644 /etc/ssh/ssh_host_ecdsa_key.pub",
                            "sleep 1 && service ssh restart"
                           ] }

      user_data = "#cloud-config\n#{body.to_yaml}"

      File.write("/tmp/cloud_config.yaml", user_data)

      droplet = DropletKit::Droplet.new(name: name,
                                        region: region,
                                        image: 'ubuntu-14-04-x64',
                                        size: '512mb',
                                        ssh_keys: [@ssh_key.id],
                                        user_data: user_data)

      @client.droplets.create(droplet)

      $logger.info({ text: "Created droplet", name: name })

      known_hosts << KnownHost.new(known_host_key, name)
    end

    self.increment_delay(3)
    self.update_known_hosts(known_hosts) if update_known_hosts
    self.increment_delay(15)
  end

  def update_known_hosts(known_hosts)
    self.droplets.map do |droplet|
      ip = droplet.networks.v4.first.ip_address

      known_hosts.map do |known_host|
        if known_host.name == droplet.name

          known_host.host = ip
          known_host.save!
          break
        end
      end
    end
  end

end

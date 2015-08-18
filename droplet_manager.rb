require "securerandom"
require "yaml"
require "openssl"

class DropletManager

  def initialize(client, task, ssh_key)

    @client = client
    @task = task.to_s

    raise "ssh_key required" if ssh_key.nil?
    @ssh_key = ssh_key

  end

  def droplets
    @client.droplets.all.select do |droplet|
      droplet.name.start_with? @task
    end
  end

  def destroy_all_droplets

    droplets.each do |droplet|
      @client.droplets.delete(id: droplet.id)
    end

  end

  def set_droplet_target(count)
    # 1% chance of collision after 10_000 generations.
    (droplets.length + 1).upto(count) do

      id = SecureRandom.hex(4)

      region = ["nyc1",
                "ams1",
                "sfo1",
                "nyc2",
                "ams2",
                "sgp1",
                "lon1",
                "nyc3",
                "ams3",
                "fra1"].sample

      key = OpenSSL::PKey::RSA.new(4096)
      user_data = { "ssh_keys" => { "rsa_private" => key.to_pem,
          "rsa_public" => key.public_key.to_pem } }

      puts "#cloud-config\n#{user_data.to_yaml}"

      raise

      droplet = DropletKit::Droplet.new(name: "#{@task}-#{id}",
                                        region: region,
                                        image: 'ubuntu-14-04-x64',
                                        size: '512mb',
                                        ssh_keys: [@ssh_key.id],
                                        user_data: user_data)
      @client.droplets.create(droplet)
    end

  end

end

require_relative "../lib/swell"

secrets = Secrets.new

client = DropletKit::Client
  .new(access_token: secrets.digital_ocean_key)

ssh_manager = SSHManager.new(client)
ssh_manager.add_pub_key_if_not_exists( secrets.ssh_pub_key )

droplet_manager = DropletManager.new(client,
                                     "testing",
                                     ssh_manager.key)

droplet_manager.destroy_all_droplets

droplet_manager.set_droplet_target(1)

deployer = Deployer.new(droplet_manager)

deployer.instruct_all("date")

droplet_manager.destroy_all_droplets

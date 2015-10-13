require_relative "../lib/swell"
require 'pry'
secrets = Secrets.new

client = DropletKit::Client
  .new(access_token: secrets.digital_ocean_key)

ssh_manager = SSHManager.new(client)
ssh_manager.add_pub_key_if_not_exists( secrets.ssh_pub_key )

droplet_manager = DropletManager.new(client,
                                     "research",
                                     ssh_manager.key)

#droplet_manager.destroy_all_droplets

binding.pry

exit

filenames = Dir.glob('urls/*.txt.??').map {|f| 
  File.join(File.expand_path('./'), f)
}

if filenames.count > 80
  raise "too many droplets check account limits"
end

droplet_manager.set_droplet_target(filenames.count)

deployer = Deployer.new(droplet_manager)

deployer.rsync_all("/home/zach/code/swell/scripts/start.sh")
deployer.instruct_all("bash start.sh")
deployer.rsync_all("/home/zach/code/swell/scripts/download.rb")

hosts = []
skip = true
droplet_manager.droplets.zip(filenames).map do |rec|
  droplet = rec[0]
  filename = rec[1]
  new_filename = filename + ".zip"
  `zip --junk-paths #{new_filename} #{filename}`
  deployer.rsync(droplet, new_filename)
  host = "root@#{droplet.networks.v4.first.ip_address}"
  hosts << host
  binding.pry unless skip
end

require 'pp'
pp hosts

deployer.instruct_all("screen -d -m ruby download.rb")
binding.pry
puts "finished instuctions"

# droplet_manager.destroy_all_droplets

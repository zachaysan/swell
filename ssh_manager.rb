class SSHManager

  attr_reader :key

  def initialize(client)
    @client = client
  end

  def add_pub_key_if_not_exists(pub_key)

    pub_key.chomp!

    # Use the hostname as the key name
    hostname = `hostname`.chomp

    raise "Empty key not allowed" if pub_key.blank?

    @client.ssh_keys.all.each do |key|
      @key = key and return if key.public_key.chomp == pub_key

      # If a key has been deleted by our host we delete it from
      # the acceptable key list in order to minimize the
      # chance that a leaked key is still considered valid.
      @client.ssh_keys.delete(key.id) if key.name == hostname
    end

    @key = @client.ssh_keys
      .create(Struct
                .new(:name, :public_key)
                .new(hostname, pub_key))
  end

end

# The long term plan here is to remove this class and
# replace it with a SSH Certificate Authority. But
# this works for now, and I have things to do.

class KnownHost

  attr_accessor :host, :name

  def initialize(public_key, name)
    @public_key = public_key
    @name = name
  end

  def to_s
    raise "Host required" unless host
    raise "Integer host not supported" if host.is_a? Integer
    @host = [@host] if @host.is_a? String
    hosts = @host.join(",")
    "#{hosts} #{@public_key}"
  end

  def save!
    known_hosts = File.join(File.expand_path("~"),
                            ".ssh",
                            "known_hosts")
    line = self.to_s

    open(known_hosts, 'a') do |f|
      f.puts line
    end
  end

  def hosts=(other)
    @host = other
  end

end

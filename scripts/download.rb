require 'securerandom'

`unzip *.txt.*.zip`
`rm *.txt.*.zip`

Dir.glob('*.txt.*') do |filename|
  `split -l 10000 #{filename} outfile.`
  `rm #{filename}`
end

Dir.glob('outfile.*') do |filename|
  processes = `nproc`.chomp.to_i
  `cat #{filename} | parallel -j #{processes * 5} --gnu "wget -nc {}"`
  `rm #{filename}`
  `zip #{SecureRandom.uuid} *geneneighb*`
  `rm *geneneighb*`
end

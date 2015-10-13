set -e

apt-get update
apt-get -y install ruby-full parallel zip unzip
ruby --version
echo "setup complete"

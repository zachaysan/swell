set -e

apt-get update
apt-get -y install ruby-full
ruby --version
echo "setup complete"

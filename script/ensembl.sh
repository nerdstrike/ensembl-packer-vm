#!/bin/bash -eux

echo "Doing system update to avoid user being hit with the Software Updater"
sudo apt-get update && sudo apt-get -y dist-upgrade

# Install extras needed by Ensembl API

# Perl modules
debconf-set-selections <<< 'mysql-server mysql-server/root_password password ensembl'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password ensembl'
apt-get install -y libdbi-perl libdbd-mysql libdbd-mysql-perl sqlite3 libmysqlclient-dev mysql-server
#apt-get install -y cpanminus libdbi-perl libdbd-mysql libdbd-mysql-perl sqlite3

# We need git and other build essentials
apt-get install -y git build-essential

# Install emacs
apt-get install -y emacs24

# Puppet modules
puppet module install puppetlabs-vcsrepo
puppet module install camptocamp-archive
puppet module install puppetlabs-stdlib

# Set up environment
echo >> /home/ensembl/.bashrc
echo "export PERL5LIB=$HOME/ensembl-api-folder/ensembl/modules:$HOME/ensembl-api-folder/ensembl-compara/modules:$HOME/ensembl-api-folder/ensembl-external/modules:$HOME/ensembl-api-folder/ensembl-funcgen/modules:$HOME/ensembl-api-folder/ensembl-variation/modules:$HOME/ensembl-api-folder/ensembl-variation/scripts/import:$HOME/ensembl-api-folder/ensembl-io/modules:$HOME/ensembl-api-folder/ensembl-hive/modules:$HOME/ensembl-api-folder/ensembl-test/modules:$HOME/ensembl-api-folder/bioperl-live:$PERL5LIB" >> /home/ensembl/.bashrc

echo >> /home/ensembl/.bashrc
echo "export PATH=$PATH:$HOME/ensembl-git-tools/bin:$HOME/ensembl-api-folder/ensembl-variation/C_code:$HOME/ensembl-api-folder/tabix" >> /home/ensembl/.bashrc
echo "# This MUST be set for LWP::Simple to retrieve cache files back from the Ensembl FTP site" >> /home/ensembl/.bashrc
echo "export FTP_PASSIVE=1" >> /home/ensembl/.bashrc

# Install MATE desktop
sudo apt-add-repository -y ppa:ubuntu-mate-dev/ppa
sudo apt-add-repository -y ppa:ubuntu-mate-dev/trusty-mate
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y --no-install-recommends ubuntu-mate-core ubuntu-mate-desktop

# Install Chromium
apt-get -y install chromium-browser

# Make Desktop symlinks
(cd /home/ensembl/Desktop ; ln -s /home/ensembl/VEP)
(cd /home/ensembl/Desktop ; ln -s /home/ensembl/ensembl-api-folder)

# Install Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt-get update 
#sudo apt-get install -y google-chrome-stable

# Set desktop icons executable
chmod +x /home/ensembl/Desktop/*.desktop

# Set background image
echo "Set background image"
gsettings set org.gnome.desktop.background picture-uri "file:///home/ensembl/Pictures/ebang-1440-900.png"
cp /home/ensembl/Pictures/ebang-1440-900.png /usr/share/backgrounds/warty-final-ubuntu.png

# Hack for future parser
echo "Puppet parser settings, future"
echo "parser = future" >>/etc/puppet/puppet.conf

# Auto Login
mkdir /etc/lightdm/lightdm.conf.d
echo "[SeatDefaults]" >/etc/lightdm/lightdm.conf.d/50-myconfig.conf
echo "autologin-user=ensembl" >>/etc/lightdm/lightdm.conf.d/50-myconfig.conf

mysql -uroot --password=ensembl -h localhost <<EOF
CREATE USER 'travis'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'travis'@'localhost';
exit
EOF

cat <<EOF >/home/lock_disable.sh
/usr/bin/gsettings set org.gnome.desktop.screensaver lock-enabled false
EOF

sudo chmod +x /home/lock_disable.sh

cat <<EOF >/etc/xdg/autostart/lock_disable.sh.desktop
[Desktop Entry]
Type=Application
Exec=/home/lock_disable.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=LockScreen Disabled
Comment=Disable the lock screen
EOF

# Removing Amazon search results
sudo rm -f /usr/share/applications/ubuntu-amazon-default.desktop

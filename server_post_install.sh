#! /bin/bash

###################################
#         add repositories        #
###################################

echo adding repositories
# sudo add-apt-repository -y "deb http://dl.google.com/linux/chrome/deb/ stable main"
#sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

###################################
#         Basic Update            #
###################################

echo updating system
sudo dpkg --configure -a > /dev/null
sudo apt-get -qq update  > /dev/null
sudo apt-get -qq upgrade > /dev/null

###################################
#      install and unistall apps  #
###################################

echo installing new apps
sudo apt-get -qq install \
    ssh git gitk gitg curl gparted \
    dkms python3-pip rygel

sudo apt-get -y -qq remove \


###################################
#      install python libraries   #
###################################

echo installing python libraries
sudo pip3 install \
	homeassistant

###################################
#      Updating dotfiles          #
###################################
echo installing configuration files
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' ~/.bashrc


###################################
#      Setting up Github          #
###################################
    
mkdir ~/projects 

echo downloading the github files
git -C ~/projects clone https://github.com/marcwagner/install_scripts.git
git -C ~/projects clone https://github.com/pi-hole/pi-hole.git


###################################
#      Setting up backup script   #
###################################


echo installing foto backup system

echo - creating user fotosync
sudo useradd -m -d /home/fotosync fotosync

echo - adding mounts to fstab 
echo '//192.168.1.130/fotos /media/fotos                    cifs    username=foto_sync,password=Foto_1234,rw,noexec   0       0' | sudo tee -a /etc/fstab
echo '//192.168.1.130/Documents /media/documents            cifs    username=foto_sync,password=Foto_1234,rw,noexec   0       0' | sudo tee -a /etc/fstab 
echo - creating mount points
sudo mkdir /media/fotos && sudo chown fotosync:fotosync /media/fotos
sudo mkdir /media/documents && sudo chown fotosync:fotosync /media/documents

echo - creating home dir folder structure
sudo mkdir /home/fotosync/scripts
sudo mkdir /home/fotosync/documents
sudo mkdir /home/fotosync/fotos
sudo mkdir /home/fotosync/documents/monthly
sudo mkdir /home/fotosync/documents/daily
sudo mkdir /home/fotosync/fotos/monthly
sudo mkdir /home/fotosync/fotos/daily

echo - copying scripts
cp ~/projects/install_scripts/backups/* /home/fotosync/scripts/

echo - setting the correct file ownerships
sudo chown -R fotosync:fotosync /home/fotosync

echo - mounting laptop fotos
sudo mount -a

echo - setting crontab
sudo su -c '(crontab -l 2>/dev/null; echo " 10 20  *   *   *     /home/fotosync/scripts/daily_sync.sh") | crontab -' fotosync
sudo su -c '(crontab -l 2>/dev/null; echo "  0 20  *   *   *     /home/fotosync/scripts/monthly_sync.sh") | crontab -' fotosync



###################################
#   setting up rygel upnp server  #
###################################

echo setting up upnp sharing
echo creating user rygel
sudo useradd -m rygel
echo - setting up share folders
sudo mkdir /share
sudo mkdir /share/music/

sudo cp ~/projects/install_scripts/upnp/rygel.conf /etc/rygel.conf
sudo cp ~/projects/install_scripts/upnp/rygel@rygel.service /etc/systemd/system/rygel@rygel.service

sudo systemctl --system daemon-reload
sudo systemctl enable rygel@rygel.service
sudo systemctl start rygel@rygel.service



###################################
#  setting up pi-hole add-blocker #
###################################

echo installing pi-hole
echo - copying configuration files

sudo mkdir /etc/pihole/
sudo cp ~/projects/install_scripts/pihole/setupVars.conf /etc/pihole/setupVars.conf
echo - downloading and running the pihole setup script
curl -L https://install.pi-hole.net | sudo bash /dev/stdin --unattended



###################################
#   setting up homeassistant      #
###################################


echo setting up homeassistant
echo - creating user homeassistant
sudo useradd -m homeassistant
sudo mkdir /.homeassistant/

echo - copying congiguration files
sudo cp ~/projects/install_scripts/homeassistant/*.yaml /home/homeassistant/
sudo cp ~/projects/install_scripts/homeassistant/homeassistant@homeassistant.service /etc/systemd/system/homeassistant@homeassistant.service



echo - starting homeassistant service
sudo systemctl --system daemon-reload
sudo systemctl enable homeassistant@homeassistant.service
sudo systemctl start homeassistant@homeassistant.service



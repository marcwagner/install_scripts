#! /bin/bash

# add repositories

sudo add-apt-repository -y "deb http://dl.google.com/linux/chrome/deb/ stable main"
sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -



# basic update
sudo apt-get -y --force-yes update
sudo apt-get -y --force-yes upgrade



#install apps
sudo apt-get -y install \
    git gitk gitg virtualbox virtualbox-guest-additions-iso curl gparted \
    dkms google-chrome-stable screen python3-pip


# uninstall apps
sudo apt-get -y remove \
	firefox	


#install python libraries

sudo pip3 install esptool


#update dotfiles
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' ~.bashrc

    
# folders
rm -rf ~/Documents
rm -rf ~/Public
rm -rf ~/Templates
rm -rf ~/Videos
rm -rf ~/Music
rm ~/examples.desktop
mkdir ~/projects


# github repositories
setiing up github
cd ~/projects

git config --global user.email "wagner.marc@gmail.com"
git config --global user.name "Marc Wagner"

git clone https://github.com/micropython/webrepl.git



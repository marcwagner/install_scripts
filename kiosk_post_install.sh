#kiosk script

###################################
#         setting up users        #
###################################

echo setting up user accounts

###################################
#         Basic cleanup          #
###################################

echo purging unneeded apps

sudo apt-get purge wolfram-engine scratch scratch2 nuscratch sonic-pi idle3 -y
sudo apt-get purge smartsim java-common minecraft-pi libreoffice* -y

###################################
#      install and unistall apps  #
###################################

echo installing new apps
sudo apt-get -qq install \
    ssh git git-secret gitk gitg curl \
    dkms python3-pip nmap \
    nfs-kernel-server \
    xdotool unclutter sed

sudo apt-get clean
sudo apt-get autoremove -y

echo updating system
sudo dpkg --configure -a > /dev/null
sudo apt-get -qq update  > /dev/null
sudo apt-get -qq upgrade > /dev/null


###################################
#      configuring the host       #
###################################
echo configuring the host
echo '... setting hostname'
echo -e 'magic-mirror' | sudo tee /etc/hostname
echo -e '127.0.0.1     magic-mirror' | sudo tee -a /etc/hosts


echo '... setting screen orientation'
echo -e '# configuration for magic mirror\ndisplay_rotate=1\navoid_warnings=1' | sudo tee -a /boot/config.txt

# expected output
#  # configuration for magic mirror
#  display_rotate=1
#  avoid_warnings=1


echo '...disabling screensaver and screen_blanking'

#echo -e 'consoleblank=0' | sudo tee -a /boot/cmdline.txt
#rm ~/.xscreensaver
#ln -s ~/projects/install_scripts/magicmirror/.xscreensaver ~/.xscreensaver
# xscreensaver does not need a restart because it automatically reloads if the config file has changed

iwconfig wlan0 power off

###################################
#       setting up VNC server     #
###################################
echo setting up vnc server

mkdir ~/.config/autostart
ln -s ~/projects/install_scripts/magicmirror/x11vnc.desktop ~/.config/autostart/x11vnc.desktop

echo setting up password
mkdir ~/.vnc
ln -s ~/projects/install_scripts/magicmirror/passwd ~/.vnc/passwd

x11vnc --usepw


#####################################
# Unclutter - removes mouse pointer #
#####################################

unclutter -idle 0.5 -root &

#####################################
#   some screen namenament stuff    #
#####################################

#sed -i 's/"@xscreensaver -no-splash"/"#@xscreensaver -no-splash"/'
#@bash /home/kiosk/kiosk.sh

## rotate screen:
# /boot/config.txt
# lcd_rotate=2




#####################################
# installing snips voice platform   #
#####################################

sudo apt-get update
sudo apt-get install -y dirmngr
sudo bash -c  'echo "deb https://raspbian.snips.ai/$(lsb_release -cs) stable main" > /etc/apt/sources.list.d/snips.list'
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys D4F50CDCA10A2849
sudo apt-get update
sudo apt-get install -y snips-platform-voice


#####################################
#     installing services           #
#####################################

mkdir ~/scripts
cd ~/scripts

wget https://github.com/marcwagner/install_scripts/raw/master/magicmirror/pi@mm_switch.service
wget https://github.com/marcwagner/install_scripts/raw/master/magicmirror/mm_switch.py
wget https://github.com/marcwagner/install_scripts/raw/master/magicmirror/pi@kiosk.service
wget https://github.com/marcwagner/install_scripts/raw/master/magicmirror/kiosk.sh

wget https://github.com/marcwagner/p1_python/raw/master/pi@p1_reader.service
wget https://github.com/marcwagner/p1_python/raw/master/p1_reader.py
wget https://github.com/marcwagner/p1_python/raw/master/serial_reader.py
wget https://github.com/marcwagner/p1_python/raw/master/converter.py

activating all the service files
sudo chown root:root pi@*
sudo mv pi@* /etc/systemd/system/

echo enabling services at boot
sudo systemctl enable pi@kiosk.services pi@mm_switch.services pi@p1_reader.services
sudo systemctl daemon-reload # Run if .service file has changed
sudo systemctl restart pi@kiosk.services pi@mm_switch.services pi@p1_reader.services

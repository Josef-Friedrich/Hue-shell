#! /bin/sh

# TP link
rsync -av --delete /home/jf/git-repositories/Hue-shell/ root@192.168.2.4:/root/hue/

# CoovaAP
scp -r /home/jf/git-repositories/Hue-shell/ root@192.168.2.99:/root/


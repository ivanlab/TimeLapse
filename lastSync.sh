#!/bin/bash
scp -v -P 6666 -i ~/.ssh/id_rsa_new huri@173.39.245.44:`ssh -p 6666 -i ~/.ssh/id_rsa_new huri@173.39.245.44 ls -1td /var/www/html/owncloud/data/timelapse/files/Photos/Timelapse/Fotos_JPG/\* | head -1` ~/Desktop/ultima/ultima.jpg

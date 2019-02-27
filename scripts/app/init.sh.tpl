#!/bin/bash

echo "export DB_HOST=mongodb://${private_ip}:27017/posts" >> /home/ubuntu/.bashrc
source /home/ubuntu/.bashrc

npm install
cd /home/ubuntu/app
pm2 start app.js

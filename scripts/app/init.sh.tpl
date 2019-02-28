#!/bin/bash

echo "export DB_HOST=mongodb://${private_ip}:27017/posts" >> /home/ubuntu/.bashrc
source /home/ubuntu/.bashrc

cd /home/ubuntu/app

npm install

sleep 30s

pm2 start app.js

#!/bin/bash

export DB_HOST="mongodb://${private_ip}:27017/posts"
cd /home/ubuntu/app
npm i
pm2 kill
pm2 start app.js

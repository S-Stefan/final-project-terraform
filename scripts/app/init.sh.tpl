#!/bin/bash

export DB_HOST="mongodb://${private_ip},${private_ip_secondary_1},${private_ip_secondary_2}:27017/posts"
cd /home/ubuntu/app
npm i
pm2 kill
pm2 start app.js

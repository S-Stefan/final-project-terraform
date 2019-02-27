#!/bin/bash

cd /home/ubuntu/app
npm install
pm2 start app.js

export DB_HOST="mongodb://${private_ip}:27017/posts"
export TEST="test"

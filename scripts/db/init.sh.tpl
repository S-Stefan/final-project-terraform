#!/bin/bash

mongo --eval 'rs.initiate({_id:"rs0", members: [{"_id":1, "host":"11.0.14.100:27017"}]})'
mongo --eval 'rs.add("11.0.15.100:27017")'
mongo --eval 'rs.add("11.0.16.100:27017")'

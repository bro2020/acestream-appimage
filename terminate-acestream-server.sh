#!/bin/bash
ps -aux | grep acestreamengine
/usr/bin/pkill --signal SIGHUP acestreamengine
sleep 2
ps -aux | grep acestreamengine

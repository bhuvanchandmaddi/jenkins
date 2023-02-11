#!/bin/bash

# Starts ssh

/usr/sbin/sshd

# Starts php process in background

/usr/sbin/php-fpm -c /etc/php/fpm

# Starts nginx daemon

/usr/local/nginx -g 'daemon off;'

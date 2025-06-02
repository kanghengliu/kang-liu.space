#!/bin/sh

zola build && rsync -av --delete ./public/ omen:~/hdd/apps/swag/config/www/

#!/bin/bash

# Ensure you have permissions to search and execute commands
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# The command you wish to execute

# Find all wp-config.php files
find /var/www/clients/ -type f -name wp-links-opml.php 2>/dev/null | while read -r FILE_PATH; do

    rm -rf /tmp/.wp-cli
    # Get the directory of the file
    DIR_PATH=$(dirname "$FILE_PATH")

    # Get the owner of the file
    FILE_OWNER=$(stat -c '%U' "$FILE_PATH")

    export WP_CLI_CACHE_DIR=/tmp/.wp-cli/cache

    # Execute command as that user in the directory of the found file
    sudo -u "$FILE_OWNER" -E sh -c "cd $DIR_PATH && wp option get siteurl && wp core version && wp core update && wp theme update --all && wp plugin update --all && wp core language update"
done

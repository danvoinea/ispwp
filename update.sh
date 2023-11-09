#!/bin/bash

cd /tmp

# Ensure you have permissions to search and execute commands
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

#Install wp cli
if ! command -v wp &> /dev/null
then
    echo "wp cli could not be found - installing"
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
fi

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

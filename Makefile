BASEDIR = $(CURDIR)

CONFIG_DIR = $(BASEDIR)/etc/config
UNARCHIVE_DIR = $(BASEDIR)/tmp
SOFTWARE_DIR = $(BASEDIR)/var/software
PUBLIC_HTML = $(BASEDIR)/var/www
LOG_DIR = $(BASEDIR)/var/log

MYSQL_USER = webdev
MYSQL_PASS = webdev
MYSQL_DBNAME = wp_simple

WEB_USER = www-data:www-data

.PHONY: install-wordpress create-wpdb
.PHONY: init-project

install-wordpress: init-project $(PUBLIC_HTML)/wp-load.php
	@echo "Wordpress Installed"


$(PUBLIC_HTML)/wp-load.php: $(UNARCHIVE_DIR)/wordpress
	@echo "Installing Wordpress"
	@cp -r $(UNARCHIVE_DIR)/wordpress/* $(PUBLIC_HTML)/
	@mysql -u$(MYSQL_USER) -p$(MYSQL_PASS) -Bse "CREATE DATABASE IF NOT EXISTS $(MYSQL_DBNAME);"

$(UNARCHIVE_DIR)/wordpress/: $(SOFTWARE_DIR)/wordpress.tar.gz
	@echo "Unarchiving Wordpress"
	@tar zxf $(SOFTWARE_DIR)/wordpress.tar.gz --directory $(UNARCHIVE_DIR)/

$(SOFTWARE_DIR)/wordpress.tar.gz:
	@echo "Downloading Wordpress"
	@wget -O $(SOFTWARE_DIR)/wordpress.tar.gz https://wordpress.org/latest.tar.gz


init-project: $(UNARCHIVE_DIR)/ $(SOFTWARE_DIR)/ $(PUBLIC_HTML)/ $(LOG_DIR)/

$(LOG_DIR)/:
	@mkdir -p $(LOG_DIR)

$(PUBLIC_HTML)/:
	@mkdir -p $(PUBLIC_HTML)

$(SOFTWARE_DIR)/:
	@mkdir -p $(SOFTWARE_DIR)

$(UNARCHIVE_DIR)/:
	@mkdir -p $(UNARCHIVE_DIR)

BASEDIR = $(CURDIR)

CONFIG_DIR = $(BASEDIR)/etc/config
UNARCHIVE_DIR = $(BASEDIR)/tmp
SOFTWARE_DIR = $(BASEDIR)/var/software
PUBLIC_HTML = $(BASEDIR)/var/www
LOG_DIR = $(BASEDIR)/var/log
TEMPLATE_DIR = $(BASEDIR)/etc/opt

SITES_AVAILABLE = /etc/nginx/sites-available
SITES_ENABLED = /etc/nginx/sites-enabled

MYSQL_USER = webdev
MYSQL_PASS = webdev
MYSQL_DBNAME = wp_simple

DOMAIN = devbox-php5.dev

.PHONY: install-wordpress create-wpdb
.PHONY: init-project init-config

install-wordpress: init-project init-config $(PUBLIC_HTML)/wp-config.php
	@echo "Wordpress Installed"

$(PUBLIC_HTML)/wp-config.php: $(PUBLIC_HTML)/wp-load.php
	@cat $(TEMPLATE_DIR)/wp-config.php.template |  \
	sed -e "s/%%MYSQL_USER%%/$(MYSQL_USER)/"      \
	    -e "s/%%MYSQL_PASS%%/$(MYSQL_PASS)/"      \
	    -e "s/%%MYSQL_DBNAME%%/$(MYSQL_DBNAME)/"  > $(PUBLIC_HTML)/wp-config.php

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


init-config: $(SITES_ENABLED)/$(DOMAIN)

$(SITES_ENABLED)/$(DOMAIN): $(SITES_AVAILABLE)/$(DOMAIN)
	@sudo ln -s $(SITES_AVAILABLE)/$(DOMAIN) $(SITES_ENABLED)/$(DOMAIN)
	@sudo service nginx restart

$(SITES_AVAILABLE)/$(DOMAIN): $(CONFIG_DIR)/$(DOMAIN).conf
	@sudo ln -s $(CONFIG_DIR)/$(DOMAIN).conf $(SITES_AVAILABLE)/$(DOMAIN)

$(CONFIG_DIR)/$(DOMAIN).conf: $(CONFIG_DIR)/
	@cat $(TEMPLATE_DIR)/nginx.conf.template |      \
	sed -e "s|%%DOMAIN%%|$(DOMAIN)|"                \
	    -e "s|%%DOCUMENT_ROOT%%|$(PUBLIC_HTML)|"    \
	    -e "s|%%LOG_DIR%%|$(LOG_DIR)|"              > $(CONFIG_DIR)/$(DOMAIN).conf

init-project: $(UNARCHIVE_DIR)/ $(SOFTWARE_DIR)/ $(PUBLIC_HTML)/ $(LOG_DIR)/ $(CONFIG_DIR)/

$(CONFIG_DIR)/:
	@mkdir -p $(CONFIG_DIR)

$(LOG_DIR)/:
	@mkdir -p $(LOG_DIR)

$(PUBLIC_HTML)/:
	@mkdir -p $(PUBLIC_HTML)

$(SOFTWARE_DIR)/:
	@mkdir -p $(SOFTWARE_DIR)

$(UNARCHIVE_DIR)/:
	@mkdir -p $(UNARCHIVE_DIR)

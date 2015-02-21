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
WEB_USER = www-data:www-data

WP_PLUGINS_DIR = $(PUBLIC_HTML)/wp-content/plugins

YOAST_ZIP = wordpress-seo.1.7.3.1.zip
YOAST_PLUGIN = wordpress-seo

WOOCOMMERCE_ZIP = woocommerce.2.3.5.zip
WOOCOMMERCE_PLUGIN = woocommerce

STRIPE_ZIP = stripe-for-woocommerce.zip
STRIPE_PLUGIN = stripe-for-woocommerce

.PHONY: install-wordpress install-plugins
.PHONY: install-yoast install-woocommerce
.PHONY: init-project init-config
.PHONY: clean clean-config clean-wpdb

install: install-wordpress install-plugins


install-wordpress: init-project init-config $(PUBLIC_HTML)/wp-config.php

$(PUBLIC_HTML)/wp-config.php: $(PUBLIC_HTML)/wp-load.php
	@cat $(TEMPLATE_DIR)/wp-config.php.template |     \
	     sed -e "s/%%MYSQL_USER%%/$(MYSQL_USER)/"      \
	         -e "s/%%MYSQL_PASS%%/$(MYSQL_PASS)/"       \
	         -e "s/%%MYSQL_DBNAME%%/$(MYSQL_DBNAME)/"    > $(PUBLIC_HTML)/wp-config.php
	@# sudo chown -R $(WEB_USER) $(PUBLIC_HTML)
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
	@wget -nv -O $(SOFTWARE_DIR)/wordpress.tar.gz https://wordpress.org/latest.tar.gz


install-plugins: install-wordpress install-yoast install-woocommerce install-stripe


install-yoast: $(WP_PLUGINS_DIR)/$(YOAST_PLUGIN)/

$(WP_PLUGINS_DIR)/$(YOAST_PLUGIN)/: $(UNARCHIVE_DIR)/$(YOAST_PLUGIN)/
	@cp -r $(UNARCHIVE_DIR)/$(YOAST_PLUGIN) $(WP_PLUGINS_DIR)/
	@echo "Wordpress SEO by Yoast installed"

$(UNARCHIVE_DIR)/$(YOAST_PLUGIN)/: $(SOFTWARE_DIR)/$(YOAST_ZIP)
	@echo "Unarchiving Wordpress SEO by Yoast"
	@unzip -q $(SOFTWARE_DIR)/$(YOAST_ZIP) -d $(UNARCHIVE_DIR)/

$(SOFTWARE_DIR)/$(YOAST_ZIP):
	@echo "Downloading Wordpress SEO by Yoast"
	@wget -nv -O $(SOFTWARE_DIR)/$(YOAST_ZIP) https://downloads.wordpress.org/plugin/$(YOAST_ZIP)


install-woocommerce: $(WP_PLUGINS_DIR)/$(WOOCOMMERCE_PLUGIN)/

$(WP_PLUGINS_DIR)/$(WOOCOMMERCE_PLUGIN)/: $(UNARCHIVE_DIR)/$(WOOCOMMERCE_PLUGIN)/
	@cp -r $(UNARCHIVE_DIR)/$(WOOCOMMERCE_PLUGIN) $(WP_PLUGINS_DIR)/
	@echo "WooCommerce installed"

$(UNARCHIVE_DIR)/$(WOOCOMMERCE_PLUGIN)/: $(SOFTWARE_DIR)/$(WOOCOMMERCE_ZIP)
	@echo "Unarchiving WooCommerce"
	@unzip -q $(SOFTWARE_DIR)/$(WOOCOMMERCE_ZIP) -d $(UNARCHIVE_DIR)/

$(SOFTWARE_DIR)/$(WOOCOMMERCE_ZIP):
	@echo "Downloading WooCommerce"
	@wget -nv -O $(SOFTWARE_DIR)/$(WOOCOMMERCE_ZIP) https://downloads.wordpress.org/plugin/$(WOOCOMMERCE_ZIP)


install-stripe: install-woocommerce $(WP_PLUGINS_DIR)/$(STRIPE_PLUGIN)/

$(WP_PLUGINS_DIR)/$(STRIPE_PLUGIN)/: $(UNARCHIVE_DIR)/$(STRIPE_PLUGIN)/
	@cp -r $(UNARCHIVE_DIR)/$(STRIPE_PLUGIN) $(WP_PLUGINS_DIR)
	@echo "Stripe for WooCommerce installed"

$(UNARCHIVE_DIR)/$(STRIPE_PLUGIN)/: $(SOFTWARE_DIR)/$(STRIPE_ZIP)
	@echo "Unarchiving Stripe for WooCommerce"
	@unzip -q $(SOFTWARE_DIR)/$(STRIPE_ZIP) -d $(UNARCHIVE_DIR)

$(SOFTWARE_DIR)/$(STRIPE_ZIP):
	@echo "Downloading Stripe for WooCommerce"
	@wget -nv -O $(SOFTWARE_DIR)/$(STRIPE_ZIP) https://downloads.wordpress.org/plugin/$(STRIPE_ZIP)


init-config: $(SITES_ENABLED)/$(DOMAIN)

$(SITES_ENABLED)/$(DOMAIN): $(SITES_AVAILABLE)/$(DOMAIN)
	@sudo ln -s $(SITES_AVAILABLE)/$(DOMAIN) $(SITES_ENABLED)/$(DOMAIN)
	@sudo service nginx restart

$(SITES_AVAILABLE)/$(DOMAIN): $(CONFIG_DIR)/$(DOMAIN).conf
	@sudo ln -s $(CONFIG_DIR)/$(DOMAIN).conf $(SITES_AVAILABLE)/$(DOMAIN)

$(CONFIG_DIR)/$(DOMAIN).conf: $(CONFIG_DIR)/
	@echo "Setting up NginX config"
	@cat $(TEMPLATE_DIR)/nginx.conf.template |         \
	     sed -e "s|%%DOMAIN%%|$(DOMAIN)|"               \
	         -e "s|%%DOCUMENT_ROOT%%|$(PUBLIC_HTML)|"    \
	         -e "s|%%LOG_DIR%%|$(LOG_DIR)|"               > $(CONFIG_DIR)/$(DOMAIN).conf

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

clean: clean-config clean-wpdb
	@echo "Clearing down created directories"
	@rm -rf $(UNARCHIVE_DIR) $(PUBLIC_HTML) $(CONFIG_DIR)
	@rm -rf $(LOG_DIR)

clean-config:
	@echo "Removing NginX config"
	@sudo rm -rf $(SITES_ENABLED)/$(DOMAIN) $(SITES_AVAILABLE)/$(DOMAIN)
	@sudo service nginx stop && rm -rf $(LOG_DIR)/* && sudo service nginx start

clean-wpdb:
	@echo "Dropping database $(MYSQL_DBNAME)"
	@mysql -u$(MYSQL_USER) -p$(MYSQL_PASS) -Bse "DROP DATABASE IF EXISTS $(MYSQL_DBNAME);"

make-wordpress (WooCommerce)
============================

Building out-of-the-box working instances of WordPress from a Makefile. The intended server environment is Ubuntu 14.04 running NginX and PHP-FPM (PHP 5.5). You can find a suitable vagrant setup in the `ubuntu-14.04` branch of https://github.com/isofarro/devbox-php5

Platform requirements:

* Ubuntu 14.04 LTS
* PHP 5.5.9 (default package), and `php5-fpm`
* NginX 1.4.6 (default package)

Plugins installed:

* Wordpress SEO by Yoast (v1.7.3.1)
* WooCommerce (v2.3.5)
* Stripe for WooCommerce (v1.36)

Steps
-----

1. Checkout this repository
2. `make install`
3. Do the Wordpress setup through the browser



From scratch set up:
--------------------

Setting up a new dev box (PHP5.5 on Ubuntu 14.04):

1. `wget https://github.com/isofarro/devbox-php5/archive/ubuntu-14.04.zip`
2. `unzip ubuntu-14.04.zip`

Creating your new project:

1. `git clone -b woocommerce https://github.com/isofarro/make-wordpress.git YOUR_NEW_PROJECT`
2. `cd YOUR_NEW_PROJECT/ && rf -rf .git/ && git init && cd ..`

Start dev environment:

1. `cd devbox-php5-ubuntu-14.04/`
2. `vagrant up` -- this takes a few minutes to create and build a new VirtualBox environment
3. `vagrant ssh`
4. `cd Projects/YOUR_NEW_PROJECT/`
5. `make install`


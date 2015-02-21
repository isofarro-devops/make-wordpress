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



Name
====

riot-openresty

Description
===========

riotjs application using openresty as API

Prerequisites
=============

* openresty
* npm

Usage
=====

* install html dependency: `cd html && npm install`
* clone [lua-resty-stack](http://github.com/antonheryanto/lua-resty-stack) to lib
* link or copy: `cp lib/lua-resty-stack/lib/resty .`
* run openresty: `nginx -p. -c conf/nginx.conf`
* [browse](http://localhost:8000)

Author
======

Anton Heryanto Hasan <anton.heryanto@gmail.com>
License MIT

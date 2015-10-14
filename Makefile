mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
DIR = $(dir $(mkfile_path))
NGINX = nginx

start: 
	@$(NGINX) -p $(DIR) 

stop: 
	@$(NGINX) -p $(DIR) -s quit

restart: stop start

reload: 
	@$(NGINX) -p $(DIR) -s reload

prepare: 
	@mkdir -p resty && cd resty && ln -sf ../lib/*/lib/resty/* .
	@cd html && npm install && npm run build

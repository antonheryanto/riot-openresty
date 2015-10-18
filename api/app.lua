require 'resty.core'
local redis = require 'resty.redis'
local stack = require 'resty.stack'
local config = require 'api.config'
local auth = require 'api.auth'
local insert = table.insert
local concat = table.concat
local pairs = pairs
local shared_db = ngx.shared.db
local say = ngx.say
local log = ngx.log
local WARN = ngx.WARN
local ERR = ngx.ERR
local exit = ngx.exit
local STATUS = {
    [500] = 'Service Error',
    [401] = 'Service Require Authentication',
    [404] = 'Service Not found'
}

local function ngx_db(self)
    return shared_db
end

local function redis_db(self)
    local config = self.config.redis or {}
    local db  = redis:new()
    self.redis = db
    db.delete = db.del
    db.incr = db.incrby
    db:set_timeout(config.timeout or 1000)
    local ok, err = db:connect(config.host or '127.0.0.1', config.port or 6379)
    if ok then return db end
        
    log(ERR, 'connection fail: ', err)
    exit(500)
end

-- init db
local function init_db(self)
    local db = self:db()
    db:set('user', 1)
    db:set('email:anton.heryanto@gmail.com', 1)
    db:set('user:1:email', 'anton.heryanto@gmail.com')
    db:set('user:1:name', 'Anton Heryanto')
end

-- validate config
local db = config.db == 'redis' and redis_db or ngx_db
if config.db ~= 'redis' then init_db({ db = db }) end

local app = stack:new(config)

function app.begin_request(param) 
    param.db = db 
end

function app.end_request(param)
    if not param.redis then return end
    local config = param.config.redis or {}
    local db = param.redis
    local times, err = db:get_reused_times()
    log(WARN, not err and 'reused: '.. times or  ' error: '.. err)
    local ok, err = db:set_keepalive(config.keep_idle or 10000, 
        config.keep_size or 100)
    if not ok then log(WARN, 'fail to keepalive: ', err) end
end

app.authorize = auth.get
app:use('api/init', init_db)
app:use('api', function()
    local m = {}
    for k,v in pairs(app.services) do
        local perm = v.authorize and 'private' or 'public'
        insert(m, '  "'..k..'": "'..perm..'"')
    end
    return '{\n'..concat(m, ',\n')..'\n}'
end)
app:use('api/auth', auth)
app:use('api/user', 'api.user')
app:use('api/error', function()
    return { message = STATUS[ngx.status] }
end)
return app

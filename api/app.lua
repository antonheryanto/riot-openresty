require "resty.core" 
local auth = require 'api.auth'
local stack = require 'resty.stack'
local db = ngx.shared.db
local STATUS = {
    [401] = 'Service Require Authentication',
    [404] = 'Service Not found'
}
-- init db
db:set('email:anton.heryanto@gmail.com', 1)
db:set('user:1:name', 'Anton heryanto')

local app = stack:new({ debug = true })
app.authorize = auth.get_id
app:use('api', function()
    for k,v in pairs(app.services) do
        ngx.say(k)
    end
    return ''
end)
app:use('api/auth', auth)
app:use('api/user', 'api.user')
app:use('api/error', function()
    return { message = STATUS[ngx.status] }
end)
return app

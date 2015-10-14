require 'resty.core'
local auth = require 'api.auth'
local stack = require 'resty.stack'
local insert = table.insert
local concat = table.concat
local pairs = pairs
local db = ngx.shared.db
local say = ngx.say
local STATUS = {
    [401] = 'Service Require Authentication',
    [404] = 'Service Not found'
}
-- init db
db:set('user', 1)
db:set('email:anton.heryanto@gmail.com', 1)
db:set('user:1:email', 'anton.heryanto@gmail.com')
db:set('user:1:name', 'Anton Heryanto')

local app = stack:new({ debug = true })
app.authorize = auth.get
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

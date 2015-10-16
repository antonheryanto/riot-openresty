local user = require 'api.user'
local var = ngx.var
local time = ngx.time
local cookie_time = ngx.cookie_time
local md5 = ngx.md5
local null = ngx.null
local ex = { message = 'please provide username and password' }

local _M = {}

function _M.get(self)
    local token = self.arg.token or var.cookie_auth
    if not token then return end

    local db = self:db()
    local id = db:get('auth:'..token)
    return id and id ~= null and user.get(self, id), nil, token
end

function _M.post(self)
    local m = self.data or self.arg
    if not m.name or not m.password then return ex end
    
    local db = self:db()
    local id = db:get('email:'.. m.name)
    if not id or id == null or m.password ~= 'password' then return ex end

    local u, status, auth = user.get(self, id) 
    local expires = cookie_time(time() + 3600 * 24) -- 1 day
    if not auth or auth == null then
        auth = md5(expires)
        db:set('user:'..id..':auth', auth)
    end

    db:set('auth:'..auth, id)
    local header = ngx.header
    header['Set-Cookie'] = 'Auth=' .. auth  .. '; Path=/; Expires=' .. expires
    return u
end

function _M.delete(self)
    local u, status, token = _M.get(self) 
    if not u then return end

    local db = self:db()
    db:delete('auth:'..token)
    db:set('user:'..u.id..':auth:'..md5(time()))
end

return _M

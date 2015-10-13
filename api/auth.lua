local user = require 'api.user'
local var = ngx.var
local time = ngx.time
local cookie_time = ngx.cookie_time
local db = ngx.shared.db
local md5 = ngx.md5
local ex = { message = 'please provide username and password' }

local _M = {}

function _M.get_id(self)
    local token = self.arg.token or var.cookie_auth
    if not token then return end

    local id = db:get('auth:'..token)
    return id, token
end

function _M.get(self)
    local m = self.data or self.arg
    if not m.name or not m.password then
        local id = _M.get_id(self)
        return id and user.get(self, id) or ex
    end
    
    local id = db:get('email:'.. m.name)
    if not id or m.password ~= 'password' then
        return ex
    end

    if not id then return ex end

    local u, status, auth = user.get(self, id) 
    local expires = cookie_time(time() + 3600 * 24) -- 1 day
    if not auth then
        auth = md5(expires)
        db:set('user:'..id..':auth', auth)
    end

    db:set('auth:'..auth, id)
    local header = ngx.header
    header['Set-Cookie'] = 'auth=' .. auth  .. ';Expire=' .. expires
    return u
end

_M.post = _M.get

function _M.delete(self)
    local id, token = _M.get_id(self) 
    if not id then return end

    db:delete('auth:'..token)
    db:set('user:'..id..':auth:'..md5(time()))
end

return _M

local db = ngx.shared.db
local users = {1}
local _M = {}
_M.AUTHORIZE = true

local function one(self, id)
    if not id then return end

    return { 
        name = db:get('user:'..id..':name'), 
        id = id
    }, 200, db:get('user:'..id..':auth')
end

function _M.get(self, id)
    id = id or self.arg.id
    if id then return one(self, id) end

    local m = {}
    for i = 1, #users do
        m[i] = one(self, users[i])
    end

    return m
end

return _M

local properties = {'name', 'email'}
local np = #properties
local _M = {}
_M.AUTHORIZE = true

local function one(self, id)
    if not id then return end
    
    local db = self:db()
    local m = { id = id }
    local prefix = 'user:'..id..':'
    for i=1, np do
        local k = properties[i]
        m[k] = db:get(prefix .. k)
    end
    if not m.email then return end

    return m, nil, db:get('user:'..id..':auth')
end

function _M.get(self, id)
    id = id or self.arg.id
    if id then return one(self, id) end

    local db = self:db()
    local n = db:get('user')
    local m = {}
    local j = 1
    for i = 1, n do
        local v = one(self, i)
        if v then
            m[j] = one(self, i)
            j = j + 1
        end
    end

    return m
end

function _M.post(self)
    local m = self.data or self.arg
    local has_id = tonumber(m.id)
    if not has_id then
        m.id = db:incr('user', 1)
    end

    local prefix = 'user:'..m.id..':'
    db:set('email:'..m.email, m.id)
    for i=1, np do
        local k = properties[i]
        if m[k] then
            db:set(prefix .. k, m[k])
        end
    end
    return m
end

function _M.delete(self, id)
    id = id or self.arg.id
    if not id then return end
    
    local prefix = 'user:'..id..':'
    db:delete('email:', db:get(prefix..'email'))
    for i=1, np do
        db:delete(prefix .. properties[i])
    end
end

return _M

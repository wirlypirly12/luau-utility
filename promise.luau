local Class = loadstring(game:HttpGet("https://raw.githubusercontent.com/wirlypirly12/luau-utility/refs/heads/main/class.luau"))()
local Task = loadstring(game:HttpGet("https://raw.githubusercontent.com/wirlypirly12/luau-utility/refs/heads/main/task.luau"))()

local Promise = Class.new{
    name = "Promise"
}

function Promise.new(executor)
    local self = Promise:create("Promise")
    self._state = "pending"
    self._value = nil
    self._then = {}
    self._catch = {}
    self.task = Task.new()

    local function resolve(value)
        if self._state ~= "pending" then return end
        self._state = "complete"
        self._value = value
        self:run_all_then()
    end

    local function reject(reason)
        if self._state ~= "pending" then return end
        self._state = "rejected"
        self._value = reason
        self:run_all_catch()
    end

    local state = self.task:give_task(function()
        local ok, err = pcall(executor, resolve, reject)
        if not ok then
            reject(err)
        end
        self.task:close()
    end)
    if state == false then
        error("promise creation failed (failed to give task)", 1)
    end
    return self
end

function Promise:run_all_then()
    for i, callback in next, self._then do
        callback(self._value)
    end
end

function Promise:run_all_catch()
    for i, callback in next, self._catch do
        callback(self._value)
    end
end

function Promise:andThen(callback)
    if self._state == "complete" then
        callback(self._value)
    elseif self._state == "pending" then
        table.insert(self._then, callback)
    end


    -- im lazy.. ok?
    local promise = self
    local methods = {}
    function methods:catch(callback)
        return promise:catch(callback)
    end
    return methods
end

function Promise:catch(callback)
    if self._state == "rejected" then
        callback(self._value)
    elseif self._state == "pending" then
        table.insert(self._catch, callback)
    end
end


-- example:
-- local players = game:GetService("Players")
-- for i, player in next, players:GetPlayers() do
--     local promise_data = {}
--     local promise = Promise.new(function(resolve, reject)
--         promise_data.resolve = resolve
--         promise_data.reject = reject
--     end)
--     promise:catch(warn)
--     promise:andThen(print)

--     if player == players.LocalPlayer then
--         promise_data.reject("its you!")
--         continue
--     end

--     promise_data.resolve(`{player.Name} isn't you so its ok.`)
-- end

return Promise

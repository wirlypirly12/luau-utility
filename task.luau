-- :-)

local Class = loadstring(game:HttpGet("https://raw.githubusercontent.com/wirlypirly12/luau-utility/refs/heads/main/class.luau"))()

local Task = Class.new{
    name = "Task"
}

function Task.new(options)
    options = options or {}
    local self = Task:create(options.name or "New Task")
    if options.perframe then
        self.tasks = {}
        self:create_heartbeat()
    else self:create_thread() end
    
    self.options = options
    return self
end


function Task:create_heartbeat()
    self.run_service = game:GetService("RunService")
    self.heartbeat = self.run_service.Heartbeat:Connect(function(...)
        for i, tsk in next, self.tasks do
            tsk(...)
        end
    end)
end

function Task:close()
    if self.options.perframe then
        return self:close_heartbeat()
    else
        return self:close_thread()
    end
    table.clear(self)
end

function Task:close_thread()
    if not self.thread then
        return
    end
    coroutine.close(self.thread)
end

function Task:close_heartbeat()
    if not self.heartbeat then
        return
    end
    self.heartbeat:Disconnect()
end

function Task:create_thread()
    self.thread = coroutine.create(function()
        while true do
            local current_task = coroutine.yield()
            current_task()
        end
    end)
end

function Task:create_heartbeat_task(func)
    self.tasks[#self.tasks+1] = func
    return true
end

function Task:create_thread_task(func)
    if not self.thread then return false end
    coroutine.resume(self.thread, func)
    return true
end

function Task:give_task(vfunction)
    return self.tasks and self:create_heartbeat_task(vfunction) or self:create_thread_task(vfunction)
end

-- local render_task = Task.new()

-- local function myveryexpensivetask()
--     print("Herro World!")
-- end

-- for i = 1, 10 do
--     render_task:give_task(myveryexpensivetask)
-- end

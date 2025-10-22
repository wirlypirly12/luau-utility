local Class = setmetatable({}, {
    __tostring = function()
        return "Class"
    end
})

function Class:find_dependencies(d)
    local ok, missing = true, {}
    for i, dep in next, d or {} do
        local func = getgenv()[dep]
        if not func then
            table.insert(missing, dep)
            ok = false
        end
    end

    return ok, missing
end

function Class:proxy(func, module, args)
    -- ("format your %s plz"):format("strings")
    return func(`[{tostring(module)}] ->`,table.unpack(args))
end

function Class:create(class, name)
    local self = setmetatable({}, {
        __tostring = function()
            return name
        end,
        __index = class
    })
    return self
end

function Class.new(options)
    options = options or {}

    local base_class = setmetatable({
        name = options.name or "Unnamed class",
        dependencies = options.dependencies or {}
    }, {
        __tostring = function()
            return options.name or "?"
        end
    })

    local ok, missing = Class:find_dependencies(base_class.dependencies)
    if not ok then
        error(("missing %d dependencies: %s"):format(#missing, table.concat(missing, ", ")))
    end

    function base_class:log(...)
        return Class:proxy(warn, base_class, table.pack(...))
    end
    
    function base_class:create(name)
        return Class:create(base_class, name)
    end

    return base_class
end

return Class

-- local esp = Class.new{
--     name = "esp",
--     dependencies = {
--         "hookfunction"
--     }
-- }

-- function esp.new()
--     local self = esp:create("hi")
--     self:log("created a new esp object", "hi", "wattt")
--     return self
-- end

-- print(esp.new())

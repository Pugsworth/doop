--[[
    The Lua 5.0=>5.1 way of making modules involves using the "module()" function with "package.seeall".
    
    The Lua 5.2+ way of making modules involves using the "return" keyword at the end of the file.
--]]

-- Stores the created classes.
local _class_list = {}

-- library table
local doop = {}

--- Creates a new class definition object. From this, you can create new instances of the class.
---@param name string The name of the class
---@param constructor function The constructor function for the class. Called when a new instance is created.
---@param parent_class string? The name of the parent class
---@return table class_def The class definition table. From this, you can call .new or call directly as a function to create a new instance.
function doop.Class(name, constructor, parent_class)
    local class_def = {name=name, parent=parent_class}
    -- Instance methods table for the class
    class_def.prototype = {
        super = doop.getClass(parent_class)
    }
    -- Metamethods table for the class
    -- First checks the metatable of the instance, then checks the prototype.
    class_def.meta = {
        __index = class_def.prototype
    }

    setmetatable(class_def, class_def.meta)

    function class_def.new(self, ...)
        local instance = setmetatable({}, class_def.meta);
        constructor(instance, ...)
        return instance
    end

    class_def.meta.__call = class_def.new

    _class_list[name] = class_def

    return class_def
end

--- Returns a class definition if it exists
---@param name string? The name of the class
---@return table The class definition
function doop.getClass(name)
    return _class_list[name]
end

--- Creates a new instance of a class.
---@param name string The name of the class
function doop.create(name, ...)
    local class_def = _class_list[name]
    if not class_def then
        error(string.format("Class '%s' does not exist", name))
    end

    return class_def:new(...)
end




return doop
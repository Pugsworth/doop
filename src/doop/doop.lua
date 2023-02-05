--[[
    @file doop.lua
    @brief A simple class system for Lua.
    @version 1.0.0
    @author Kyle Wolsten
    @date 2022-
    @license GPL-3.0


    The Lua 5.0=>5.1 way of making modules involves using the "module()" function with "package.seeall".
    
    The Lua 5.2+ way of making modules involves using the "return" keyword at the end of the file.
--]]


-- Stores the created classes.
local _class_list = {}
local _interface_list = {}

-- library table
---@class doop
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
        super = doop.getClass(parent_class),
        implements = function(self, interface)
            return doop.implements(self, interface)
        end,
        instanceOf = function(self, class)
            return doop.instanceOf(self, class)
        end,
        getType = function(self)
            return doop.getType(self)
        end,
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


--- Creates a new instance of a class.
---@param name string The name of the class
function doop.create(name, ...)
    local class_def = _class_list[name]
    if not class_def then
        error(string.format("Class '%s' does not exist", name))
    end

    return class_def:new(...)
end


--[[
-- I was going to attempt to implement interfaces. I don't know if they are
-- even necessary. The point of an interface is to ensure that an object implements
-- the methods and properties. However, this isn't really necessary in a dynamic language
-- like Lua.
-- The best thing we could hope to accomplish without lots of metatable magic and the resulting
-- slowdown is to tell [doop] what "interface(s)" a class is supposed to implement.
-- This allows users of the class to quickly determine if a class should have certain methods/properties
-- i.e. ```class:implements("interface")``` or ```doop.implements(class, "interface")```
-- There would be no real enforcement of the interface besides maybe a default "NotImplemented" error.
function doop.interface(name)
    local interface = {name=name}
    interface.meta = {
        __index = interface
    }
end
--]]


--- Add an interface to a class
---@param class string|table The class to add the interface to. Can either be the name of the class or the class definition
---@param interface string The name of the interface.
function doop.implements(class, interface)
    if not doop.interfaceExists(interface) then
        error(string.format("Interface '%s' does not exist!!!", interface))
    end

    if type(class) == "table" and doop.isClass(class) then
        local implements = _class_list[class.name].implements or {}
        table.insert(implements, interface)
        _class_list[class.name].implements = implements
    end
end



--[[
    Guards and Checks
--]]

function doop.isClass(class)
    if class.name == nil then
        return false
    end


    return true
end


function doop.getType(class)
    if not doop.isClass(class) then
        return type(class)
    end

    return class.name
end


--- Returns a class definition if it exists
---@param name string? The name of the class
---@return table @The class definition
function doop.getClass(name)
    return _class_list[name]
end


--- Guard to check if a class is an instance of another class or interface.
--- This is mainly used for type checking in a function.
---@param obj table The object to check.
---@param type_name string The name of the class or interface to check for.
function doop.expects(obj, type_name)
    if not doop.isClass(obj) then
        error(string.format("'%s' is not a doop class!", obj))
    end

    if not doop.classExists(type_name) and not doop.interfaceExists(type_name) then
        error(string.format("Class or interface '%s' does not exist!!!", type_name))
    end

    -- Check if the class is an instance of the type.
    if not doop.instanceOf(obj, type_name) then
        -- If it's not an instance of the type, check if it's an interface.
        if not doop.implements(obj, type_name) then
            error(string.format("'%s' is not an instance of '%s'!", obj.name, type_name))
        end

        error(string.format("'%s' is not an instance of '%s'!", obj.name, type_name))
    end

    return true
end


--- Checks if a class says it implements an interface.
---@param class string|table The class to check.
---@param interface string The name of the interface to check for.
---@return boolean @True if the class implements the interface, false otherwise.
function doop.doesImplement(class, interface)
    if not doop.isClass(class) then
        error(string.format("'%s' is not a doop class!", class))
    end

    if not doop.interfaceExists(interface) then
        error(string.format("Interface '%s' does not exist!!!", interface))
    end

    -- TODO: add a method to the table library to check if a table contains a value
    -- table.contains(tab: table, value: any) -> boolean
    local implements = _class_list[class.name].implements or {}
    for _, v in ipairs(implements) do
        if v == interface then
            return true
        end
    end

    return false;
end


--- Checks if an interface has been defined.
---@param interface string The name of the interface to check for.
---@return boolean @True if the interface exists, false otherwise.
function doop.interfaceExists(interface)
    return _interface_list[interface] ~= nil
end


--- Check if a class is an instance of another class. This implies Class1 is instance of Class1.
---@param class table The class to check.
---@param parent table|string The parent class to check against.
---@return boolean @True if the class is an instance of the parent class, false otherwise.
function doop.instanceOf(class, parent)
    if not doop.isClass(class) then
        error(string.format("'%s' is not a doop class!", class))
    end

    if type(parent) == "string" then
        parent = doop.getClass(parent)
    end

    if not doop.isClass(parent) then
        error(string.format("'%s' is not a doop class!", parent))
    end

    if class.name == parent.name then
        return true
    end

    if class.parent == nil then
        return false
    end

    return doop.instanceOf(_class_list[class.parent], parent)
end



return doop
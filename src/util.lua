--- Default value function.
---@param a any
---@param b any
---@return any value Returns b if a is nil, otherwise returns a.
local function default(a, b)
    if a == nil then
        return b
    end

    return a
end

--- Calls print(string.format(fmt, ...))
---@param fmt string
---@vararg any
local function printf(fmt, ...)
    if select("#", ...) == 0 then
        print(fmt)
        return
    end

    print(string.format(fmt, ...))
end

--- Prints a table in a nice tree format. References previously printed tables and functions.
---@param tab table The table to print.
---@param depth number The maximum depth to print. Defaults to 99.
local function print_tree(tab, depth)
    depth = default(depth, 99)
end




return {
    default = default,
    printf = printf,
    print_tree = print_tree,
}

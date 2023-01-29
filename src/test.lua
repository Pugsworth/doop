--[[
    Library for running simple tests.
    
    This library does the typical "test", "describe", "it" thing in addition to providing
    some useful functions for testing like "should.be", "should.equal", etc.


    Example usage:
    local Test = require("test")

    Test.new(function(test)
        test.describe("Test", function()
            test.it("should work", function()
                test.should.equal(1, 1)
            end)

            test.it("should be true", function()
                test.should.be(false, true)
            end)
        end)
    end)

    Output:
    describe Test
        it should work
            ✅ 1 == 1
            ❌ false != true
--]]

local CHAR_PASSED = "✅"
local CHAR_FAILED = "❌"
local CHAR_SKIPPED = "⏭"
local INDENTATION = "\t"

local function tabulate(count)
    return string.rep(INDENTATION, count)
end

local function errorMsg(msg)
    print(string.format("%s%s %s", tabulate(2), CHAR_FAILED, msg))
end

local Test = {}




local function describe(name, func)
    print(string.format("describe '%s'", name))
    func()
end

local function it(name, func)
    print(string.format("%sit '%s'", tabulate(1), name))
    func()
end

local function assertEqual(a, b, msg)
    if a ~= b then
        errorMsg(msg or string.format("%s == %s", tostring(a), tostring(b)))
    end
end

t.expect(1).toBe(1)
t.expect({}).toHaveProperty("foo", bFollowMetatable)
t.expect(false).toBeFalse()
t.expect(1.12345).toBeCloseTo(1.123, 0.001)



return Test
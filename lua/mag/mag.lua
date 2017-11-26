---
--- mag.lua - Simple mag card reader and writer utility
--- Author: Rolando Islas
--- Version: 0.1
--- License: GPLv2
---

local Mag = {}
Mag.__index = Mag

---
--- Create new mag reader/writer instance
---
function Mag:new()
    local mag = {}
    setmetatable(mag, Mag)
    -- ComputerCraft
    if peripheral then
        mag.mag = peripheral.find("mag_reader_writer")
        -- OpenComputers
    else
        mag.mag = require("component").mag_reader_writer
        os.pullEvent = require("event").pull
    end
    if not mag.mag then
        error("Mag Card Reader/Writer not found")
    end
    return mag
end

---
--- Main command line entry point
--- @param args table command line arguments
---
function Mag:run(args)
    self:check_argument_count(args, 1, "argument", false)
    local arg = args[1]
    if arg == "read" then
        local event, address, track_one, track_two, track_three
        if peripheral then
            event, track_one, track_two, track_three = os.pullEvent("mag_swipe")
        else
            event, address, track_one, track_two, track_three = os.pullEvent("mag_swipe")
        end
        print(string.format("1: %s\n2: %s\n3: %s", track_one, track_two, track_three))
    elseif arg == "write" then
        self:check_argument_count(args, 2, "track index", false)
        self:check_argument_count(args, 3, "data buffer", true)
        self.mag.write(tonumber(args[2]), args[3])
        print(string.format("Wrote to track buffer %d", args[2]))
    elseif arg == "clear" then
        self.mag.clear()
        print("Cleared buffers")
    else
        error(string.format("No argument \"%s\" found. Try \"help mag\".", arg))
    end
end

---
--- Check the argument count matches the bounds passed
--- Errors with a reason message.
---
--- @param args table arguments
--- @param index number minimum amount of arguments
--- @param name string noun to use for error messages
--- @param max boolean should the arguments end at the index passed
---
function Mag:check_argument_count(args, index, name, max)
    if max == nil then
        max = true
    end
    if #args < index then
        error("Missing " .. name .. ". Try Try \"help mag\".")
    elseif max and #args > index then
        error("Too many " .. name .. "s passed. Try \"help mag\".")
    end
end

-- Init
local mag = Mag:new()
mag:run({...})

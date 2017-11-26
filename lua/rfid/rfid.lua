---
--- rfid.lua - Simple RFID reader and writer utility
--- Author: Rolando Islas
--- Version: 0.1
--- License: GPLv2
---

local Rfid = {}
Rfid.__index = Rfid

local SECTORS = 16
local SECTOR_SIZE = 4
local KEY_TYPE_A = 0 -- Type B is 1
local KEY_A = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff} -- Default key
local BLOCK_SIZE = 16

---
--- Create new Rfid simple reader/writer instance
---
function Rfid:new()
    local rfid = {}
    setmetatable(rfid, Rfid)
    -- ComputerCraft
    if peripheral then
        rfid.rfid = peripheral.find("rfid_reader_writer")
    -- OpenComputers
    else
        rfid.rfid = require("component").rfid_reader_writer
    end
    if not rfid.rfid then
        error("RFID Reader/Writer not found")
    end
    return rfid
end

---
--- Main command line entry point
--- @param args table command line arguments
---
function Rfid:run(args)
    self:check_argument_count(args, 1, "argument", false)
    local arg = args[1]
    if arg == "read" then
        self:read()
    elseif arg == "write" then
        self:check_argument_count(args, 2, "argument", true)
        self:write(args[2])
    else
        error(string.format("No argument \"%s\" found. Try \"help rfid\".", arg))
    end
end

---
--- Writes a table's values to a string
---
function table_to_string(t)
    local s = ""
    for k, v in ipairs(t) do
        s = s .. v .. ","
    end
    return s
end

---
--- Block and wait for a chip to be found. When found, the chip will be selected
---
function Rfid:find_chip()
    print("Searching for RFID chip...")
    local rfid_chip
    repeat
        rfid_chip = self.rfid.search()
        os.sleep(0.1)
    until rfid_chip
    print(string.format("Found RFID chip\nID: %s", table_to_string(rfid_chip)))
    self.rfid.select(rfid_chip)
end

---
--- Return a shallow copy of a table constrained to the index
--- @param start_index number index to start from - inclusive
--- @param end_index number index to stop at - inclusive
--- @return table
---
function copy_table(t, start_index, end_index, empty_value)
    end_index = end_index or #t
    local new_table = {}
    for item_index = start_index, end_index do
        local item = t[item_index]
        table.insert(new_table, item or empty_value)
    end
    return new_table
end

---
--- Checks if two table are equal.
--- Only performs a shallow check
--- @param table_one table first table
--- @param table_two table second table
--- @return boolean equality
---
function areTablesEqual(table_one, table_two)
    if #table_one ~= #table_two then
        return false
    end
    for table_one_index, table_one_value in pairs(table_one) do
        if table_one_value ~= table_two[table_one_index] then
            return false
        end
    end
    return true
end

---
--- Read from the card's data blocks, converting the read values to characters.
--- This ignores trailing blocks and the first block.
---
function Rfid:read()
    self:find_chip()
    local blocks = SECTOR_SIZE * SECTORS
    local data = ""
    for block = 1, blocks - 1 do
        if (block + 1) % SECTOR_SIZE ~= 0 then
            self.rfid.auth(KEY_TYPE_A, block, KEY_A)
            local block_table = self.rfid.read(block)
            if not block_table then
                error(string.format("Auth error. Block: %d", block))
            end
            for byte_index, byte in ipairs(block_table) do
                data = data .. string.char(byte)
            end
        end
    end
    self.rfid.deauth()
    data = data:gsub(string.char(0), "")
    print(data)
end

---
--- Write to the card's data blocks, converting string characters to bytes
--- This does not write to trailing blocks or the first block
--- @param s string string to write
---
function Rfid:write(s)
    local data = {}
    for character_index = 1, string.len(s) do
        local byte = string.byte(s:sub(character_index))
        table.insert(data, byte)
    end
    self:find_chip()
    local blocks = SECTOR_SIZE * SECTORS
    for block = 1, blocks - 1 do
        if (block + 1) % SECTOR_SIZE ~= 0 then
            self.rfid.auth(KEY_TYPE_A, block, KEY_A)
            local chunk = copy_table(data, 1, BLOCK_SIZE, 0)
            data = copy_table(data, BLOCK_SIZE + 1)
            local written = self.rfid.write(block, chunk)
            if not written or not areTablesEqual(self.rfid.read(block), chunk) then
                error(string.format("Auth error. Block: %d", block))
            end
        end
    end
    self.rfid.deauth()
    print("Write finished")
end

---
--- Check the argument count matches the bounds passed
--- Errors with a reason message.
---
--- @param args table arguments
--- @param index number minimun amount of arguments
--- @param name string noun to use for error messages
--- @param max boolean should the arguments end at the index passed
---
function Rfid:check_argument_count(args, index, name, max)
    if max == nil then
        max = true
    end
    if #args < index then
        error("Missing " .. name .. ". Try Try \"help rfid\".")
    elseif max and #args > index then
        error("Too many " .. name .. "s passed. Try \"help rfid\".")
    end
end

-- Init
local rfid = Rfid:new()
rfid:run({...})

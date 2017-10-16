--[[
Created by austinv11
]]
tArgs = {...}
local p = peripheral.find("speaker")
for key,value in pairs(tArgs) do
  p.synthesize(value, 64)--Speaking
  local event, text, lang = os.pullEvent("synthComplete")--Waiting for the speech to complete
  end

--[[
Created by Fxz_y
]]
if turtle then
  shell.run("peripheralsplusone/ore_dictionary/ore_dictionary_turtle.lua")
  return
end
p = peripheral.find("oreDictionary") --Wrapping the peripheral
if p then
  oreDict,data = os.pullEvent("oreDict") --Waiting for a player to right click the ore dictionary with an item
  if oreDict then
    for k,v in pairs(data) do
      print(tostring(k)..": "..tostring(v))
    end
  else
    sleep(0.5)
  end
end

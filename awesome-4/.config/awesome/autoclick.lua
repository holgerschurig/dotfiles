local awful  = require("awful")
local screen = awful.screen
local ac     = {}


-----------------------------------------------------------------------------

local function start_stop(timer)
   if timer.started then
      -- print("stopping ...")
      timer:stop()
      return
   end

   if not mouse.current_client then
      -- print("not starting ...")
      return
   end
   -- print("starting ...")
   timer:start()
end


-----------------------------------------------------------------------------

function autoclicker_once()
   -- only auto-click on selected screen
   if ac.tag ~= screen.focused().selected_tag then
   	  return
   end

   -- only click near original position
   local mc = mouse.coords()
   local dist = (mc.x - ac.mx) ^ 2 + (mc.y - ac.my) ^ 2
   -- print("dist " .. dist)
   if dist > 200 then
	  return
   end


   root.fake_input("button_press", 1)
   root.fake_input("button_release", 1)
end


autoclicker_timer = require("gears.timer") { timeout=0.2, callback= autoclicker_once }
function ac.autoclicker()

   local mc = mouse.coords()
   ac.mx = mc.x
   ac.my = mc.y
   ac.tag = screen.focused().selected_tag

   start_stop(autoclicker_timer)

   -- require 'pl.pretty'.dump(ac)
end



-----------------------------------------------------------------------------

local clicks_idlewizard = {
   { x = 960, y = 200 + 1*63 }, -- source
   { x = 960, y = 200 + 2*63 }, -- source
   { x = 960, y = 200 + 3*63 }, -- source
   { x = 960, y = 200 + 4*63 }, -- source
   { x = 960, y = 200 + 5*63 }, -- source
   { x = 960, y = 200 + 6*63 }, -- source
   { x = 960, y = 200 + 7*63 }, -- source
   { x = 960, y = 200 + 8*63 }, -- source
   { key = "b" },        -- buy upgrades
   { x = 495, y = 425},  -- void source
   { x = 584, y = 362},  -- void source
   { x = 763, y = 348},  -- void source
   { x = 856, y = 434},  -- void source
   { key = "w" },        -- weapon
   { x = 852, y = 239 }, -- buy sources
   { x = 670, y = 443 }, -- orb
}

local clicks_wami = {
   { x = 760, y = 690},    -- Basic Attack
   { x = 865, y = 690},    -- Double Attack
   { x = 990, y = 690},    -- Poison Attack
   { x = 1110, y = 690},   -- Paralyze Attack
   { x = 760, y = 735},    -- Block
   { x = 865, y = 735},    -- Absorb
   { x = 990, y = 735},    -- Counter
   { x = 1110, y = 735},   -- Parry
   { x = 760, y = 770},    -- Heal
   { x = 865, y = 770},    -- Regen
   { x = 990, y = 770},    -- Buff Stats
   -- { x = 1110, y = 770},   -- Debuff
}

ac.clicks = clicks_wami

function idleclick_once()
   if ac.iw > table.getn(ac.clicks) then
      ac.iw = 1
   end
   --  print("ac.iw " .. ac.iw)

   -- send mouse click
   local c = ac.clicks[ac.iw]
   if c.x ~= nil then
      mouse.coords(c, false)
      root.fake_input("button_press",   1)
      root.fake_input("button_release", 1)
   end

   -- send key
   if c.key ~= nil then
      root.fake_input("key_press",   c.key)
      root.fake_input("key_release", c.key)
   end

   ac.iw = ac.iw + 1
end


idleclick_timer = require("gears.timer") { timeout=0.07, callback=idleclick_once }

function ac.idlewizard()
   local mc = mouse.coords()
   print("mouse at " .. mc.x .. ", " .. mc.y)

   ac.iw = 1
   start_stop(idleclick_timer)
end



return ac

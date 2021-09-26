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

   local mc = mouse.coords() -- only click near original position
   local dist = (mc.x - ac.mx) ^ 2 + (mc.y - ac.my) ^ 2
   -- print("dist " .. dist)
   if dist > 200 then
      return
   end

   root.fake_input("button_press", 1)
   root.fake_input("button_release", 1)
end


autoclicker_timer = require("gears.timer") { timeout=0.1, callback= autoclicker_once }
function ac.autoclicker()

   local mc = mouse.coords()
   ac.mx = mc.x
   ac.my = mc.y
   ac.tag = screen.focused().selected_tag

   -- autoclicker_once()
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
   -- { x = 760, y = 690},    -- Basic Attack
   { x = 865, y = 690},    -- Double Attack
   { x = 990, y = 690},    -- Poison Attack
   { x = 1110, y = 690},   -- Paralyze Attack
   -- { x = 760, y = 735},    -- Block
   { x = 865, y = 735},    -- Absorb
   { x = 990, y = 735},    -- Counter
   { x = 1110, y = 735},   -- Parry
   { x = 760, y = 770},    -- Heal
   { x = 865, y = 770},    -- Regen
   { x = 990, y = 770},    -- Buff Stats
   { x = 1110, y = 770},   -- Debuff
}

local clicks_ngu = {
   -- Seed, FP, Wando, Cane
   -- { x = 540, y = 520, hold = "d" }, -- row 1, pos 1
   -- { x = 590, y = 520, hold = "d" }, -- row 1, pos 2
   -- { x = 640, y = 520, hold = "d" }, -- row 1, pos 3
   -- { x = 690, y = 520, hold = "d" }, -- row 1, pos 4a
   -- { x = 740, y = 520, hold = "d" }, -- row 1, pos 5
   -- { x = 790, y = 520, hold = "d" }, -- row 1, pos 5

   -- { x = 670, y = 250, hold = "d" }, -- acc 1
   -- { x = 670, y = 250, hold = "a" }, -- acc 1
   -- { x = 670, y = 300, hold = "d" }, -- acc 2
   -- { x = 670, y = 300, hold = "a" }, -- acc 2
   -- { x = 670, y = 350, hold = "d" }, -- acc 3
   -- { x = 670, y = 350, hold = "a" }, -- acc 3
   -- { x = 670, y = 400, hold = "d" }, -- acc 4
   -- { x = 670, y = 400, hold = "a" }, -- acc 4
   -- { x = 720, y = 250, hold = "d" }, -- head
   -- { x = 720, y = 250, hold = "a" }, -- head
   -- { x = 720, y = 300, hold = "d" }, -- chest
   -- { x = 720, y = 300, hold = "a" }, -- chest
   -- { x = 720, y = 350, hold = "d" }, -- legs
   -- { x = 720, y = 350, hold = "a" }, -- legs
   -- { x = 720, y = 400, hold = "d" }, -- boots
   -- { x = 720, y = 400, hold = "a" }, -- boots
   -- { x = 770, y = 300, hold = "d" }, -- weapon
   -- { x = 770, y = 300, hold = "a" }, -- weapon

   -- { x = 540, y = 620, hold = "d" }, -- row 3, pos 1
   -- { x = 540, y = 620, hold = "a" }, -- row 3, pos 1
   -- { x = 590, y = 620, hold = "d" }, -- row 3, pos 2
   -- { x = 590, y = 620, hold = "a" }, -- row 3, pos 2
   -- { x = 640, y = 620, hold = "d" }, -- row 3, pos 3
   -- { x = 640, y = 620, hold = "a" }, -- row 3, pos 3
   -- { x = 690, y = 620, hold = "d" }, -- row 3, pos 4
   -- { x = 690, y = 620, hold = "a" }, -- row 3, pos 4
   -- { x = 740, y = 620, hold = "d" }, -- row 3, pos 5
   -- { x = 740, y = 620, hold = "a" }, -- row 3, pos 5
   -- { x = 790, y = 620, hold = "d" }, -- row 3, pos 6
   -- { x = 790, y = 620, hold = "a" }, -- row 3, pos 6
   -- { x = 840, y = 620, hold = "d" }, -- row 3, pos 7
   -- { x = 840, y = 620, hold = "a" }, -- row 3, pos 7

   -- { x = 540, y = 670, hold = "a" }, -- row 4, pos 1
   -- { x = 590, y = 670, hold = "a" }, -- row 4, pos 2
   -- { x = 640, y = 670, hold = "a" }, -- row 4, pos 3
   -- { x = 690, y = 670, hold = "a" }, -- row 4, pos 4
   -- { x = 740, y = 670, hold = "a" }, -- row 4, pos 5
   -- { x = 790, y = 670, hold = "d" }, -- row 4, pos 6
   -- { x = 840, y = 670, hold = "d" }, -- row 4, pos 7
   -- { x = 890, y = 670, hold = "d" }, -- row 4, pos 8
   -- { x = 940, y = 670, hold = "d" }, -- row 4, pos 9
   -- { x = 990, y = 670, hold = "d" }, -- row 4, pos 10

   -- { x = 820, y = 300, hold = "a" }, -- infinity cube

   -- { x =  345, y = 640, down=1 },
   -- { x =  345, y = 640, up=1 },
   -- { x = 1000, y = 380 }, -- pampa

   { x =  345, y = 700, down=1 },
   { x =  345, y = 700, up=1 },
   { x =  345, y = 700, down=1 },
   { x =  345, y = 700, up=1 },

   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
   { x = 1035, y = 675 }, -- pump
}



function idleclick_once()
   print("ac.iw " .. ac.iw)
   if ac.iw > 100 then
      ac.iw = 1
   end
   if ac.iw > #ac.clicks then
      ac.iw = ac.iw + 1
      return
   end

   -- send mouse click
   local c = ac.clicks[ac.iw]
   if c.hold ~= nil then
      root.fake_input("key_press",   c.hold)
   end
   if c.x ~= nil then
      mouse.coords(c, false)
      root.fake_input("button_press",   1)
      root.fake_input("button_release", 1)
   end
   if c.down ~= nil then
      mouse.coords(c, false)
      root.fake_input("button_press",   1)
   end
   if c.up ~= nil then
      mouse.coords(c, false)
      root.fake_input("button_release",   1)
   end
   if c.hold ~= nil then
      root.fake_input("key_release",   c.hold)
   end

   -- send key
   if c.key ~= nil then
      root.fake_input("key_press",   c.key)
      root.fake_input("key_release", c.key)
   end

   ac.iw = ac.iw + 1
end


idleclick_timer = require("gears.timer") { timeout=0.3, callback=idleclick_once }

function ac.idlewizard()
   local mc = mouse.coords()
   print("ac.idlewizard mouse at " .. mc.x .. ", " .. mc.y)

   ac.iw = 90
   ac.clicks = clicks_ngu
   start_stop(idleclick_timer)
end



return ac

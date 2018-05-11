local awful  = require("awful")
local root   = require("root")
local screen = awful.screen
local mouse  = require("mouse")       -- https://awesomewm.org/doc/api/libraries/mouse.html
local client = require("awful.client")
local ac     = {}


-----------------------------------------------------------------------------

local function start_stop(timer)
   if timer.started then
	  timer:stop()
	  return
   end

   if not mouse.current_client then
	  return
   end
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


autoclicker_timer = require("gears.timer") { timeout=0.08, callback= autoclicker_once }


function ac.autoclicker()

   local mc = mouse.coords()
   ac.mx = mc.x
   ac.my = mc.y
   ac.tag = screen.focused().selected_tag

   start_stop(autoclicker_timer)

   -- require 'pl.pretty'.dump(ac)
end



-----------------------------------------------------------------------------

local function idlewizard_once()
   -- print("Idle Wizard step " .. ac.iw)
   if ac.iw > ac.max then
	  -- print("reset from " .. ac.iw .. " to " .. ac.min)
	  ac.iw = ac.min
   end

   if ac.iw < 8 then
	  -- print("buy source " .. ac.iw)
	  mouse.coords({ x = 960, y = 200 + ac.iw * 63}, false)
	  root.fake_input("button_press", 1)
	  root.fake_input("button_release", 1)
   end
   if ac.iw == 8 then
	  -- print "buy upgrades"
	  root.fake_input("key_press", "b")
	  root.fake_input("key_release", "b")
   end
   -- void sources
   if ac.iw == 9 then
	  mouse.coords({ x = 495, y = 425}, false)
	  root.fake_input("button_press", 1)
	  root.fake_input("button_release", 1)
   end
   if ac.iw == 10 then
	  mouse.coords({ x = 584, y = 362}, false)
	  root.fake_input("button_press", 1)
	  root.fake_input("button_release", 1)
   end
   if ac.iw == 11 then
	  mouse.coords({ x = 763, y = 348}, false)
	  root.fake_input("button_press", 1)
	  root.fake_input("button_release", 1)
   end
   if ac.iw == 12 then
	  mouse.coords({ x = 856, y = 434}, false)
	  root.fake_input("button_press", 1)
	  root.fake_input("button_release", 1)
   end
   -- click orb
   if ac.iw == 13 then
	  mouse.coords({ x = 660, y = 530}, false)
	  root.fake_input("button_press", 1)
	  root.fake_input("button_release", 1)
   end

   ac.iw = ac.iw + 1
end

idlewizard_timer = require("gears.timer") { timeout=0.2, callback= idlewizard_once }

function ac.idlewizard()
   -- local mc = mouse.coords()
   -- print("mouse at " .. mc.x .. ", " .. mc.y)

   -- 0-7    sources
   -- 8      upgrades
   -- 9-12   void traps
   -- 13     orb

   ac.min = 0
   ac.max = 12

   -- ac.iw = 10
   -- idlewizard_once()
   -- return

   ac.iw = 0
   start_stop(idlewizard_timer)

end



return ac

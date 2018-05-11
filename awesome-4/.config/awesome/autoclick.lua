local ac = {
   max_dist = 450,
   delay = 0.07,
}

local awful  = require("awful")
local root   = require("root")
local screen = awful.screen
local mouse  = require("mouse")       -- https://awesomewm.org/doc/api/libraries/mouse.html
local client = require("awful.client")
local timer  = 0

local function ac_timer_func()

   -- find out how far our mouse moved away, but only if we didn't select another tag
   if ac.tag == screen.focused().selected_tag then
	  if ac.moveto then
		 mouse.coords({ x = ac.mx, y = ac.my }, false)
		 ac.moveto = false
	  else
		 local mc = mouse.coords()
		 local dist = (mc.x - ac.mx) ^ 2 + (mc.y - ac.my) ^ 2
		 -- print("AC timer_func, mouse x,y:" .. c.x .. "," .. c.y .. ", dist " .. dist)
		 if dist > ac.max_dist then
			-- print "AC timer stop because of distance"
			-- timer:stop()

			-- or temporarily stop clicking
			return
		 end
	  end
   else
	  ac.moveto = true
   end

   print "AC timer_func"
   root.fake_input("button_press", 1)
   root.fake_input("button_release", 1)
end

timer = require("gears.timer") { timeout=ac.delay, callback= ac_timer_func }


function ac.start_stop()
   print "AC start_stop()"

   if timer.started then
	  timer:stop()
	  return
   end

   ac.client = mouse.current_client
   if not ac.client then
	  return
   end

   local mc = mouse.coords()
   ac.mx = mc.x
   ac.my = mc.y
   ac.tag = screen.focused().selected_tag
   ac.moveto = false


   timer:start()

   require 'pl.pretty'.dump(ac)
end

return ac

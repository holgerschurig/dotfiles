--[[

     Licensed under GNU General Public License v2
      * (c) 2017, Holger Schurig

--]]

local client   = require("awful.client")
local titlebar = require("awful.titlebar")
local floor    = math.floor
local screen   = screen

local two = {
    name    = "two",
    mwfact  = 0,
	yofs    = 32
}


function two.arrange(p)
    local t = p.tag or screen[p.screen].selected_tag
    local wa = p.workarea
    local cls = p.clients

    if #cls == 0 then return end

	print("----")

	-- determine master width
	local mwfact
	if two.mwfact > 0 then
	   mwfact = two.mwfact
	else
	   mwfact = t.master_width_factor
	end

	-- Rounding is necessary to prevent the rendered size of slavewid
	-- from being 1 pixel off when the result is not an integer.
	local master_width = floor(wa.width * mwfact)
	local slave_width = wa.width - master_width

	-- Last client is master, assign fixed width
	local c = cls[#cls]

	local g = {}
	g.width = master_width
	g.height = wa.height
	g.x = wa.x
	g.y = wa.y
	if g.width < 1  then g.width  = 1 end
	if g.height < 1 then g.height = 1 end
	p.geometries[c] = g

	titlebar.hide(c)

	-- function to set slave geometries
	local top = 0
	local function get_geometry()
	   g = {}
	   g.width  = slave_width
	   g.x = wa.x + master_width
	   g.y = top
	   g.height = wa.height - g.y
	   if g.width < 1  then g.width  = 1 end
	   if g.height < 1 then g.height = 1 end
	   print("TWO top: " .. top .. " geo: " .. g.x .. "," .. g.y .. " " .. g.width .. "x" .. g.height)
	   top = top + two.yofs
	   return g
	end

	-- any remaining clients?
	if #cls <= 1 then return end

	local focused = c.focus
	for i = 1,#cls-1 do
	   c = cls[i]
	   print("TWO " .. i .. " class: " .. (c.class or "NONE"))
	   if #cls > 2 then
		  titlebar.show(c)
	   else
		  titlebar.hide(c)
	   end

	   if c == focused then
		  -- omit focused client for now
		  print("TWO focused!")
	   else
		  print("TWO not focused")
		  p.geometries[c] = get_geometry()
	   end
	end

	if focused then
	   print("TWO finally geometry for class: " .. (c.class or "NONE"))
	   p.geometries[focused] = get_geometry()
	end

end

return two

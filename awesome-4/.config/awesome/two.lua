--[[

   Licensed under GNU General Public License v2
   * (c) 2017, Holger Schurig


   One client:
   +-------+........
   |       |       .
   |       |       .
   |       |       .
   |       |       .
   |       |       .
   |       |       .
   |       |       .
   +-------+........

   Two clients:
   +-------+-------+
   |       |       |
   |       |       |
   |       |       |
   |       |       |
   |       |       |
   |       |       |
   |       |       |
   +-------+-------+

   Three clients:
   +-------+-------+
   |       |       |
   |       +-------+
   |       |       |
   |       |       |
   |       |       |
   |       |       |
   |       |       |
   +-------+-------+

   Four clients:
   +-------+-------+
   |       |       |
   |       +-------+
   |       |       |
   |       +-------+
   |       |       |
   |       |       |
   |       |       |
   +-------+-------+

--]]

local client   = require("awful.client")
local titlebar = require("awful.titlebar")
local floor    = math.floor
local capi =
{
    mouse = mouse,
    screen = screen,
    mousegrabber = mousegrabber
}

local two = {
    name    = "two",
    mwfact  = 0,
	yofs    = 32
}


function two.arrange(param)
    local cls = param.clients
    if #cls == 0 then return end

	-- print("-----")
	-- for i = 1,#cls do
	--    c = cls[i]
	--    print("TWO " .. i .. " class: " .. (c.class or "NONE"))
	-- end

    local tag = param.tag or capi.screen[param.screen].selected_tag
    local mwfact = tag.master_width_factor
    local wa = param.workarea

	-- Rounding is necessary to prevent the rendered size of slave_width
	-- from being 1 pixel off when the result is not an integer.
	local master_width = floor(wa.width * mwfact)
	local slave_width = wa.width - master_width

	-- Last client is master, assign fixed width position
	local c = cls[#cls]

	local g = {}
	g.width = master_width
	g.height = wa.height
	g.x = wa.x
	g.y = wa.y
	if g.width < 1  then g.width  = 1 end
	if g.height < 1 then g.height = 1 end
	param.geometries[c] = g

	-- The master doesn't have a title bar
	titlebar.hide(c)

	-- any remaining clients?
	if #cls <= 1 then return end

	-- function to set slave geometries
	local top = (#cls-2) * two.yofs
	local reduce_height = top
	-- print("TWO #cls: " .. #cls)
	-- print("TWO wa.height: " .. wa.height .. ", reduce_height: " .. reduce_height)

	local function get_geometry()
	   g = {}
	   g.width  = slave_width
	   g.x = wa.x + master_width
	   g.y = top
	   g.height = wa.height - reduce_height
	   if g.width < 1  then g.width  = 1 end
	   if g.height < 1 then g.height = 1 end
	   -- print("TWO " geo: " .. g.x .. "," .. g.y .. " " .. g.width .. "x" .. g.height)
	   top = top - two.yofs
	   return g
	end


	for i = 1,#cls-1 do
	   c = cls[i]
	   -- slaves have title bars if we have more than one
	   if #cls > 2 then
		  titlebar.show(c)
	   else
		  titlebar.hide(c)
	   end

	   param.geometries[c] = get_geometry()
	end
end

-- TODO:  two.mouse_resize_handler ?


return two

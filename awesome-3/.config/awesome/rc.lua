-- -*- mode: lua -*-

-- VARIABLES
terminal = "x-terminal-emulator --loginShell"
-- editor = os.getenv("EDITOR") or "editor"
-- editor_cmd = terminal .. " -e " .. editor
editor = "emacs"
editor_cmd = editor
modkey = "Mod4"

-- MODULES
beautiful = require("beautiful")
naughty = require("naughty")
beautiful = require("beautiful")
menubar = require("menubar")
awful = require("awful")
wibox = require("wibox")
tagbox = require("tagbox")
tag = require("awful.tag")
-- lain = require("lain")


-- AUTOFOCUS
require("awful.autofocus")


-- AWESOME-CLIENT
-- https://awesome.naquadah.org/wiki/Awesome-client
require("awful.remote")


-- EXTENSIONS
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
					 title = "Oops, there were errors during startup!",
					 text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
						 title = "Oops, an error happened!",
						 text = err })
		in_error = false
	end)
end

function dump(t)
   require 'pl.pretty'.dump(t)
end


-- MENU
require("debian.menu")


-- THEME
beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
--beautiful.init("awesome-themes-3.5/blue/theme.lua")


-- TAGS
termfair = require("termfair")
termfair.nmaster = 2
termfair.ncol = 1

my_tag_list = {
   termfair,
   termfair,
   termfair,
   awful.layout.suit.tile,
   awful.layout.suit.floating,
   awful.layout.suit.floating,
   -- awful.layout.suit.fair,
   -- awful.layout.suit.tile,
   -- awful.layout.suit.tile.left,
   -- awful.layout.suit.tile.bottom,
   -- awful.layout.suit.tile.top,
   -- awful.layout.suit.fair.horizontal,
   -- awful.layout.suit.spiral,
   -- awful.layout.suit.spiral.dwindle,
   -- awful.layout.suit.max.fullscreen,
   -- awful.layout.suit.magnifier
}

layouts = {
   termfair,
   awful.layout.suit.tile,
   awful.layout.suit.floating,
   awful.layout.suit.max.fullscreen
}

function shorten_tag_name(name)
   if name == "fullscreen" then name = "full"
   elseif name == "floating" then name = "float"
   elseif name == "termfair" then name = "term" end
   return name
end

-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
   tags[s] = {}
   for i, l in ipairs(my_tag_list) do
	  local name = shorten_tag_name(l.name)
	  local t = tag.add(i .. ":" .. name, { screen = s, layout = l})
	  if name == "tile" then
		 tag.setncol(2, t)
	  end
	  table.insert(tags[s], i, t)
   end
end
tags[1][1].selected = true

-- automatically update texts when we switch a layout
function tagbox_update_on_tag_selection(t)
   local index
   for i, v in ipairs(tags[tag.getscreen(t)]) do
	  if v == t then
		 index = i
		 break
	  end
   end

   local l = tag.getproperty(t, "layout") or awful.layout.suit.floating
   local name = shorten_tag_name(l.name)
   t.name = index .. ":" .. name

   -- also update the titlebar
   for _,c in ipairs(t:clients()) do
		   if name == "float" then
			  awful.titlebar.show(c)
	   else
			  awful.titlebar.hide(c)
	   end
   end
end
for s = 1, screen.count() do
   tag.attached_connect_signal(s, "tagged", tagbox_update_on_tag_selection)
   tag.attached_connect_signal(s, "property::layout", tagbox_update_on_tag_selection)
end


-- Create a laucher widget and a main menu
myawesomemenu = {
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}


mymainmenu = awful.menu({ items = { { "Terminal", terminal },
							        { "Emacs", "emacs" },
									{ "Web", "chromium" },
									{ "awesome", myawesomemenu, beautiful.awesome_icon },
									{ "Debian", debian.menu.Debian_menu.Debian }
								  }
						})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
									 menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- Create a textclock widget
mytextclock = awful.widget.textclock("%H:%M  %Y:%m:%d")

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
					awful.button({ }, 1, awful.tag.viewonly),
					awful.button({ modkey }, 1, awful.client.movetotag),
					awful.button({ }, 3, awful.tag.viewtoggle),
					awful.button({ modkey }, 3, awful.client.toggletag),
					awful.button({ }, 4, function(t) awful.layout.inc(layouts, 1) end),
					awful.button({ }, 5, function(t) awful.layout.inc(layouts, -1) end)
					)

for s = 1, screen.count() do
	-- Create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt()
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

	-- Create the wibox
	mywibox[s] = awful.wibox({ position = "bottom", screen = s })

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	-- left_layout:add(mylauncher)
	left_layout:add(mytaglist[s])
	left_layout:add(mypromptbox[s])

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	if s == 1 then right_layout:add(wibox.widget.systray()) end
	right_layout:add(mytextclock)

	-- Now bring it all together
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	-- there is nothing in the middle
	layout:set_right(right_layout)

	mywibox[s]:set_widget(layout)
end

awful.rules = require("awful.rules")


-- BINDINGS
function bind_toogle_wibox()
   mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
end

function bind_focus_client_left()
   awful.client.focus.bydirection("left")
   if client.focus then client.focus:raise() end
end

function bind_focus_client_right()
   awful.client.focus.bydirection("right")
   if client.focus then client.focus:raise() end
end

function bind_focus_client_up()
   awful.client.focus.bydirection("up")
   if client.focus then client.focus:raise() end
end

function bind_focus_client_down()
   awful.client.focus.bydirection("down")
   if client.focus then client.focus:raise() end
end

function bind_toggle_client()
   awful.client.focus.history.previous()
   if client.focus then
	  client.focus:raise()
   end
end

function bind_move_client_left()
   awful.client.swap.bydirection("left")
end

function bind_move_client_right()
   awful.client.swap.bydirection("right")
end

function bind_move_client_up()
   awful.client.swap.bydirection("up")
end

function bind_move_client_down()
   awful.client.swap.bydirection("down")
end

function bind_client_width_increase()
   awful.tag.incmwfact(0.05)
end

function bind_client_width_decrease()
   awful.tag.incmwfact(-0.05)
end

function bind_next_layout()
   awful.layout.inc(layouts, 1)
end

function bind_prev_layout()
   awful.layout.inc(layouts, -1)
end

function bind_run_lua()
   awful.prompt.run({ prompt = "Run Lua code: " },
	  mypromptbox[mouse.screen].widget,
	  awful.util.eval, nil,
	  awful.util.getdir("cache") .. "/history_eval")
end

function bind_run_menu()
   mypromptbox[mouse.screen]:run()
end

function bind_run_terminal()
   awful.util.spawn(terminal)
end

function bind_raise_or_run_web()
   local matcher = function (c)
	  return awful.rules.match(c, {class = 'chromium-browser'})
   end
   local screen = mouse.screen
   local tag = awful.tag.gettags(screen)[4]
   if tag then
	  awful.tag.viewonly(tag)
   end
   awful.client.run_or_raise("chromium", matcher)
end

function bind_raise_or_run_editor()
   local matcher = function (c)
	  return awful.rules.match(c, {class = 'Emacs'})
   end
   awful.client.run_or_raise("emacs", matcher)
end

function bind_unminimize_client()
   awful.client.restore()
end

function bind_minimize_client(c)
   -- The client currently has the input focus, so it cannot be
   -- minimized, since minimized clients can't have the focus.
   c.minimized = true
end

function bind_maximize_client(c)
   c.maximized_horizontal = not c.maximized_horizontal
   c.maximized_vertical   = not c.maximized_vertical
end

function bind_toggle_fullscreen_client(c)
   c.fullscreen = not c.fullscreen
end

function bind_toogle_floating_client(c)
   awful.client.floating.toggle()
end

function bind_toggle_ontop_client(c)
   c.ontop = not c.ontop
end

function bind_kill_client(c)
   c:kill()
end

function bind_swap_client_with_master(c)
   c:swap(awful.client.getmaster())
end

function bind_viewonly_tag(i)
	local screen = mouse.screen
	local tag = awful.tag.gettags(screen)[i]
	if tag then
		awful.tag.viewonly(tag)
	end
end

function bind_viewtoggle_tag(i)
	local screen = mouse.screen
	local tag = awful.tag.gettags(screen)[i]
	if tag then
		awful.tag.viewtoggle(tag)
	end
end

function bind_moveto_tag(i)
	if client.focus then
		local tag = awful.tag.gettags(client.focus.screen)[i]
		if tag then
			awful.client.movetotag(tag)
		end
	end
end

function bind_toggle_tag_on_focused(i)
	if client.focus then
		local tag = awful.tag.gettags(client.focus.screen)[i]
		if tag then
			awful.client.toggletag(tag)
		end
	end
end

function bind_set_layout(i)
	if i > #layouts then
		return
	end
	awful.layout.set(layouts[i])
end


-- Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end)
	-- this used to be a method to switch to another screen
	-- awful.button({ }, 4, awful.tag.viewnext),
	-- awful.button({ }, 5, awful.tag.viewprev)
))

--- Key bindings
globalkeys = awful.util.table.join(
	awful.key({ modkey, "Control" }, "r", awesome.restart), -- really reload
	awful.key({ modkey, "Control" }, "b", menubar.show),
	awful.key({ modkey, "Control" }, "w", bind_toggle_wibox),

	-- TAGS
	-- switch to another tag
	awful.key({ modkey,           }, "Left",   awful.tag.viewprev),
	awful.key({ modkey,           }, "Right",  awful.tag.viewnext),
	-- switch back and forth current tag with last tag
	awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

	-- CLIENT
	awful.key({ modkey,           }, "j", bind_focus_client_left),
	awful.key({ modkey,           }, "k", bind_focus_client_right),
	awful.key({ modkey,           }, "i", bind_focus_client_up),
	awful.key({ modkey,           }, "m", bind_focus_client_down),
	awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
	awful.key({ modkey,           }, "Tab", bind_toggle_client),
	awful.key({ modkey, "Shift"   }, "j", bind_move_client_left),
	awful.key({ modkey, "Shift"   }, "k", bind_move_client_right),
	awful.key({ modkey, "Shift"   }, "i", bind_move_client_up),
	awful.key({ modkey, "Shift"   }, "m", bind_move_client_down),
	awful.key({ modkey,           }, "l", bind_client_width_increase), 	-- doesn't work for term layout
	awful.key({ modkey,           }, "h", bind_client_width_decrease), 	-- doesn't work for term layout
	awful.key({ modkey, "Control" }, "u", bind_client_unminimize),

	-- RUNNING
	awful.key({ modkey,           }, "r",      bind_run_menu),
	awful.key({ modkey, "Control" }, "l",      bind_run_lua),
	awful.key({ modkey,           }, "Return", bind_run_terminal),
	awful.key({ modkey,           }, "w",      bind_raise_or_run_web),
	awful.key({ modkey,           }, "e",      bind_raise_or_run_editor)

	-- ????
	-- awful.key({ modkey,           }, "space", bind_next_layout)
	-- awful.key({ modkey, "Shift"   }, "space", bind_prev_layout)
	-- awful.key({ modkey, "Control" }, "m",     function() mymainmenu:show() end),
	-- awful.key({ modkey, "Shift"   }, "q",     awesome.quit),
	-- awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
	-- awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
	-- awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
	-- awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
	-- awful.key({ modkey, "Control" }, "j",     function () awful.screen.focus_relative( 1) end),
	-- awful.key({ modkey, "Control" }, "k",     function () awful.screen.focus_relative(-1) end),
)

clientkeys = awful.util.table.join(
	awful.key({ modkey, "Control" }, "q",      bind_kill_client),              -- was Mod+Shift+"c"
	awful.key({ modkey, "Control" }, "f",      bind_toggle_fullscreen_client), -- was Mod+"f"
	awful.key({ modkey, "Control",}, "t",      awful.titlebar.toggle),
	awful.key({ modkey, "Control" }, "l",      bind_toggle_floating_client),   -- was Mod+Shift+"f"
	awful.key({ modkey, "Control" }, "x",      bind_toggle_maximize_client),
	awful.key({ modkey, "Shift"   }, "Return", bind_swap_client_with_master),
	awful.key({ modkey, "Shift",  }, "o",      awful.client.movetoscreen)
	--awful.key({ modkey, "Control" }, "n",      bind_minimize_client) -- use S-C-u to un-minimize
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = awful.util.table.join(globalkeys,
		-- View tag on S-1 .. S-9
		-- View tag on S-F1 .. S-F9 (see "xmodmap -pke | grep F1")
		-- Toggle tag on S-C-1 .. S-C-9
		-- Move client to tag on S-Sh-1 .. S-Sh-9.
		-- Toggle tag on focused on S-C-1 .. S-C-9
		awful.key({ modkey                     }, "#" .. i + 9,  function() bind_viewonly_tag(i) end),
		awful.key({ modkey                     }, "#" .. i + 66, function() bind_viewonly_tag(i) end),
		awful.key({ modkey, "Shift"            }, "#" .. i + 9,  function() bind_moveto_tag(i) end),
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,  function() bind_toggle_tag_on_focused(i) end),
		-- awful.key({ modkey, "Control"       }, "#" .. i + 9,  function() bind_viewtoggle_tag(i) end),
		-- Set layout
		awful.key({ modkey, "Control"          }, "#" .. i + 9,  function() bind_set_layout(i) end)
	)
end

-- Some mousebuttons
clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)


-- RULES
-- https://awesomewm.org/wiki/Understanding_Rules
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
	 properties = { border_width = beautiful.border_width,
					border_color = beautiful.border_normal,
					focus = awful.client.focus.filter,
					keys = clientkeys,
					buttons = clientbuttons } },
   { rule = { class = "MPlayer" },
	 properties = { floating = true } },
   { rule = { class = "pinentry" },
	 properties = { floating = true } },
   { rule = { class = "gimp" },
	 properties = { floating = true } },
}


-- SIGNALS
-- https://awesomewm.org/wiki/Signals

-- Executed when a new client appears
client.connect_signal("manage",
function (c, startup)
   -- Enable sloppy focus
   c:connect_signal("mouse::enter",
   function(c)
	  if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
	  and awful.client.focus.filter(c) then
		 client.focus = c
	  end
   end)

   c:connect_signal("tagged",
   function(c, t)
	  if (c.type == "normal" or c.type == "dialog") then
		 if string.find(t.name, "float") then
			awful.titlebar.show(c)
		 else
			awful.titlebar.hide(c)
		 end
	  end
   end)

   if not startup then
	  -- Set the windows at the slave,
	  -- i.e. put it at the end of others instead of setting it master.
	  -- awful.client.setslave(c)

	  -- Put windows in a smart way, only if they does not set an initial position.
	  if not c.size_hints.user_position and not c.size_hints.program_position then
		 awful.placement.no_overlap(c)
		 awful.placement.no_offscreen(c)
	  end
   end

   -- create titlebar, but hide them normally
   if (c.type == "normal" or c.type == "dialog") then
	  -- buttons for the titlebar
	  local buttons = awful.util.table.join(
		 awful.button({ }, 1, function()
			   client.focus = c
			   c:raise()
			   awful.mouse.client.move(c)
		 end),
		 awful.button({ }, 3, function()
			   client.focus = c
			   c:raise()
			   awful.mouse.client.resize(c)
		 end)
	  )

	  -- Widgets that are aligned to the left
	  local left_layout = wibox.layout.fixed.horizontal()
	  left_layout:add(awful.titlebar.widget.iconwidget(c))
	  left_layout:buttons(buttons)

	  -- Widgets that are aligned to the right
	  local right_layout = wibox.layout.fixed.horizontal()
	  right_layout:add(awful.titlebar.widget.floatingbutton(c))
	  right_layout:add(awful.titlebar.widget.maximizedbutton(c))
	  -- right_layout:add(awful.titlebar.widget.stickybutton(c))
	  -- right_layout:add(awful.titlebar.widget.ontopbutton(c))
	  right_layout:add(awful.titlebar.widget.closebutton(c))

	  -- The title goes in the middle
	  local middle_layout = wibox.layout.flex.horizontal()
	  local title = awful.titlebar.widget.titlewidget(c)
	  title:set_align("center")
	  middle_layout:add(title)
	  middle_layout:buttons(buttons)

	  -- Now bring it all together
	  local layout = wibox.layout.align.horizontal()
	  layout:set_left(left_layout)
	  layout:set_right(right_layout)
	  layout:set_middle(middle_layout)

	  awful.titlebar(c):set_widget(layout)
	  awful.titlebar.hide(c)
   end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

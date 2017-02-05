-- I tried to setup a rule to put only the first emacs on tag 1, and
-- only the first browser on tag 5, but this didn't work. So let's do
-- this with a signal instead.
local function manage_first(c)
   if awesome.startup then
	  return
   end

   local count = 0
   local tag
   if c.class == "Emacs" then
	  tag = screen[1].tags[1]
	  count = 0
	  for _, cc in ipairs(client.get()) do
		 if cc.class == c.class then
			count = count + 1
		 end
	  end
   end
   if c.class == "Firefox" or c.class == "Chromium" then
	  tag = screen[1].tags[5]
	  print("")
	  for _, cc in ipairs(client.get()) do
		 print("cc.class:" .. cc.class)
		 if cc.class == "Firefox" or cc.class == "Chromium" then
			count = count + 1
		 end
	  end
   end
   print("Class: " .. c.class .. "  count: " .. count)
   if count == 1 then
   	  c:move_to_tag(tag)
   	  c:jump_to()
   end
end
client.connect_signal("manage", manage_first)


-- Rules to apply to new clients
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false,
     }
    },

    -- Floating clients
    { rule_any = {
        instance = {
          "DTA",    -- Firefox addon DownThemAll
          "copyq",  -- Includes session name in class
        },
        class = {
		  "Minetest",
		  "qconf",
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },
}

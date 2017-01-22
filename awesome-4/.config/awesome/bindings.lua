local awful   = require("awful")

-- speedup
local tinsert = table.insert
local pairs = pairs

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- {{{ Binding functions
local function bind_lua_prompt()
   awful.prompt.run {
	  prompt       = "Run Lua code: ",
	  textbox      = awful.screen.focused().mypromptbox.widget,
	  exe_callback = awful.util.eval,
	  history_path = awful.util.get_cache_dir() .. "/history_eval"
   }
end

local function bind_toggle_client()
   awful.client.focus.history.previous()
   if client.focus then
	  client.focus:raise()
   end
end

local function bind_restore_minimized ()
   local c = awful.client.restore()
   -- Focus restored client
   if c then
	  client.focus = c
	  c:raise()
   end
end

function bind_toggle_fullscreen_client (c)
   c.fullscreen = not c.fullscreen
   c:raise()
end

function bind_toggle_maximize_client (c)
   c.maximized = not c.maximized
   c:raise()
end

function bind_tags_viewonly(i)
   local screen = awful.screen.focused()
   local tag = screen.tags[i]
   if tag then
	  tag:view_only()
   end
end

function bind_tags_viewtoggle()
   local screen = awful.screen.focused()
   local tag = screen.tags[i]
   if tag then
	  awful.tag.viewtoggle(tag)
   end
end

function bind_tags_move_to_tag(i)
   if client.focus then
	  local tag = client.focus.screen.tags[i]
	  if tag then
		 client.focus:move_to_tag(tag)
	  end
   end
end

function bind_tags_toggle_tag(i)
   if client.focus then
	  local tag = client.focus.screen.tags[i]
	  if tag then
		 client.focus:toggle_tag(tag)
	  end
   end
end

function bind_tags_set_layout(i)
   local tag = awful.screen.focused().selected_tag
   print("TAG: " .. tag.name .. " to " .. i)
   tag.layout = awful.layout.layouts[i]
end

function bind_run_or_raise_emacs()
   local matcher = function (c)
	  return awful.rules.match(c, {class = 'Emacs'})
   end
   awful.client.run_or_raise('emacs', matcher)
end
function bind_run_or_raise_browser()
   local matcher = function (c)
	  return awful.rules.match(c, {class = 'Firefox'}) or awful.rules.match(c, {class = 'chromium-browser'})
   end
   awful.client.run_or_raise('x-www-browser', matcher)
end
-- }}}

-- {{{ Key bindings
globalkeys = {}
clientkeys = {}
function globalkey(mod, key, func, desc)
   local key = awful.key(mod, key, func, desc)
   for k,v in pairs(key) do
	  tinsert(globalkeys, v)
   end
end
function clientkey(mod, key, func, desc)
   local key = awful.key(mod, key, func, desc)
   for k,v in pairs(key) do
	  tinsert(clientkeys, v)
   end
end


-- AWESOME
globalkey({ modkey }, "s",
   hotkeys.show_help,
   {description="Show help", group="Awesome"})
globalkey({ modkey, "Control" }, "r",
   awesome.restart,
   {description = "Reload configuration", group = "Awesome"})
globalkey({ modkey, "Control" }, "u",
   bind_lua_prompt,
   {description = "Lua prompt", group = "Awesome"})
globalkey({ modkey, "Control" }, "m",
   function () mymainmenu:show() end,
   {description = "Awesome's menu", group = "Awesome"})
-- globalkey({ modkey, "Control" }, "q",
--    awesome.quit,
--    {description = "quit awesome", group = "Awesome"})

-- RUNNING
globalkey({ modkey }, "r",
   function () awful.screen.focused().mypromptbox:run() end,
   {description = "Run prompt", group = "Run"})
globalkey({ modkey }, "Return",
   function () awful.spawn(terminal) end,
   {description = "Terminal", group = "Run"})
globalkey({ modkey }, "e",
   bind_run_or_raise_emacs,
   {description = "Emacs", group = "Run"})
globalkey({ modkey }, "w",
   bind_run_or_raise_browser,
   {description = "Web browser", group = "Run"})

-- TAGS
globalkey({ modkey }, "Escape",
   awful.tag.history.restore,
   {description = "Previous tag", group = "Tags"})
globalkey({ modkey }, "Right",
   awful.tag.viewnext,
   {description = "Tag forward", group = "Tags"})
globalkey({ modkey }, "Left",
   awful.tag.viewprev,
   {description = "Tag backword", group = "Tags"})

-- FOCUS
globalkey({ modkey }, "j",
   function () awful.client.focus.bydirection("left") end,
   {description = "Focus left client", group = "Focus"})
globalkey({ modkey }, "k",
   function () awful.client.focus.bydirection("right") end,
   {description = "Focus right client", group = "Focus"})
globalkey({ modkey }, "i",
   function () awful.client.focus.bydirection("up") end,
   {description = "Focus upper client", group = "Focus"})
globalkey({ modkey }, "m",
   function () awful.client.focus.bydirection("down") end,
   {description = "Focus lower client", group = "Focus"})
globalkey({ modkey }, "u",
   awful.client.urgent.jumpto,
   {description = "Focus urgent client", group = "Focus"})
globalkey({ modkey }, "Tab",
   bind_toggle_client,
   {description = "Focus previous client", group = "Focus"})

-- CLIENTS: MOVE
globalkey({ modkey, "Shift"}, "j",
   function () awful.client.swap.bydirection("left") end,
   {description = "Move client left", group = "Clients"})
globalkey({ modkey, "Shift", }, "k",
   function () awful.client.swap.bydirection("right") end,
   {description = "Move client right", group = "Clients"})
globalkey({ modkey, "Shift", }, "i",
   function () awful.client.swap.bydirection("up") end,
   {description = "Move client up", group = "Clients"})
globalkey({ modkey, "Shift", }, "m",
   function () awful.client.swap.bydirection("down") end,
   {description = "Focus client down", group = "Clients"})
globalkey({ modkey, "Control" }, "n",
   bind_restore_minimized,
   {description = "Restore minimized clients", group = "Clients"})

-- LAYOUT: width
globalkey({ modkey, "Shift" }, "h",
   function () awful.tag.incnmaster( 1, nil, true) end,
   {description = "Increase masters", group = "Layout"})
globalkey({ modkey, "Shift" }, "l",
   function () awful.tag.incnmaster(-1, nil, true) end,
   {description = "Decrease masters", group = "Layout"})
globalkey({ modkey, "Control" }, "h",
   function () awful.tag.incncol( 1, nil, true) end,
   {description = "Increase columns", group = "Layout"})
globalkey({ modkey, "Control" }, "l",
   function () awful.tag.incncol(-1, nil, true) end,
   {description = "Decrease columns", group = "Layout"})
if awful.util.table.hasitem(awful.layout.layouts, awful.layout.suit.tile) then
   -- master_width_facto: only supported in the tile, maginifier, corner
   globalkey({ modkey }, "l",
	  function () awful.tag.incmwfact( 0.05) end,
	  {description = "Increase master width", group = "Layout"})
   globalkey({ modkey }, "h",
	  function () awful.tag.incmwfact(-0.05) end,
	  {description = "Decrease master width", group = "Layout"})
end
-- Next/Previous layout
globalkey({ modkey }, "space",
   function () awful.layout.inc( 1) end,
   {description = "Next layout", group = "Layout"})
globalkey({ modkey, "Shift" }, "space",
   function () awful.layout.inc(-1) end,
   {description = "Previous layout", group = "Layout"})
for i,v in ipairs(awful.layout.layouts) do
   globalkey({ modkey, "Control", "Shift" }, "#" .. i + 9,
	  function () bind_tags_set_layout(i) end,
	  {description = "Set " .. shorten_layout_name(v.name), group = "Layout"})
end

-- SCREEN
globalkey({ modkey, "Control" }, "j",
   function () awful.screen.focus_relative( 1) end,
   {description = "focus the next screen", group = "Screen"})
globalkey({ modkey, "Control" }, "k",
   function () awful.screen.focus_relative(-1) end,
   {description = "focus the previous screen", group = "Screen"})




clientkey({ modkey, "Control" }, "q",
   function (c) c:kill() end,
   {description = "Quit (kill) client", group = "Clients"})
clientkey({ modkey, "Control" }, "f",
   bind_toggle_fullscreen_client,
   {description = "Toggle fullscreen", group = "Clients"})
clientkey({ modkey, "Control" }, "t",
   awful.titlebar.toggle,
   {description = "Toggle titlebar", group = "Clients"})
clientkey({ modkey, "Control" }, "o",
   function (c) c.floating = not c.floating end,
   {description = "Toggle floating", group = "Clients"})
clientkey({ modkey, "Control" }, "Return",
   function (c) c:swap(awful.client.getmaster()) end,
   {description = "Move to master", group = "Clients"})
-- clientkey({ modkey }, "o",
--    function (c) c:move_to_screen() end,
--    {description = "Move client to screen", group = "Screen"})
-- clientkey({ modkey, "Control"}, "t",
--    function (c) c.ontop = not c.ontop end,
--    {description = "toggle keep on top", group = "Clients"}),
-- clientkey({ modkey, "Control" }, "n"
--     function (c) c.minimized = true end,
--     {description = "minimize", group = "client"})
clientkey({ modkey, "Control" }, "x",
   bind_toggle_maximize_client,
   {description = "Maximize", group = "Clients"})


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
   -- View tag only.
   globalkey({ modkey }, "#" .. i + 9,
	  function () bind_tags_viewonly(i) end,
	  {description = "View tag #"..i, group = "Tags"})
   globalkey({ modkey }, "#" .. i + 66, -- F1..F8
	  function () bind_tags_viewonly(i) end,
	  {description = "View tag #"..i, group = "Tags"})
   -- Toggle tag display.
   globalkey({ modkey, "Control" }, "#" .. i + 9,
	  function () bind_tags_viewtoggle(i) end,
	  {description = "Toggle tag #" .. i, group = "Tags"})
   globalkey({ modkey, "Control" }, "#" .. i + 66,
	  function () bind_tags_viewtoggle(i) end,
	  {description = "Toggle tag #" .. i, group = "Tags"})
   -- Move client to tag.
   globalkey({ modkey, "Shift" }, "#" .. i + 9,
	  function () bind_tags_move_to_tag(i) end,
	  {description = "Move focused client to tag #"..i, group = "Tags"})
   globalkey({ modkey, "Shift" }, "#" .. i + 66,
	  function () bind_tags_move_to_tag(i) end,
	  {description = "Move focused client to tag #"..i, group = "Tags"})
   -- Toggle tag on focused client.
   -- globalkey({ modkey, "Control", "Shift" }, "#" .. i + 9,
   -- 	  function () bind_tags_toggle_tag(i) end,
   -- 	  {description = "Toggle tag #" .. i .. " for on focused client", group = "Tags"})
   -- globalkey({ modkey, "Control", "Shift" }, "#" .. i + 66,
   -- 	  function () bind_tags_toggle_tag(i) end,
   -- 	  {description = "Toggle tag #" .. i .. " for on focused client", group = "Tags"})
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

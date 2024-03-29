-----------------------------------------------------------------------------
-- Variable definitions
-----------------------------------------------------------------------------
terminal = "/usr/bin/x-terminal-emulator"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
rofi_cmd = "/usr/bin/rofi -combi-modi drun -show combi -modi combi"


-----------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------
awful = require("awful")
beautiful = require("beautiful")
hotkeys = require("awful.hotkeys_popup").widget

local naughty = require("naughty")
local gears = require("gears")
local wibox = require("wibox")
local two = require('two')


-----------------------------------------------------------------------------
-- Error handling
-----------------------------------------------------------------------------
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
                         text = tostring(err) })
        in_error = false
    end)
end


-----------------------------------------------------------------------------
-- Theme definitions
-----------------------------------------------------------------------------
beautiful.init(awful.util.get_themes_dir() .. "zenburn/theme.lua")
beautiful.wallpaper = nil
gears.wallpaper.set("#000000")


-----------------------------------------------------------------------------
-- Tags & Layouts
-----------------------------------------------------------------------------
-- Don't jump mouse cursor to the client's corner when resizing it
awful.layout.suit.tile.resize_jump_to_corner = false
awful.layout.suit.floating.resize_jump_to_corner = false

local function my_update_tag(t)
    -- require 'pl.pretty'.dump(t.layout)

    local conf = gears.filesystem.get_configuration_dir()
    local themes = gears.filesystem.get_themes_dir() .. "zenburn/layouts/"
    if     t.name == "1" and t.layout == two then t.icon = conf .. "devel.svg"
    elseif t.name == "2" and t.layout == two then t.icon = conf .. "term.svg"
    elseif t.name == "3" and t.layout == two then t.icon = conf .. "term.svg"
    elseif t.name == "4" and t.layout == two then t.icon = conf .. "term.svg"
    elseif t.name == "5" and t.layout == awful.layout.suit.fair then t.icon = conf .. "web.svg"

    elseif t.layout == awful.layout.suit.fair     then t.icon = themes .. "fairv.png"
    elseif t.layout == awful.layout.suit.floating then t.icon = themes .. "floating.png"
    elseif t.layout == awful.layout.suit.max      then t.icon = themes .. "max.png"
    else t.icon = gears.filesystem.get_configuration_dir() .. "term.svg" end
end
awful.tag.attached_connect_signal(s, "property::layout", my_update_tag)

local function my_tags(s)
    local conf = gears.filesystem.get_configuration_dir()
    local themes = gears.filesystem.get_themes_dir() .. "zenburn/layouts/"
    awful.tag.add("1", { screen = s,layout = two, selected = true })
    awful.tag.add("2", { screen = s,layout = two })
    awful.tag.add("3", { screen = s,layout = two })
    awful.tag.add("4", { screen = s,layout = two })
    awful.tag.add("5", { screen = s,layout = awful.layout.suit.fair })
    awful.tag.add("6", { screen = s,layout = awful.layout.suit.fair })
    awful.tag.add("7", { screen = s,layout = awful.layout.suit.floating })
    awful.tag.add("8", { screen = s,layout = awful.layout.suit.max })
end

awful.layout.layouts = {
    two,
    awful.layout.suit.fair,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}

-- Change some of the (internal) layout names to something I like more
function shorten_layout_name(name)
    if name == "fullscreen" then name = "full"
    elseif name == "tileleft" then name = "tile"
    elseif name == "floating" then name = "float"
    elseif name == "fairv" then name = "fair"
    elseif name == "termfair" then name = "term" end
    return name
end


-----------------------------------------------------------------------------
-- Mini menu
-----------------------------------------------------------------------------
my_main_menu = awful.menu(
    { items = {
          { "open terminal", terminal },
          { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
          { "restart", awesome.restart },
          { "quit", function() awesome.quit() end },
}})

root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () my_main_menu:toggle() end)
))


-----------------------------------------------------------------------------
-- Side bar buttons
-----------------------------------------------------------------------------
function run_rofi()
    awesome.spawn(
      rofi_cmd,
      false, -- use startup notification?
      false, -- return a FD for STDIN
      false, -- return a FD for STDOUT
      false, -- return a FD for STDERR
      nil,   -- exit callback
      nil)   -- environment
end

-- this is similar to https://github.com/PapyElGringo/material-awesome/blob/master/widgets/clickable-container.lua
local clickable_container = function(widget)
    local container =
        wibox.widget {
        widget,
        widget = wibox.container.background
    }
    local old_cursor, old_wibox
    container.bg = beautiful.bg_normal

    container:connect_signal('mouse::enter', function() container.bg = beautiful.bg_focus end)
    container:connect_signal('mouse::leave', function() container.bg = beautiful.bg_normal end)
    container:connect_signal('button::press', function() container.bg = beautiful.bg_urgent end)
    container:connect_signal('button::release', function() container.bg = beautiful.bg_focus end)

    return container
end


local function my_sidebar_button(func, svg, left_margin, right_margin, top_margin, botton_margin)
    local button = wibox.widget {
        wibox.widget {
            wibox.widget {
                wibox.widget {
                    image = gears.filesystem.get_configuration_dir() .. "/" .. svg,
                    widget = wibox.widget.imagebox
                },
                left = left_margin or 0,
                right = right_margin or 0,
                top = top_margin or 0,
                bottom = bottom_margin or 0,
                widget = wibox.container.margin
            },
            widget = clickable_container
        },
        bg = beautiful.bg_normal,
        widget = wibox.container.background
    }
    button:buttons(awful.button({}, 1, nil, func))
    return button
end


-----------------------------------------------------------------------------
-- Tag list
-----------------------------------------------------------------------------
local taglist_buttons =
    awful.util.table.join(
        awful.button({ }, 1, function(t) t:view_only() end),
        awful.button({ modkey }, 1, function(t)
                if client.focus then
                    client.focus:move_to_tag(t)
                    t:view_only()
                end
        end),
        awful.button({ }, 3, awful.tag.viewtoggle),
        awful.button({ modkey }, 3, function(t)
                if client.focus then
                    client.focus:toggle_tag(t)
                end
        end),
        awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
        awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
    )

local function my_taglist(s)
    local tl = awful.widget.taglist{
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,

        layout   = {
            spacing = 4,
            layout  = wibox.layout.fixed.vertical,
        },
    }
    -- require 'pl.pretty'.dump(tl.buttons)
    return tl
end


-----------------------------------------------------------------------------
-- Systray
-----------------------------------------------------------------------------
local my_systray = wibox.widget.systray()
my_systray:set_horizontal(false)


-----------------------------------------------------------------------------
-- CPU usage
-----------------------------------------------------------------------------
-- based on https://github.com/streetturtle/awesome-wm-widgets/tree/master/cpu-widget
local my_cpu_usage =
    wibox.widget {
        max_value = 100,
        forced_height = 24,
        widget = wibox.widget.graph
    }
local cpu_usage_prev_total = 0
local cpu_usage_prev_idle  = 0

awful.widget.watch(
    [[grep '^cpu ' /proc/stat]],
    2, -- this is the intervall
    function(widget, stdout, stderr, exitreason, exitcode)
        local user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice =
            stdout:match('(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s')

        local total = user + nice + system + idle + iowait + irq + softirq + steal

        local diff_idle = idle - cpu_usage_prev_idle
        local diff_total = total - cpu_usage_prev_total
        local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10
        widget:set_color(diff_usage > 80 and '#FF0000' or '#00FF00')

        widget:add_value(diff_usage)

        cpu_usage_prev_total = total
        cpu_usage_prev_idle  = idle
    end,
    my_cpu_usage
)
my_cpu_usage = wibox.container.mirror(my_cpu_usage, {horizontal = true})


-----------------------------------------------------------------------------
-- Text clock
-----------------------------------------------------------------------------
local my_clock = function()
    local clock = wibox.widget.textclock('%H\n%M')
    return wibox.container.place(
        wibox.container.margin(clock, 3,3, 4,2) -- left,right, top,bottom
    )
end


-----------------------------------------------------------------------------
-- Side bar
-----------------------------------------------------------------------------
awful.screen.connect_for_each_screen(function(s)
    my_tags(s)

    -- Create the wibox
    s.mywibox = awful.wibar({
            position = "right",
            screen = s,
            width = 24,
    })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.vertical,
        -- Top widgets
        {
            layout = wibox.layout.fixed.vertical,
            my_sidebar_button(run_rofi, "menu.svg", 0,0,0,4),
            my_taglist(s),
        },
        -- Middle widget
        nil,
        -- Bottom widgets
        {
            layout = wibox.layout.fixed.vertical,
            my_systray,
            wibox.container.margin(nil, 0,0, 4,0),
            my_cpu_usage,
            wibox.container.margin(nil, 0,0, 4,0),
            my_clock(),
        },
    }
end)
awful.screen.focused().tags[1]:view_only()


-----------------------------------------------------------------------------
-- Mouse and Keyboard bindings
-----------------------------------------------------------------------------
awful.mouse.snap.edge_enabled = false
require("bindings")


-----------------------------------------------------------------------------
-- Rules
-----------------------------------------------------------------------------
require("rules")


-----------------------------------------------------------------------------
-- Signals
-----------------------------------------------------------------------------
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
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

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            -- awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            -- awful.titlebar.widget.stickybutton   (c),
            -- awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
    -- Hide the menubar if we are not floating
    local l = awful.layout.get(c.screen)
    if not (l.name == "floating" or c.floating) then
        awful.titlebar.hide(c)
    end
end)
-- Toggle on/off the floating bar when a client becomes floating
client.connect_signal("property::floating", function (c)
    if c.floating then
        awful.titlebar.show(c)
    else
        awful.titlebar.hide(c)
    end
end)
-- I want all clients in a floating layout have a title bar
awful.tag.attached_connect_signal(s, "property::layout", function (t)
    local float = t.layout.name == "floating"
    for _,c in pairs(t:clients()) do
        c.floating = float
    end
end)


-----------------------------------------------------------------------------
-- Focus
-----------------------------------------------------------------------------
-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- makes sure that there's always a client that will have focus
require("awful.autofocus")


-----------------------------------------------------------------------------
-- awesome-client
-----------------------------------------------------------------------------
require("awful.remote")

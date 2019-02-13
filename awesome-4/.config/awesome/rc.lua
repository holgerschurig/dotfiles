-----------------------------------------------------------------------------
-- Variable definitions
-----------------------------------------------------------------------------
terminal = "/usr/bin/urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
rofi_cmd = "/usr/bin/rofi -combi-modi drun -show combi -modi combi"


-----------------------------------------------------------------------------
-- Globally needed things
-----------------------------------------------------------------------------
local awful = require("awful")
local hotkeys = require("awful.hotkeys_popup").widget
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")
local two = require('two')


-----------------------------------------------------------------------------
-- Error handling
-----------------------------------------------------------------------------
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
local naughty = require("naughty")
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
beautiful = require("beautiful")
awful = require("awful")
beautiful.init(awful.util.get_themes_dir() .. "zenburn/theme.lua")
beautiful.wallpaper = nil


-----------------------------------------------------------------------------
-- Tags & Layouts
-----------------------------------------------------------------------------
local two = require('two')

awful.layout.suit.tile.resize_jump_to_corner = false

-- This is the list of my tags and their associated layout. I don't need to name
-- them, because they will be named automatically "1:tile", "2:tile" ... "8:fairv"
local my_tag_list = {
    two,
    two,
    two,
    two,
    awful.layout.suit.fair,
    awful.layout.suit.fair,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}

-- Built list of possible tags dynamically
awful.layout.layouts = {}
for _,v in pairs(my_tag_list) do
    if not awful.util.table.hasitem(awful.layout.layouts, v) then
        table.insert(awful.layout.layouts, v)
    end
end

-- Change some of the (internal) layout names to something I like more
function shorten_layout_name(name)
    if name == "fullscreen" then name = "full"
    elseif name == "tileleft" then name = "tile"
    elseif name == "floating" then name = "float"
    elseif name == "fairv" then name = "fair"
    elseif name == "termfair" then name = "term" end
    return name
end

-- When the layout changed we need to reset the names
local function tagbox_update_tagname(t)
    -- require 'pl.pretty'.dump(t)
    t.name = t.index .. ":" .. shorten_layout_name(t.layout.name)
end


-----------------------------------------------------------------------------
--  Mini menu
-----------------------------------------------------------------------------
mymainmenu = awful.menu({ items = {
                                 { "open terminal", terminal },
                                 { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
                                 { "restart", awesome.restart },
                                 { "quit", function() awesome.quit() end },
                       }})

root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))


-----------------------------------------------------------------------------
--  Menu button
-----------------------------------------------------------------------------
local wibox = require("wibox")
gears = require("gears")
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


local mymenubutton = function()
    button = wibox.widget {
        wibox.widget {
            wibox.widget {
                wibox.widget {
                    image = os.getenv("HOME") .. "/.config/awesome/menu.svg",
                    widget = wibox.widget.imagebox
                },
                top = 12,
                left = 12,
                right = 12,
                bottom = 12,
                widget = wibox.container.margin
            },
            widget = clickable_container
        },
        bg = beautiful.bg_normal, -- TODO primary.hue_500,
        widget = wibox.container.background
    }
    button:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                nil,
                run_rofi
            )
        )
    )
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

local function mytaglist(s)
    return awful.widget.taglist{
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,

        layout   = {
            spacing = 2,
            spacing_widget = {
                color  = beautiful.bg_normal,
                shape  = gears.shape.powerline,
                widget = wibox.widget.separator,
            },
            layout  = wibox.layout.fixed.vertical,
        },
    }
end


-----------------------------------------------------------------------------
-- Text clock
-----------------------------------------------------------------------------
local myclock = function()
    local clock = wibox.widget.textclock('<b>%H:%M</b>\n%d.%m')
    local calendar = awful.widget.calendar_popup.year({
            style_yearheader = {
                fg_color = "#ff0000",
                markup = "<span size=\"x-large\">%s</span>",
            },
    })
    calendar:attach(clock, 'br')
    return wibox.container.place(
        wibox.container.margin(clock, 3,3, 2,4)
    )
end


-----------------------------------------------------------------------------
-- Side bar
-----------------------------------------------------------------------------
awful.screen.connect_for_each_screen(function(s)
    for i,l in ipairs(my_tag_list) do
        awful.tag.add(i .. ":" .. shorten_layout_name(l.name),
                      {layout = l,
                       screen = s})
    end
    awful.tag.attached_connect_signal(s, "tagged", tagbox_update_tagname)
    awful.tag.attached_connect_signal(s, "property::layout", tagbox_update_tagname)

    -- Create the wibox
    s.mywibox = awful.wibar({
            position = "right",
            screen = s,
            width = 48,
    })


    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.vertical,
        -- Top widgets
        {
            layout = wibox.layout.fixed.vertical,
            mymenubutton(),
            mytaglist(s),
        },
        -- Middle widget
        nil,
        -- Bottom widgets
        {
            layout = wibox.layout.fixed.vertical,
            wibox.widget.systray(),
            myclock(),
        },
    }
end)
awful.screen.focused().tags[1]:view_only()


-----------------------------------------------------------------------------
-- Mouse and Keyboard bindings
-----------------------------------------------------------------------------
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

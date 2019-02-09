-- I tried to setup a rule to put only the first emacs on tag 1, and
-- only the first browser on tag 5, but this didn't work. So let's do
-- this with a signal instead.
function manage_first(c)
    if awesome.startup then
        return
    end

    function isBrowser(c)
        return c.class == "Firefox" or c.class == "Chromium" or c.class == "Chromium-browser"
    end

    local count = 0
    local tag
    -- print("CLAZZ: " .. (c.class or "NONE"))
    if c.class == "Emacs" then
        tag = screen[1].tags[1]
        count = 0
        for _, cc in ipairs(client.get()) do
            if cc.class == c.class then
                count = count + 1
            end
        end
    end
    if isBrowser(c) then
        tag = screen[1].tags[5]
        for _, cc in ipairs(client.get()) do
            if isBrowser(cc) then
                count = count + 1
            end
        end
    end
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
                     floating = false,
      }
    },

    -- Floating clients
    { rule_any = {
          name = {
              "Event Tester",  -- xev
              "QEMU",
          },
          class = {
              -- "qconf",        -- make xkernelconfig
              "qemu-system-x86_64",
              "qemu-system-arm",
              "xine",
          },
          role = {
              "AlarmWindow",  -- Thunderbird's calendar
              "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
          },
    }, properties = {
          floating = true
    }},

    -- Add titlebars to normal clients and dialogs
    { rule = { type = "normal" },
      properties = { titlebars_enabled = true } },

    { rule = { type = "dialog" },
      properties = {
          titlebars_enabled = true,
          floating = true,
    }},
}

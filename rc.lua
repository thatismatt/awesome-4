---------------------------------
-- thatismatt's awesome config --
---------------------------------

gears         = require("gears")
awful         = require("awful")
                require("awful.autofocus")
wibox         = require("wibox")
beautiful     = require("beautiful")
naughty       = require("naughty")
menubar       = require("menubar")
hotkeys_popup = require("awful.hotkeys_popup").widget
                require("awful.hotkeys_popup.keys")
debian        = require("debian.menu")

prime         = require("prime")
utils         = require("utils")

-- {{{ Error handling
-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal(
      "debug::error",
      function (err)
         -- Make sure we don't go into an endless error loop
         if in_error then return end
         in_error = true
         naughty.notify({ preset = naughty.config.presets.critical,
                          title = "Oops, an error happened!",
                          text = tostring(err) })
         in_error = false
      end
   )
end
-- }}}

-- {{{ Prime - extra commands
prime.add_commands({
      d = {
         name = "dump",
         handle = utils.dump
      },
      l = {
         name = "log",
         handle = function (v)
            utils.log(tostring(v))
            return "LOGGED"
         end
      }
})
prime.default_command_id = "d"
-- }}}

-- {{{ Variable definitions
beautiful.init("/home/matt/.config/awesome/theme.lua")

terminal = "x-terminal-emulator"
emacs = "emacsclient -c -a="

modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   -- awful.layout.suit.tile.top,
   -- awful.layout.suit.fair,
   -- awful.layout.suit.fair.horizontal,
   -- awful.layout.suit.spiral,
   awful.layout.suit.spiral.dwindle,
   awful.layout.suit.max,
   awful.layout.suit.max.fullscreen,
   awful.layout.suit.magnifier,
   awful.layout.suit.corner.nw,
   -- awful.layout.suit.corner.ne,
   -- awful.layout.suit.corner.sw,
   -- awful.layout.suit.corner.se,
   awful.layout.suit.floating,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
   local instance = nil

   return function ()
      if instance and instance.wibox.visible then
         instance:hide()
         instance = nil
      else
         instance = awful.menu.clients({ theme = { width = 250 } })
      end
   end
end

function focus_other_screen ()
   awful.screen.focus_relative(1)
   if awful.screen.focused() ~= client.focus.screen then
      client.focus = nil
   end
end

function restore_and_focus ()
   local restored = awful.client.restore(mouse.screen)
   if restored then
      client.focus = restored
      restored:raise()
   end
end

function focus_raise (direction)
   return function ()
      local cls = utils.filter(
         utils.flatmap(utils.range(screen.count()), awful.client.visible),
         function (c) return awful.client.focus.filter(c) or c == client.focus end)
      local client_to_focus = nil
      for idx, c in ipairs(cls) do
         if c == client.focus then
            client_to_focus = cls[awful.util.cycle(#cls, idx + direction)]
         end
      end
      if client_to_focus then
         client.focus = client_to_focus
         client.focus:raise()
         awful.screen.focus(client_to_focus.screen)
      end
   end
end
-- }}}

-- {{{ Menu
menu = {}

menu.icon = function (dir, name)
   return string.format("/usr/share/icons/Faenza/%s/32/%s.png", dir, name)
end

menu.awesome = {
   { "Manual",  terminal .. " -e man awesome" },
   { "Hotkeys", function () return false, hotkeys_popup.show_help end },
   { "Restart", awesome.restart },
   { "Quit",    awesome.quit }
}

menu.power = {
   { "Power Off", "systemctl poweroff",  menu.icon("actions", "system-shutdown") },
   { "Suspend",   "systemctl suspend",   menu.icon("apps", "system-suspend") },
   { "Restart",   "systemctl reboot",    menu.icon("apps", "system-restart") }
}

menu.screens = {
   { "Auto",   "/home/matt/scripts/screen-auto.sh" },
   { "Single", "/home/matt/scripts/screen-single.sh" },
   { "Dual",   "/home/matt/scripts/screen-dual.sh" },
   { "Arandr", "arandr"}
}

menu.main = awful.menu({
      { "Awesome",      menu.awesome,    beautiful.awesome_icon },
      { "Terminal",     terminal,        menu.icon("apps", "xterm") },
      { "Thunar",       "thunar",        menu.icon("apps", "thunar") },
      { "Emacs",        emacs,           menu.icon("apps", "emacs") },
      { "Firefox",      "firefox",       menu.icon("apps", "firefox") },
      { "Chrome",       "google-chrome", menu.icon("apps", "google-chrome") },
      { "Gimp",         "gimp",          menu.icon("apps", "gimp") },
      { "LXAppearance", "lxappearance",  menu.icon("categories", "preferences-desktop") },
      { "Screens",      menu.screens,    menu.icon("devices", "monitor") },
      { "Power",        menu.power,      menu.icon("actions", "system-shutdown") }
})

menu.main.toggle_at_corner = function ()
   menu.main:toggle({ coords = { x = 0, y = 0 } })
end

menu.launcher = awful.widget.launcher({
      image = beautiful.awesome_icon,
      menu = menu.main
})

menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock(" %a %d %b %Y, %H:%M ")
mytextclock:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn("gsimplecal") end)))

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
   awful.button({ }, 1, function(t) t:view_only() end),
   awful.button({ modkey }, 1, function(t)
         if client.focus then
            client.focus:move_to_tag(t)
         end
   end),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function(t)
         if client.focus then
            client.focus:toggle_tag(t)
         end
   end),
   awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
   awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end)
)

local tasklist_buttons = gears.table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            c.minimized = true
         else
            -- Without this, the following :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
               c.first_tag:view_only()
            end
            -- This will also un-minimize the client, if needed
            client.focus = c
            c:raise()
         end
   end),
   awful.button({ }, 2, function (c) c:kill() end),
   awful.button({ }, 3, client_menu_toggle_fn()),
   awful.button({ }, 4, focus_raise(-1)),
   awful.button({ }, 5, focus_raise(1)))

local function set_wallpaper(s)
   -- Wallpaper
   if beautiful.wallpaper then
      local wallpaper = beautiful.wallpaper
      -- If wallpaper is a function, call it with the screen
      if type(wallpaper) == "function" then
         wallpaper = wallpaper(s)
      end
      gears.wallpaper.maximized(wallpaper, s, true)
   end
end

screen.connect_signal("property::geometry", set_wallpaper)

-- {{{ Tags
tags = { by_screen = {} }
tags.count = 9

function screen_tags (s, names)
   tags.by_screen[s] = awful.tag(names, s, awful.layout.layouts[1])
   for k, v in pairs(names) do
      tags[v] = tags.by_screen[s][k]
   end
end

if screen.count() == 2 then
   screen_tags(1, utils.range(1, 3))
   screen_tags(2, utils.range(4, tags.count))
else
   screen_tags(1, utils.range(1, tags.count))
end
-- }}}

awful.screen.connect_for_each_screen(function(s)

      -- Wallpaper
      set_wallpaper(s)

      -- Create a promptbox for each screen
      s.mypromptbox = awful.widget.prompt()
      -- Create an imagebox widget which will contain an icon indicating which layout we're using.
      -- We need one layoutbox per screen.
      s.mylayoutbox = awful.widget.layoutbox(s)
      s.mylayoutbox:buttons(gears.table.join(
                               awful.button({ }, 1, function () awful.layout.inc( 1) end),
                               awful.button({ }, 3, function () awful.layout.inc(-1) end),
                               awful.button({ }, 4, function () awful.layout.inc( 1) end),
                               awful.button({ }, 5, function () awful.layout.inc(-1) end)))
      -- Create a taglist widget
      s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

      -- Create a tasklist widget
      s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

      -- Create the wibox
      s.mywibox = awful.wibar({ position = "top", screen = s })

      -- Add widgets to the wibox
      s.mywibox:setup {
         layout = wibox.layout.align.horizontal,
         { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            menu.launcher,
            s.mytaglist,
            s.mypromptbox,
         },
         s.mytasklist, -- Middle widget
         { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
         },
      }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
                awful.button({ }, 3, function () menu.main:toggle() end),
                awful.button({ }, 4, awful.tag.viewnext),
                awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
   awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
      { description = "Hotkeys", group = "awesome" }),

   awful.key({ modkey,           }, "t",      function () awful.spawn(terminal) end,
      { description = "Terminal", group = "launcher" }),
   awful.key({ modkey,           }, "e",      function () awful.spawn(emacs) end,
      { description = "Emacs", group = "launcher" }),
   awful.key({ modkey,           }, "w",      function () awful.spawn("x-www-browser") end,
      { description = "Web Browser", group = "launcher" }),
   awful.key({ modkey,           }, "f",      function () awful.spawn("thunar") end,
      { description = "Thunar", group = "launcher" }),
   awful.key({ modkey,           }, "v",      function () awful.spawn("pavucontrol") end,
      { description = "Volume", group = "launcher" }),
   awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
      { description = "view previous", group = "tag" }),
   awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
      { description = "view next", group = "tag" }),
   awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
      { description = "go back", group = "tag" }),

   awful.key({ modkey,           }, "Down",   focus_raise(1),
      { description = "Next", group = "client" }),
   awful.key({ modkey,           }, "Up",     focus_raise(-1),
      { description = "Previous", group = "client" }),
   awful.key({ modkey            }, "o",      focus_other_screen,
      { description = "Other Screen", group = "screen" }),

   awful.key({ modkey,           }, "z",      menu.main.toggle_at_corner,
      { description = "Menu", group = "awesome" }),

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "Down",   function () awful.client.swap.byidx(  1) end,
      { description = "Move next", group = "client" }),
   awful.key({ modkey, "Shift"   }, "Up",     function () awful.client.swap.byidx( -1) end,
      { description = "Move previous", group = "client" }),
   awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
      { description = "Jump to urgent", group = "client" }),
   awful.key({ modkey,           }, "Tab",
      function ()
         awful.client.focus.history.previous()
         if client.focus then
            client.focus:raise()
         end
      end,
      { description = "go back", group = "client" }),

   awful.key({ modkey, "Control" }, "r", awesome.restart,
      { description = "Reload", group = "awesome" }),
   awful.key({ modkey, "Shift"   }, "q", awesome.quit,
      { description = "Quit", group = "awesome" }),

   awful.key({ modkey,           }, "]",     function () awful.tag.incmwfact( 0.05) end,
      { description = "increase master width factor", group = "layout" }),
   awful.key({ modkey,           }, "[",     function () awful.tag.incmwfact(-0.05) end,
      { description = "decrease master width factor", group = "layout" }),
   awful.key({ modkey, "Shift"   }, "[",     function () awful.tag.incnmaster( 1, nil, true) end,
      { description = "increase the number of master clients", group = "layout" }),
   awful.key({ modkey, "Shift"   }, "]",     function () awful.tag.incnmaster(-1, nil, true) end,
      { description = "decrease the number of master clients", group = "layout" }),
   awful.key({ modkey, "Control" }, "[",     function () awful.tag.incncol( 1, nil, true) end,
      { description = "increase the number of columns", group = "layout" }),
   awful.key({ modkey, "Control" }, "]",     function () awful.tag.incncol(-1, nil, true) end,
      { description = "decrease the number of columns", group = "layout" }),
   awful.key({ modkey,           }, "space", function () awful.layout.inc( 1) end,
      { description = "select next", group = "layout" }),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1) end,
      { description = "select previous", group = "layout" }),

   awful.key({ modkey, "Shift"   }, "r",     restore_and_focus,
      { description = "Restore", group = "client" }),

   -- Prompt
   awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
      { description = "run prompt", group = "launcher" }),

   awful.key({ modkey }, "x",
      function ()
         awful.prompt.run {
            prompt       = "Run Lua code: ",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"
         }
      end,
      { description = "lua execute prompt", group = "awesome" }),
   -- Menubar
   awful.key({ modkey }, "p", function() menubar.show() end,
      { description = "show the menubar", group = "launcher" })
)

function tag_next (c)
   awful.screen.focus(c.screen) -- if the focused screen isn't the client's screen then client get
                                -- associated with the tag for the wrong screen, which is odd!
   awful.tag.viewnext()
   c:tags({ awful.tag.selected() })
   client.focus = c
end

function tag_prev (c)
   awful.screen.focus(c.screen) -- if the focused screen isn't the client's screen then client get
                                -- associated with the tag for the wrong screen, which is odd!
   awful.tag.viewprev()
   c:tags({ awful.tag.selected() })
   client.focus = c
end

clientkeys = gears.table.join(
   awful.key({ modkey, "Shift"   }, "m",      function (c) c.maximized = not c.maximized ; c:raise() end,
      { description = "(Un)maximize", group = "client" }),
   awful.key({ modkey, "Shift"   }, "n",      function (c) c.minimized = true end,
      { description = "Minimize",     group = "client" }),
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill() end,
      { description = "Close",        group = "client" }),
   awful.key({ modkey, "Shift"   }, "f",      awful.client.floating.toggle,
      { description = "(Un)float",    group = "client" }),
   awful.key({ modkey, "Shift"   }, "Left",   tag_prev,
      { description = "Previous tag", group = "client" }),
   awful.key({ modkey, "Shift"   }, "Right",  tag_next,
      { description = "Next tag",     group = "client" }),
   awful.key({ modkey,           }, "Return", function (c) c:swap(awful.client.getmaster()) end,
      { description = "Masterify",    group = "client" }),
   awful.key({ modkey, "Shift"   }, "o",      function (c) c:move_to_screen() end,
      { description = "Other screen", group = "client" }),
   awful.key({ modkey, "Shift"   }, "d",      function (c) debug_client = c end,
      { description = "Debug client", group = "client" })
)

tag_bindings = utils.flatmap(
   utils.range(tags.count),
   function (i)
      return awful.util.table.join(
         awful.key({ modkey }, i,
            function ()
               tags[i]:view_only()
               awful.screen.focus(awful.tag.getscreen(tags[i])) -- move mouse to tag's screen
            end,
            { description = "View tag #" .. i, group = "tag" }),
         awful.key({ modkey, "Shift" }, i,
            function ()
               if client.focus then
                  client.focus:move_to_tag(tags[i])
               end
            end,
            { description = "Move client to tag #" .. i, group = "tag" }),
         awful.key({ modkey, "Control" }, i,
            function ()
               awful.tag.viewtoggle(tags[i])
            end,
            { description = "View toggle tag #" .. i, group = "tag" }),
         awful.key({ modkey, "Control", "Shift" }, i,
            function ()
               if client.focus then
                  client.focus:toggle_tag(tags[i])
               end
            end,
            { description = "Client toggle tag #" .. i, group = "tag" })
      )
   end
)

clientbuttons = gears.table.join(
   awful.button({        }, 1, function (c) client.focus = c ; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(gears.table.join(globalkeys, tag_bindings))
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
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
                    placement = awful.placement.no_overlap + awful.placement.no_offscreen } },
   { rule = { name = "gsimplecal" },
     properties = { floating = true } }
}
-- }}}

-- {{{ Signals
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

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

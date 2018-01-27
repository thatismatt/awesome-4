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
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "Hotkeys", function() return false, hotkeys_popup.show_help end },
   { "Restart", awesome.restart },
   { "Quit", function() awesome.quit() end }
}

mymainmenu = awful.menu({ items = {
                             { "Awesome", myawesomemenu, beautiful.awesome_icon },
                             { "Debian", debian.menu.Debian_menu.Debian },
                             { "Terminal", terminal } } })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

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
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
               c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
         end
   end),
   awful.button({ }, 3, client_menu_toggle_fn()),
   awful.button({ }, 4, function ()
         awful.client.focus.byidx(1)
   end),
   awful.button({ }, 5, function ()
         awful.client.focus.byidx(-1)
end))

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

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
      -- Wallpaper
      set_wallpaper(s)

      -- Each screen has its own tag table.
      awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

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
            mylauncher,
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
                awful.button({ }, 3, function () mymainmenu:toggle() end),
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
   awful.key({ modkey,           }, "h",      awful.tag.viewprev,
      { description = "view previous", group = "tag" }),
   awful.key({ modkey,           }, "l",      awful.tag.viewnext,
      { description = "view next", group = "tag" }),
   awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
      { description = "go back", group = "tag" }),

   awful.key({ modkey,           }, "j",
      function ()
         awful.client.focus.byidx( 1)
      end,
      { description = "focus next by index", group = "client" }
   ),
   awful.key({ modkey,           }, "k",
      function ()
         awful.client.focus.byidx(-1)
      end,
      { description = "focus previous by index", group = "client" }
   ),
   awful.key({ modkey,           }, "z", function () mymainmenu:show() end,
      { description = "show main menu", group = "awesome" }),

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end,
      { description = "swap with next client by index", group = "client" }),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end,
      { description = "swap with previous client by index", group = "client" }),
   awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
      { description = "focus the next screen", group = "screen" }),
   awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
      { description = "focus the previous screen", group = "screen" }),
   awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
      { description = "jump to urgent client", group = "client" }),
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

   awful.key({ modkey, "Shift" },   "r",
      function ()
         local c = awful.client.restore()
         -- Focus restored client
         if c then
            client.focus = c
            c:raise()
         end
      end,
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
   awful.tag.viewnext()
   c:tags({ awful.tag.selected() })
   client.focus = c
end

function tag_prev (c)
   awful.tag.viewprev()
   c:tags({ awful.tag.selected() })
   client.focus = c
end

clientkeys = gears.table.join(
   awful.key({ modkey, "Shift"   }, "n",      function (c) c.minimized = true end,
      { description = "Minimize", group = "client" }),
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill() end,
      { description = "Close", group = "client" }),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,
      { description = "(Un)float", group = "client" }),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
      { description = "Masterify", group = "client" }),
   awful.key({ modkey, "Shift"   }, "h",      tag_prev,
      { description = "Previous tag", group = "client" }),
   awful.key({ modkey, "Shift"   }, "l",      tag_next,
      { description = "Next tag",     group = "client" }),
   awful.key({ modkey,           }, "o",      function (c) c:move_to_screen() end,
      { description = "Other screen", group = "client" }),
   awful.key({ modkey, "Shift"   }, "m",
      function (c)
         c.maximized = not c.maximized
         c:raise()
      end,
      { description = "(Un)maximize", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
   globalkeys = gears.table.join(globalkeys,
                                 -- View tag only.
                                 awful.key({ modkey }, "#" .. i + 9,
                                    function ()
                                       local screen = awful.screen.focused()
                                       local tag = screen.tags[i]
                                       if tag then
                                          tag:view_only()
                                       end
                                    end,
                                    { description = "view tag #"..i, group = "tag" }),
                                 -- Toggle tag display.
                                 awful.key({ modkey, "Control" }, "#" .. i + 9,
                                    function ()
                                       local screen = awful.screen.focused()
                                       local tag = screen.tags[i]
                                       if tag then
                                          awful.tag.viewtoggle(tag)
                                       end
                                    end,
                                    { description = "toggle tag #" .. i, group = "tag" }),
                                 -- Move client to tag.
                                 awful.key({ modkey, "Shift" }, "#" .. i + 9,
                                    function ()
                                       if client.focus then
                                          local tag = client.focus.screen.tags[i]
                                          if tag then
                                             client.focus:move_to_tag(tag)
                                          end
                                       end
                                    end,
                                    { description = "move focused client to tag #"..i, group = "tag" }),
                                 -- Toggle tag on focused client.
                                 awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                                    function ()
                                       if client.focus then
                                          local tag = client.focus.screen.tags[i]
                                          if tag then
                                             client.focus:toggle_tag(tag)
                                          end
                                       end
                                    end,
                                    { description = "toggle focused client on tag #" .. i, group = "tag" })
   )
end

clientbuttons = gears.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
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
                    placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
   },

   -- Floating clients.
   { rule_any = {
        instance = {
           "DTA",  -- Firefox addon DownThemAll.
           "copyq",  -- Includes session name in class.
        },
        class = {
           "Arandr",
           "Gpick",
           "Kruler",
           "MessageWin",  -- kalarm.
           "Sxiv",
           "Wpa_gui",
           "pinentry",
           "veromix",
           "xtightvncviewer" },

        name = {
           "Event Tester",  -- xev.
        },
        role = {
           "AlarmWindow",  -- Thunderbird's calendar.
           "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
   }, properties = { floating = true }},

   -- Add titlebars to normal clients and dialogs
   { rule_any = {type = { "normal", "dialog" }
                }, properties = { titlebars_enabled = true }
   },

   -- Set Firefox to always map on the tag named "2" on screen 1.
   -- { rule = { class = "Firefox" },
   --   properties = { screen = 1, tag = "2" } },
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

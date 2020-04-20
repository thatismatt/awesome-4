---------------------------------
-- thatismatt's awesome config --
---------------------------------

gears          = require("gears")
gfs            = require("gears.filesystem")
awful          = require("awful")
                 require("awful.autofocus")
wibox          = require("wibox")
beautiful      = require("beautiful")
naughty        = require("naughty")
hotkeys_popup  = require("awful.hotkeys_popup").widget
                 require("awful.hotkeys_popup.keys")
prime          = require("prime")
utils          = require("utils")
fennelview     = require("fennelview")
status_bar     = require("status_bar")

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
         utils.log("Runtime error: \n" .. tostring(err))
         in_error = false
      end
   )
end
-- }}}

awesome.connect_signal("debug::deprecation", utils.log)

-- HACK: reduce notification icon size, workaround for https://github.com/awesomeWM/awesome/issues/1862
naughty.config.defaults.icon_size = 64

home_dir = os.getenv("HOME")

-- {{{ Prime - extra commands
prime.add_commands({
      d = {
         name = "dump",
         handle = fennelview
      },
      l = {
         name = "log",
         handle = function (v)
            utils.log(tostring(v))
            return "LOGGED"
         end
      },
      k = {
         name = "keys",
         handle = function (v)
            return fennelview(utils.sort(utils.keys(v)))
         end
      },
      v = {
         name = "vals",
         handle = function (v)
            return fennelview(utils.vals(v))
         end
      }
})
prime.default_command_id = "d"
-- }}}

-- {{{ Variable definitions
beautiful.init(gfs.get_dir("config") .. "theme.lua")

terminal = "x-terminal-emulator"
emacs = "emacsclient -c -a="

modkey = "Mod4"
altkey = "Mod1"

local bindings = {};

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.tile.top,
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

-- {{{ Scripts
scripts = {}
scripts.dir = home_dir .. "/scripts"
scripts.screen_auto   = scripts.dir .. "/screen-auto.sh"
scripts.screen_dual   = scripts.dir .. "/screen-dual.sh"
scripts.screen_single = scripts.dir .. "/screen-single.sh"
scripts.screen_mirror = scripts.dir .. "/screen-mirror.sh"
-- }}}

-- {{{ Helper functions
local function client_menu_toggle ()
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

local function focus_other_screen ()
   awful.screen.focus_relative(1)
   if client.focus and awful.screen.focused() ~= client.focus.screen then
      client.focus = nil
   end
end

local function restore_and_focus ()
   local restored = awful.client.restore(mouse.screen)
   if restored then
      client.focus = restored
      restored:raise()
   end
end

local function focus_raise (direction)
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
         -- HACK: try to stop the mouse pointer "jumping"
         -- TODO: fix the case where the mouse isn't over the tasklist on the other screen
         if awful.screen.focused() ~= client_to_focus.screen then
            awful.screen.focus(client_to_focus.screen)
         end
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
   { "Quit",    function () awesome.quit() end}
}

menu.power = {
   { "Power Off", "systemctl poweroff",  menu.icon("actions", "system-shutdown") },
   { "Suspend",   "systemctl suspend",   menu.icon("apps", "system-suspend") },
   { "Restart",   "systemctl reboot",    menu.icon("apps", "system-restart") }
}

menu.screens = {
   { "Auto",   scripts.screen_auto },
   { "Single", scripts.screen_single },
   { "Dual",   scripts.screen_dual },
   { "Mirror", scripts.screen_mirror },
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
-- }}}

-- {{{ Wibar
-- Create a textclock widget
local textclock = wibox.widget.textclock(" %a %d %b %Y, %H:%M ")
local calendar = awful.widget.calendar_popup.month({ position = "tr", font = beautiful.font })
local calendar_toggle = function ()
   calendar:set_screen(mouse.screen)
   calendar:toggle()
end
textclock:buttons(gears.table.join(awful.button({ }, 1, calendar_toggle)))

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
   awful.button({ }, 1, function (t) t:view_only() end),
   awful.button({ modkey }, 1, function (t)
         if client.focus then
            client.focus:move_to_tag(t)
         end
   end),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function (t)
         if client.focus then
            client.focus:toggle_tag(t)
         end
   end),
   awful.button({ }, 4, function (t) awful.tag.viewprev(t.screen) end),
   awful.button({ }, 5, function (t) awful.tag.viewnext(t.screen) end)
)

local function tasklist_buttons (s)
   return gears.table.join(
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
      -- alternative to above for when middle click is tricky, e.g. touchpad
      awful.button({ "Control" }, 3, function (c) c:kill() end),
      awful.button({ }, 3, client_menu_toggle()),
      -- TODO: focus the screen first - e.g. awful.screen.focus(mouse.screen)
      awful.button({ }, 4, function () awful.client.focus.byidx(-1) end),
      awful.button({ }, 5, function () awful.client.focus.byidx(1)  end)
   )
end

local function set_wallpaper (s)
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

local function screen_tags (s, names)
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

awful.screen.connect_for_each_screen(function (s)

      -- Wallpaper
      set_wallpaper(s)

      -- Create a promptbox for each screen
      s.promptbox = awful.widget.prompt()
      -- Create an imagebox widget which will contain an icon indicating which layout we're using.
      -- We need one layoutbox per screen.
      s.layoutbox = awful.widget.layoutbox(s)
      s.layoutbox:buttons(gears.table.join(
                               awful.button({ }, 1, function () awful.layout.inc( 1) end),
                               awful.button({ }, 3, function () awful.layout.inc(-1) end),
                               awful.button({ }, 4, function () awful.layout.inc(-1) end),
                               awful.button({ }, 5, function () awful.layout.inc( 1) end)))
      -- Create a taglist widget
      s.taglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

      -- Create a tasklist widget
      s.tasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons(s))

      -- Create the wibox
      s.wibox_top = awful.wibar({ position = "top", screen = s })

      -- Add widgets to the wibox
      s.wibox_top:setup {
         layout = wibox.layout.align.horizontal,
         { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            menu.launcher,
            s.taglist,
            s.promptbox,
         },
         s.tasklist, -- Middle widget
         { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            textclock,
            s.layoutbox,
         },
      }

      -- status_bar on last screen only
      if s.index == screen.count() then
         status_bar.init(s)
      end

end)
-- }}}

-- {{{ Mouse bindings
bindings.mouse = gears.table.join(
   awful.button({ }, 3, function () menu.main:toggle() end)
)
-- }}}

-- {{{ Key bindings
bindings.keys = gears.table.join(
   awful.key({ modkey,           }, "s",       hotkeys_popup.show_help,                                { description = "Hotkeys",               group = "awesome" }),
   awful.key({ modkey, "Control" }, "s",       function () awful.spawn(scripts.screen_auto) end,       { description = "Auto Detect Screens",   group = "screen" }),
   awful.key({ modkey,           }, "z",       menu.main.toggle_at_corner,                             { description = "Menu",                  group = "awesome" }),
   awful.key({ modkey, "Control" }, "r",       awesome.restart,                                        { description = "Restart",               group = "awesome" }),
   awful.key({ modkey,           }, "t",       function () awful.spawn(terminal) end,                  { description = "Terminal",              group = "launcher" }),
   awful.key({ modkey,           }, "e",       function () awful.spawn(emacs) end,                     { description = "Emacs",                 group = "launcher" }),
   awful.key({ modkey,           }, "w",       function () awful.spawn("x-www-browser") end,           { description = "Web Browser",           group = "launcher" }),
   awful.key({ modkey,           }, "f",       function () awful.spawn("thunar") end,                  { description = "Thunar",                group = "launcher" }),
   awful.key({ modkey,           }, "v",       function () awful.spawn("pavucontrol") end,             { description = "Volume",                group = "launcher" }),
   awful.key({ modkey,           }, "Left",    awful.tag.viewprev,                                     { description = "View Previous",         group = "tag" }),
   awful.key({ modkey,           }, "Right",   awful.tag.viewnext,                                     { description = "View Next",             group = "tag" }),
   awful.key({ modkey,           }, "j",       awful.tag.viewprev,                                     { description = "View Previous",         group = "tag" }),
   awful.key({ modkey,           }, "l",       awful.tag.viewnext,                                     { description = "View Next",             group = "tag" }),
   awful.key({ modkey,           }, "Escape",  awful.tag.history.restore,                              { description = "Go Back",               group = "tag" }),
   awful.key({ modkey,           }, "Down",    focus_raise(1),                                         { description = "Next",                  group = "client" }),
   awful.key({ modkey,           }, "Up",      focus_raise(-1),                                        { description = "Previous",              group = "client" }),
   awful.key({ modkey,           }, "k",       focus_raise(1),                                         { description = "Next",                  group = "client" }),
   awful.key({ modkey,           }, "i",       focus_raise(-1),                                        { description = "Previous",              group = "client" }),
   awful.key({ modkey            }, "o",       focus_other_screen,                                     { description = "Other Screen",          group = "screen" }),
   awful.key({ modkey, "Shift"   }, "Down",    function () awful.client.swap.byidx( 1) end,            { description = "Move next",             group = "client" }),
   awful.key({ modkey, "Shift"   }, "Up",      function () awful.client.swap.byidx(-1) end,            { description = "Move previous",         group = "client" }),
   awful.key({ modkey, "Shift"   }, "k",       function () awful.client.swap.byidx( 1) end,            { description = "Move next",             group = "client" }),
   awful.key({ modkey, "Shift"   }, "i",       function () awful.client.swap.byidx(-1) end,            { description = "Move previous",         group = "client" }),
   awful.key({ modkey,           }, "u",       awful.client.urgent.jumpto,                             { description = "Jump to urgent",        group = "client" }),
   awful.key({ modkey,           }, "]",       function () awful.tag.incmwfact( 0.05) end,             { description = "Increase master width", group = "layout" }),
   awful.key({ modkey,           }, "[",       function () awful.tag.incmwfact(-0.05) end,             { description = "Decrease master width", group = "layout" }),
   awful.key({ modkey, "Shift"   }, "[",       function () awful.tag.incnmaster( 1, nil, true) end,    { description = "Increase #masters",     group = "layout" }),
   awful.key({ modkey, "Shift"   }, "]",       function () awful.tag.incnmaster(-1, nil, true) end,    { description = "Decrease #masters",     group = "layout" }),
   awful.key({ modkey, "Control" }, "[",       function () awful.tag.incncol( 1, nil, true) end,       { description = "Increase #columns",     group = "layout" }),
   awful.key({ modkey, "Control" }, "]",       function () awful.tag.incncol(-1, nil, true) end,       { description = "Decrease #columns",     group = "layout" }),
   awful.key({ modkey,           }, "space",   function () awful.layout.inc( 1) end,                   { description = "Next layout",           group = "layout" }),
   awful.key({ modkey, "Shift"   }, "space",   function () awful.layout.inc(-1) end,                   { description = "Previous layout",       group = "layout" }),
   awful.key({ modkey, "Shift"   }, "r",       restore_and_focus,                                      { description = "Restore",               group = "client" }),
   awful.key({ modkey            }, "r",       function () awful.screen.focused().promptbox:run() end, { description = "Run prompt",            group = "launcher" })
)

local function tag_next (c)
   awful.screen.focus(c.screen) -- if the focused screen isn't the client's screen then client is
                                -- associated with the tag for the wrong screen, which is odd!
   awful.tag.viewnext()
   c:tags({ c.screen.selected_tag })
   client.focus = c
end

local function tag_prev (c)
   awful.screen.focus(c.screen) -- if the focused screen isn't the client's screen then client is
                                -- associated with the tag for the wrong screen, which is odd!
   awful.tag.viewprev()
   c:tags({ c.screen.selected_tag })
   client.focus = c
end

bindings.client = {}

bindings.client.buttons = gears.table.join(
   awful.button({        }, 1, function (c) client.focus = c ; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize)
)

bindings.client.keys = gears.table.join(
   awful.key({ modkey, "Shift"   }, "m",      function (c) c.maximized = not c.maximized ; c:raise() end, { description = "(Un)maximize", group = "client" }),
   awful.key({ modkey, "Shift"   }, "n",      function (c) c.minimized = true end,                        { description = "Minimize",     group = "client" }),
   awful.key({ modkey, "Shift"   }, "f",      awful.client.floating.toggle,                               { description = "(Un)float",    group = "client" }),
   awful.key({ modkey, "Shift"   }, "t",      function (c) c.ontop = not c.ontop end,                     { description = "(Un)top",      group = "client" }),
   awful.key({ modkey, "Shift"   }, "Left",   tag_prev,                                                   { description = "Previous tag", group = "client" }),
   awful.key({ modkey, "Shift"   }, "Right",  tag_next,                                                   { description = "Next tag",     group = "client" }),
   awful.key({ modkey, "Shift"   }, "j",      tag_prev,                                                   { description = "Previous tag", group = "client" }),
   awful.key({ modkey, "Shift"   }, "l",      tag_next,                                                   { description = "Next tag",     group = "client" }),
   awful.key({ modkey,           }, "Return", function (c) c:swap(awful.client.getmaster()) end,          { description = "Masterify",    group = "client" }),
   awful.key({ modkey, "Shift"   }, "o",      function (c) c:move_to_screen() end,                        { description = "Other screen", group = "client" }),
   awful.key({ modkey, "Control" }, "q",      function (c) c:kill() end,                                  { description = "Quit",         group = "client" }),
   awful.key({ modkey, "Shift"   }, "d",      function (c) debug_client = c end,                          { description = "Debug client", group = "client" })
)

bindings.tags = utils.flatmap(
   utils.range(tags.count),
   function (i)
      return gears.table.join(
         awful.key({ modkey }, i,
            function ()
               tags[i]:view_only()
               awful.screen.focus(tags[i].screen) -- move mouse to tag's screen
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

-- Audio
local function amixer_command (action)
   return function () awful.spawn("amixer -q -D pulse set Master " .. action, false) end
end
local function mpc_command (action)
   return function () awful.spawn("mpc " .. action, false) end
end
local function mpc_status ()
   awful.spawn.easy_async("mpc status", function (stdout, stderr, reason, exit_code) naughty.notify({ text = stdout }) end)
end
bindings.audio = gears.table.join(
   awful.key({                 }, "XF86AudioMute",        amixer_command("toggle"), { description = "Toggle mute",     group = "audio" }),
   awful.key({                 }, "XF86AudioRaiseVolume", amixer_command("5%+"),    { description = "Increase volume", group = "audio" }),
   awful.key({                 }, "XF86AudioLowerVolume", amixer_command("5%-"),    { description = "Decrease volume", group = "audio" }),
   awful.key({                 }, "XF86AudioPlay",        mpc_command("toggle"),    { description = "Play/Pause",      group = "audio" }),
   awful.key({ modkey          }, "XF86AudioPlay",        mpc_status,               { description = "MPD status",      group = "audio" }),
   awful.key({ modkey          }, "XF86AudioMute",        mpc_command("toggle"),    { description = "Play/Pause",      group = "audio" }),
   awful.key({ modkey          }, "XF86AudioRaiseVolume", mpc_command("seek +60"),  { description = "Fastforward",     group = "audio" }),
   awful.key({ modkey          }, "XF86AudioLowerVolume", mpc_command("seek -60"),  { description = "Rewind",          group = "audio" }),
   awful.key({ modkey, "Shift" }, "XF86AudioRaiseVolume", mpc_command("next"),      { description = "Next track",      group = "audio" }),
   awful.key({ modkey, "Shift" }, "XF86AudioLowerVolume", mpc_command("prev"),      { description = "Previous track",  group = "audio" })
)

-- Backlight Keys -- requires: https://github.com/haikarainen/light
local function backlight_key (action)
   return function () awful.spawn("light " .. action, false) end
end
bindings.backlight = gears.table.join(
   awful.key({ }, "XF86MonBrightnessUp",   backlight_key("-A 5")),
   awful.key({ }, "XF86MonBrightnessDown", backlight_key("-U 5"))
)

-- Set keys
root.keys(gears.table.join(bindings.keys, bindings.tags, bindings.audio, bindings.backlight))
root.buttons(bindings.mouse)
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
                    keys = bindings.client.keys,
                    buttons = bindings.client.buttons,
                    screen = awful.screen.preferred,
                    placement = awful.placement.no_overlap + awful.placement.no_offscreen } }
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

client.connect_signal("focus", function (c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function (c) c.border_color = beautiful.border_normal end)
-- }}}

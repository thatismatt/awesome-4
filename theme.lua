--------------------------------
-- thatismatt's awesome theme --
--------------------------------

-- load the default theme to use it as the base for this custom theme
local success, theme = pcall(function () return dofile("/usr/share/awesome/themes/default/theme.lua") end)

local gfs = require("gears.filesystem")

theme.font          = "Liberation Sans 12"

theme.fg_normal     = "#999999"
theme.bg_normal     = "#222222"

theme.fg_focus      = "#eeeeee"
theme.bg_focus      = "#444444"

theme.fg_urgent     = "#dddddd"
theme.bg_urgent     = "#ff00ff"

theme.fg_minimize   = "#555555"
theme.bg_minimize   = "#222222"

theme.border_width  = 5
theme.border_normal = "#444444"
theme.border_focus  = "#9900ff"
theme.border_marked = "#ff00ff"

theme.hotkeys_modifiers_fg = "#9900ff"

-- There are other variable sets overriding the default one when defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]

theme.useless_gap = 5
theme.notification_icon_size = 36

-- theme.menu_submenu_icon = "/usr/share/awesome/themes/default/submenu.png"
theme.menu_height = 24
theme.menu_width  = 150

theme.wallpaper = os.getenv("HOME") .. "/Pictures/wallpaper"

-- theme.layout_matilla = "/usr/share/awesome/themes/default/layouts/tilew.png"

theme.awesome_icon = gfs.get_dir("config") .. "awesome_icon.png"

-- theme.tasklist_plain_task_name = true

-- see /usr/share/awesome/lib/awful/widget/calendar_popup.lua
theme.calendar_focus_border_width = 0
theme.calendar_normal_border_width = 0
theme.calendar_header_border_width = 0
theme.calendar_weekday_border_width = 0
theme.calendar_month_padding = 10

return theme

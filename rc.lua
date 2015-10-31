--[[

  Powerarrow Darker Awesome WM config 2.0
  github.com/copycat-killer

--]]

-- {{{ Required libraries
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
                  require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local drop      = require("scratchdrop")
local lain      = require("lain")
local treesome      = require("treesome")
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, an error happened!",
                     text = err })
    in_error = false
  end)
end
-- }}}

-- {{{ Autostart applications
function autostart(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

autostart("urxvtd")
autostart("unclutter -root")
autostart("spacefm -d")
autostart("nm-applet")
autostart("pulseaudio --start")
autostart("compton -b --config ~/.compton.conf")

-- }}}

-- {{{ Variable definitions

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/multicolor/theme.lua")

-- common
modkey     = "Mod4"
altkey     = "Mod1"
terminal   = "urxvt" or "xterm"
editor     = os.getenv("EDITOR") or "vim" or "vi" or "nano"
editor_cmd = terminal .. " -e " .. editor

-- user defined
browser    = "chromium"
browser2   = "luakit"
gui_editor = "vim"
graphics   = "pinta"
mail       = terminal .. " -e mutt "
iptraf     = terminal .. " -g 180x54-20+34 -e sudo iptraf-ng -i all "
musicplr   = "pianobar"

local layouts = {
  treesome,
  awful.layout.suit.tile,
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.floating,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral,
}
-- }}}

-- {{{ Tags
tags = {
   names = { "1", "2", "3", "4", "Float"},
   layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[2] }
}

for s = 1, screen.count() do
   tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Menu
mymainmenu = awful.menu.new({ items = require("menugen").build_menu(),
                              theme = { height = 16, width = 130 }})
-- }}}

-- {{{ Wibox
markup = lain.util.markup
separators = lain.util.separators
markup_icon = function(unicode, options)
  local options = options or {}
  local font_prop = 'font="' .. (options.font or 'FontAwesome') .. '" '
  local fg_prop = options.color and 'foreground="' .. tostring(options.color) .. '" ' or ''
  local bg_prop = options.bg and 'background="' .. tostring(options.bg) .. '" ' or ''
  local text = tostring(unicode)
  return '<span ' .. font_prop .. fg_prop .. bg_prop .. '>' .. text .. '</span>'
end

-- Unicode Icons (FontAwesome)
fa_battery_empty = '&#xf244;'
fa_battery_low = '&#xf243;'
fa_battery_half = '&#xf242;'
fa_battery_high = '&#xf241;'
fa_battery_full = '&#xf240;'
fa_battery_charging = '&#xf1e6;'
fa_net_up = '&#xf093;'
fa_net_down = '&#xf019;'
fa_filesystem = '&#xf1c0;'
fa_memory = '&#xf080;'
fa_cpu = '&#xf085;'
fa_temp = '&#xf06d;'
fa_volume_high = '&#xf028;'
fa_volume_low = '&#xf027;'
fa_volume_mute = '&#xf026;'
fa_clock = '&#xf017;'

-- Color constants
color_download = "#7AC82E"
color_upload = "#C82E7A"
color_temp_low = "#00FF00"
color_temp_medium = "#FFFF00"
color_temp_high = "#FF0000"

-- Textclock
clockicon = wibox.widget.textbox('')
clockicon:set_markup(markup_icon(fa_clock))
mytextclock = awful.widget.textclock(" %a %d %b  %H:%M")

mytextclock = lain.widgets.abase({
    timeout  = 60,
    cmd      = "date +'%a %d %b %R'",
    settings = function()
        widget:set_text(" " .. output)
    end
})

-- calendar
-- lain.widgets.calendar:attach(mytextclock, { font_size = 10 })

-- Mail IMAP check
mailicon = wibox.widget.imagebox(beautiful.widget_mail)
mailicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(mail) end)))
--[[ commented because it needs to be set before use
mailwidget = lain.widgets.imap({
    timeout  = 180,
    server   = "server",
    mail     = "mail",
    password = "keyring get mail",
    settings = function()
        if mailcount > 0 then
            widget:set_text(" " .. mailcount .. " ")
            mailicon:set_image(beautiful.widget_mail_on)
        else
            widget:set_text("")
            mailicon:set_image(beautiful.widget_mail)
        end
    end
})
]]

-- MPD
--[[ commented out until I figure out pianobar integration
mpdicon = wibox.widget.imagebox(beautiful.widget_note)
mpdicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(musicplr) end)))
mpdwidget = lain.widgets.mpd({
    settings = function()
        if mpd_now.state == "play" then
            artist = " " .. mpd_now.artist .. " "
            title  = mpd_now.title  .. " "
            mpdicon:set_image(beautiful.widget_note_on)
        elseif mpd_now.state == "pause" then
            artist = " mpd "
            title  = "paused "
        else
            artist = ""
            title  = ""
            mpdicon:set_image(beautiful.widget_note)
        end

        widget:set_markup(markup("#EA6F81", artist) .. title)
    end
})
]]

-- MEM
memicon = wibox.widget.textbox('')
memicon:set_markup(markup_icon(fa_memory))

memwidget = lain.widgets.mem({
    settings = function()
        widget:set_text(" " .. mem_now.used .. "MB ")
    end
})

-- CPU
cpuicon = wibox.widget.textbox('')
cpuicon:set_markup(markup_icon(fa_cpu))

cpuwidget = lain.widgets.cpu({
    settings = function()
        widget:set_text(" " .. cpu_now.usage .. "% ")
    end
})

-- Coretemp
tempicon = wibox.widget.textbox('')
tempwidget = lain.widgets.temp({
    settings = function()
        local color = color_temp_low
        if tonumber(coretemp_now) < 60 then
            color = color_temp_low
        elseif tonumber(coretemp_now) < 80 then
            color = color_temp_medium
        else
            color = color_temp_high
        end
        tempicon:set_markup(markup_icon(fa_temp, {color=color}))
        widget:set_markup(markup(color, " " .. coretemp_now .. "°C "))
    end
})

-- / fs
fsicon = wibox.widget.textbox('')
fsicon:set_markup(markup_icon(fa_filesystem))

fswidget = lain.widgets.fs({
    partition = "/home",
    settings = function()
        widget:set_text(" " .. fs_now.used .. "% ")
    end
})

-- Battery
baticon = wibox.widget.textbox('')
baticon:set_markup(markup_icon(fa_battery_half))

batwidget = lain.widgets.bat({
    battery = "BAT0",
    settings = function()
        if bat_now.perc == "N/A" then
            widget:set_markup(" AC ")
            baticon:set_markup(markup_icon(fa_battery_charging))
            return
        elseif bat_now.status == "Charging" then
            baticon:set_markup(markup_icon(fa_battery_charging))
        elseif tonumber(bat_now.perc) <= 5 then
            baticon:set_markup(markup_icon(fa_battery_empty))
        elseif tonumber(bat_now.perc) <= 35 then
            baticon:set_markup(markup_icon(fa_battery_low))
        elseif tonumber(bat_now.perc) <= 65 then
            baticon:set_markup(markup_icon(fa_battery_half))
        elseif tonumber(bat_now.perc) <= 95 then
            baticon:set_markup(markup_icon(fa_battery_high))
        else
            baticon:set_markup(markup_icon(fa_battery_full))
        end
        widget:set_markup(" " .. bat_now.perc .. "% ")
    end
})

-- ALSA volume
volicon = wibox.widget.textbox('')
volicon:set_markup(markup_icon(fa_volume_high))

volumewidget = lain.widgets.alsa({
    settings = function()
        if volume_now.status == "off" then
            volicon:set_markup(markup_icon(fa_volume_mute))
        elseif tonumber(volume_now.level) == 0 then
            volicon:set_markup(markup_icon(fa_volume_mute))
        elseif tonumber(volume_now.level) <= 50 then
            volicon:set_markup(markup_icon(fa_volume_low))
        else
            volicon:set_markup(markup_icon(fa_volume_high))
        end

        widget:set_text(" " .. volume_now.level .. "% ")
    end
})

-- Net
netdownicon = wibox.widget.textbox('')
netdownicon:set_markup(markup_icon(fa_net_down, {color=color_download}))
netdownicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))
netdowntext = wibox.widget.textbox('0.0')

netupicon = wibox.widget.textbox('')
netupicon:set_markup(markup_icon(fa_net_up, {color=color_upload}))
netupicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))
netuptext = wibox.widget.textbox('0.0')

netwidget = lain.widgets.net({
    settings = function()
        netuptext:set_markup(markup(color_upload, " " .. net_now.sent))
        netdowntext:set_markup(markup(color_download, " " .. net_now.received))
    end
})

-- Separators
spr = wibox.widget.textbox('  ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = separators.arrow_left(beautiful.bg_focus, "alpha")
arrl_ld = separators.arrow_left("alpha", beautiful.bg_focus)

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
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do

    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                            awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                            awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                            awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                            awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 64 })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(spr)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(spr)

    -- Widgets that are aligned to the upper right
    local right_layout_toggle = true
    local function right_layout_add (...)
        local arg = {...}
        if right_layout_toggle then
            right_layout:add(arrl_ld)
            for i, n in pairs(arg) do
                right_layout:add(wibox.widget.background(n ,beautiful.bg_focus))
            end
        else
            right_layout:add(arrl_dl)
            for i, n in pairs(arg) do
                right_layout:add(n)
            end
        end
        right_layout_toggle = not right_layout_toggle
    end
    local function right_layout_add_spr (...)
      right_layout_add(...)
      right_layout_add(spr)
    end

    right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout_add(spr)
    right_layout_add(arrl)
    right_layout_add_spr(baticon, batwidget)
    right_layout_add_spr(volicon, volumewidget)
    --right_layout_add(mailicon, mailwidget)
    --right_layout_add(mpdicon, mpdwidget)
    right_layout_add_spr(memicon, memwidget)
    right_layout_add_spr(fsicon, fswidget)
    right_layout_add_spr(cpuicon, cpuwidget)
    right_layout_add_spr(tempicon, tempwidget)
    right_layout_add(netdownicon, netdowntext)
    right_layout_add_spr(netupicon, netuptext)
    right_layout_add(clockicon, mytextclock)
    right_layout_add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)
    mywibox[s]:set_widget(layout)

end
-- }}}

-- {{{ Mouse Bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    -- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
    awful.key({ altkey }, "p", function() os.execute("screenshot") end),

    -- Tag browsing
    awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),

    -- Non-empty tag browsing
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end),

    -- Default client focus
    awful.key({ altkey }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ altkey }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Show Menu
    awful.key({ modkey }, "w",
        function ()
            mymainmenu:show({ keygrabber = true })
        end),
    -- Menubar
    -- awful.key({ modkey }, "p", function() menubar.show() end), -- Default M-p command, dmenu is a better/faster alternative
    awful.key({ modkey }, "p", function () awful.util.spawn_with_shell("dmenu_run -i -nb '" .. beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal .. "' -sb '" .. beautiful.bg_focus .. "' -sf '" .. beautiful.fg_focus .. "' -fn 'Terminus:size=19'") end),

    -- Screen lock
    awful.key({ modkey, "Shift" }, "l", function () awful.util.spawn_with_shell("physlock") end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ altkey, "Shift"   }, "l",      function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ altkey, "Shift"   }, "h",      function () awful.tag.incmwfact(-0.05)     end),
    awful.key({ modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)       end),
    awful.key({ modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)       end),
    awful.key({ modkey, "Control" }, "l",      function () awful.tag.incncol(-1)          end),
    awful.key({ modkey, "Control" }, "h",      function () awful.tag.incncol( 1)          end),
    awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1)  end),
    awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1)  end),
    awful.key({ modkey, "Control" }, "n",      awful.client.restore),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

    -- Dropdown terminal
    awful.key({ modkey,	          }, "z",      function () drop(terminal) end),

    -- Widgets popups
    awful.key({ altkey,           }, "c",      function () lain.widgets.calendar:show(7) end),
    awful.key({ altkey,           }, "h",      function () fswidget.show(7) end),

    -- ALSA volume control
    awful.key({ altkey }, "Up",
        function ()
            os.execute(string.format("amixer set %s 1%%+", volumewidget.channel))
            volumewidget.update()
        end),
    awful.key({ altkey }, "Down",
        function ()
            os.execute(string.format("amixer set %s 1%%-", volumewidget.channel))
            volumewidget.update()
        end),
    awful.key({ altkey }, "m",
        function ()
            os.execute(string.format("amixer set %s toggle", volumewidget.channel))
            volumewidget.update()
        end),
    awful.key({ altkey, "Control" }, "m",
        function ()
            os.execute(string.format("amixer set %s 100%%", volumewidget.channel))
            volumewidget.update()
        end),

    -- MPD control
    awful.key({ altkey, "Control" }, "Up",
        function ()
            awful.util.spawn_with_shell("mpc toggle || ncmpc toggle || pms toggle")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Down",
        function ()
            awful.util.spawn_with_shell("mpc stop || ncmpc stop || pms stop")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Left",
        function ()
            awful.util.spawn_with_shell("mpc prev || ncmpc prev || pms prev")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Right",
        function ()
            awful.util.spawn_with_shell("mpc next || ncmpc next || pms next")
            mpdwidget.update()
        end),

    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    -- awful.key({ modkey }, "q", function () awful.util.spawn(browser) end), -- Spawned below under Applications
    -- awful.key({ modkey }, "i", function () awful.util.spawn(browser2) end), -- Spawned below under Applications
    awful.key({ modkey }, "s", function () awful.util.spawn(gui_editor) end),
    awful.key({ modkey }, "g", function () awful.util.spawn(graphics) end),

    -- Brightness control (Script which uses 'volnoti' as notification) SYNTAX: up/down | percentagpts/kbdbrighE
    -- awful.key({ }, "XF86KbdBrightnessUp", function () awful.util.spawn_with_shell("echo 3 > /sys/class/leds/asus\\:\\:kbd_backlight/brightness") end),
    -- awful.key({ }, "XF86KbdBrightnessDown", function () awful.util.spawn_with_shell("echo 0 > /sys/class/leds/asus\\:\\:kbd_backlight/brightness") end),
    -- awful.key({ }, "XF86MonBrightnessUp",   function () awful.util.spawn_with_shell(awful.util.getdir("config") .. "/scripts/brightness.sh up") end),
    -- awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn_with_shell(awful.util.getdir("config") .. "/scripts/brightness.sh down") end),
    awful.key({ }, "XF86KbdBrightnessUp", function () awful.util.spawn_with_shell("xbacklight -inc 10%") end),
    awful.key({ }, "XF86KbdBrightnessDown", function () awful.util.spawn_with_shell("xbacklight -dec 10%") end),

    -- Enable Touchpad only when key is held
    awful.key({ }, "Menu", nil, function () awful.util.spawn_with_shell('synclient TouchpadOff=1') end),
    awful.key({ }, "Menu", function () awful.util.spawn_with_shell('synclient TouchpadOff=0') end),

    -- Volume control
    awful.key({ }, "XF86AudioLowerVolume", function ()
      awful.util.spawn("amixer set Master 2%-")
      volumewidget.update() end),
    awful.key({ }, "XF86AudioRaiseVolume", function ()
      awful.util.spawn("amixer set Master 2%+")
      volumewidget.update() end),
    awful.key({ }, "XF86AudioMute", function ()
      awful.util.spawn("amixer set Master toggle")
      volumewidget.update() end),

    -- Applications
    awful.key({ modkey }, "d", function () awful.util.spawn_with_shell(browser) end),
    awful.key({ modkey, 'Shift' }, "d", function () awful.util.spawn_with_shell(browser2) end),

    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
	                   size_hints_honor = false } },
    --{ rule = { class = "URxvt" },
    --      properties = { opacity = 0.99 } },

    { rule = { class = "MPlayer" },
          properties = { floating = true } },

    { rule = { class = "Dwb" },
          properties = { tag = tags[1][1] } },

    { rule = { class = "Iron" },
          properties = { tag = tags[1][1] } },

    { rule = { instance = "plugin-container" },
          properties = { tag = tags[1][1] } },

	  { rule = { class = "Gimp" },
     	    properties = { tag = tags[1][4] } },

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized_horizontal = true,
                         maximized_vertical = true } },
}
-- }}}

-- {{{ Signals
-- signal function to execute when a new client appears.
local sloppyfocus_last = {c=nil}
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    client.connect_signal("mouse::enter", function(c)
         if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
             -- Skip focusing the client if the mouse wasn't moved.
             if c ~= sloppyfocus_last.c then
                 client.focus = c
                 sloppyfocus_last.c = c
             end
         end
     end)

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
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

        -- widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- the title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c,{size=16}):set_widget(layout)
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_color = beautiful.border_normal
        else
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then -- Fine grained borders and floaters control
            for _, c in pairs(clients) do -- Floaters always have borders
                if awful.client.floating.get(c) or layout == "floating" then
                    c.border_width = beautiful.border_width

                -- No borders with only one visible client
                elseif #clients == 1 or layout == "max" then
                    c.border_width = 0
                else
                    c.border_width = beautiful.border_width
                end
            end
        end
      end)
end
-- }}}

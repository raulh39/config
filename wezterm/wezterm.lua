local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()
local mux = wezterm.mux

-- Window Style
---------------
config.color_scheme = "Abernathy"
config.color_scheme = "Gruvbox Dark (Gogh)"

config.font = wezterm.font("JetBrainsMonoNL Nerd Font")
config.font_size = 10
config.initial_cols = 200
config.initial_rows = 60
config.use_fancy_tab_bar = true

wezterm.on("update-right-status", function(window, pane)
        window:set_right_status(window:active_workspace() .. "    ")
end)

function tab_title(tab)
        local title = tab.tab_title
        -- if the tab title is explicitly set, take that
        if title and #title > 0 then
          return title
        end
        -- Otherwise, use the title from the active pane in that tab
        return tab.active_pane.title
end

wezterm.on("format-tab-title", function(tab)
        local pane = tab.active_pane
        local title = tab_title(tab)
        if pane.domain_name then
                title = title .. " - (" .. pane.domain_name .. ")"
        end
        return title
end)

wezterm.on("gui-startup", function(cmd)
        local tab, pane, window = mux.spawn_window(cmd or {})
        window:gui_window():maximize()
end)

config.window_frame = {
        -- font = wezterm.font('JetBrainsMonoNL Nerd Font', { weight = 'Bold', italic = false }),
        font_size = 10,
}
-- config.window_background_image = '/home/raul/Imágenes/Vader.jpeg'

-- Keys
-- -----------
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
        {
                key = "|",
                mods = "LEADER",
                action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }),
        },
        {
                key = "-",
                mods = "LEADER",
                action = act.SplitPane({ direction = "Down", size = { Percent = 50 } }),
        },
        { key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
        { key = "e", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|DOMAINS" }) },
        { key = "d", mods = "LEADER", action = act.DetachDomain("CurrentPaneDomain") },
        { key = "UpArrow", mods = "SHIFT", action = act.ScrollByLine(-1) },
        { key = "DownArrow", mods = "SHIFT", action = act.ScrollByLine(1) },
        { key = "UpArrow", mods = "SHIFT|CTRL", action = act.ScrollByLine(-5) },
        { key = "DownArrow", mods = "SHIFT|CTRL", action = act.ScrollByLine(5) },
        { key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
        { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
        { key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
        { key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },
        { key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
        -- { key = 'n',          mods = 'CTRL',        action = act.SwitchWorkspaceRelative(1) },
        -- { key = 'p',          mods = 'CTRL',        action = act.SwitchWorkspaceRelative(-1) },
        {
                key = ",",
                mods = "LEADER",
                action = act.PromptInputLine({
                        description = "Enter new name for tab",
                        action = wezterm.action_callback(function(window, pane, line)
                                if line then
                                        window:active_tab():set_title(line)
                                end
                        end),
                }),
        },
        {
                key = ";",
                mods = "LEADER|SHIFT",
                action = act.PromptInputLine({
                        description = "Enter new name for workspace",
                        action = wezterm.action_callback(function(window, pane, line)
                                if line then
                                        mux.rename_workspace(window:mux_window():get_workspace(), line)
                                end
                        end),
                }),
        },
        {
                key = "l",
                mods = "LEADER",
                action = wezterm.action.SpawnCommandInNewTab({
                        args = { "bash", "-l", "-i" },
                }),
        },
}

-- Domains
-- -----------
config.ssh_domains = {
  {
    name = 'UbuntuVirt',
    remote_address = '192.168.122.25',
    username = 'instalador',
  },
  {
    name = 'devenv',
    remote_address = 'devenv',
  },
}

config.unix_domains = {
        { name = "Linux" }, -- Ensures we are under wezterm-mux-server even in my local machine
}
config.default_gui_startup_args = { "connect", "Linux" } -- By default connect to this Domain

return config

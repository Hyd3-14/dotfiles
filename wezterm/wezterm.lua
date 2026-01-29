-- Pull in the wezterm API
local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true

-- fontサイズ
config.font_size = 12.0

-- IMEで日本語入力
config.use_ime = true

-- 背景の透過（記事は 0.85）
config.window_background_opacity = 0.85

-- Windowsの“ぼかし/マテリアル”（macの blur の代替）
-- 取り得る値: "Auto" / "Disable" / "Acrylic" / "Mica" / "Tabbed"
-- ※ backdrop を効かせるには window_background_opacity < 1.0 が必要
-- ※ "Mica"/"Tabbed" は Win11 build 22621+、最適は opacity=0 推奨
config.win32_system_backdrop = "Mica"

----------------------------------------------------
-- タブ周り（記事の流れを踏襲）
----------------------------------------------------

-- タイトルバーの削除（RESIZEだけ残す）
config.window_decorations = "RESIZE"

-- タブが1つのときはタブバー非表示
config.hide_tab_bar_if_only_one_tab = true

-- タブバーを透明にする（タイトルバー背景）
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

-- タブバーを背景色に合わせる
config.window_background_gradient = {
  colors = { "#000000" },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false

-- タブの閉じるボタンを非表示（Nightly only）
-- winget で入る Stable では使えないので、忠実にやるなら Nightly に寄せる必要がある。
-- まずはコメントアウト推奨。:contentReference[oaicite:7]{index=7}
-- config.show_close_tab_button_in_tabs = false

-- タブ同士の境界線を非表示
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

-- タブの形をカスタマイズ（nerdfonts記号を使う）
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"

  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end

  local edge_foreground = background
  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

return config

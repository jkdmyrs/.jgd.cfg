local wezterm = require 'wezterm'

return {
  default_prog = { 'pwsh.exe', '-NoLogo' },
  default_workspace = 'main',
  automatically_reload_config = true,
  window_close_confirmation = 'NeverPrompt',
  use_dead_keys = false,
  font_size = 11.0,
  color_scheme = 'OneHalfDark',
  -- avoid "OpenGL implementation is too old" on older/VM GPUs
  front_end = 'WebGpu',
  webgpu_power_preference = 'LowPower',
}

return {
  {
    'shfmt',
    'formatting',
    with_config = { extra_args = { '-i', '2', '-ci', '-bn', '-sr' } },
  },
  { 'shellharden', 'formatting' },
  { 'ltcc', 'code_actions', is_custom_tool = true },
  { 'ltcc', 'diagnostics', is_custom_tool = true },
}

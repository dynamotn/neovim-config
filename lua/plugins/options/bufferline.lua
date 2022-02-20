local present, bufferline = pcall(require, 'bufferline')

if not present then
   return
end

bufferline.setup {
    options = {
        numbers = function(opts)
            return string.format('%s', opts.raise(opts.id))
        end,
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = 'slant',
        sort_by = 'tabs',
    },
}

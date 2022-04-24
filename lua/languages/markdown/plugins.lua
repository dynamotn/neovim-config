return function(register_config)
    return {
        {
            'iamcco/markdown-preview.nvim',
            run = 'call mkdp#util#install()',
            config = register_config('markdown_preview'),
        },
    }
end

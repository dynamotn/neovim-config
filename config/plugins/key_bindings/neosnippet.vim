" Use Tab
imap <expr><Tab> dynamo#mapping#Tab()
smap <expr><Tab> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"

" Smart Enter when show completion
imap <expr><CR> dynamo#mapping#Enter()

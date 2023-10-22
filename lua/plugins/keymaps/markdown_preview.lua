local extras = require('util.extras')

return {
  {
    '<Space>lm',
    extras.cmdcr('MarkdownPreview'),
    desc = 'Preview Markdown file',
  },
}

return {
  name = 'beancount',
  description = 'Double-entry accounting from text files, with its checker and formatter',
  homepage = 'https://github.com/beancount/beancount',
  licenses = {
    'GPL-2.0-only',
  },
  languages = {
    'Beancount',
  },
  categories = {
    'Formatter',
    'Linter',
  },
  source = {
    id = 'pkg:pypi/beancount@3.2.3',
    supported_platforms = { 'unix' },
  },
  bin = {
    ['bean-check'] = 'pypi:bean-check',
    ['bean-format'] = 'pypi:bean-format',
  },
}

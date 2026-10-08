return {
  name = 'qmlformat',
  description = 'The QML formatter that comes with Qt Declarative',
  homepage = 'https://github.com/qt/qtdeclarative',
  licenses = {
    'LGPL-3.0-only',
    'GPL-2.0-only',
    'GPL-3.0-only',
  },
  languages = {
    'QML',
  },
  categories = {
    'Formatter',
  },
  -- The system package manager installs it, and dytoy links it onto PATH;
  -- see `tools.mason-dytoy`
  source = {
    id = 'dytoy:qmlformat',
  },
  bin = {
    qmlformat = 'qmlformat',
  },
}

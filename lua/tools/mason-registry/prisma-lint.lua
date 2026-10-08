return {
  name = 'prisma-lint',
  description = 'A linter for Prisma schema files',
  homepage = 'https://github.com/loop-payments/prisma-lint',
  licenses = {
    'MIT',
  },
  languages = {
    'Prisma',
  },
  categories = {
    'Linter',
  },
  source = {
    id = 'pkg:npm/prisma-lint@0.13.1',
  },
  bin = {
    ['prisma-lint'] = 'npm:prisma-lint',
  },
}

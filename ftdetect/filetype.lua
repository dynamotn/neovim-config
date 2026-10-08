vim.g.do_filetype_lua = 1

vim.filetype.add({
  extension = {
    envrc = 'sh',
    ino = 'arduino',
    pde = 'arduino',
    gotmpl = 'gotmpl',
    rasi = 'rasi',
    rofi = 'rasi',
    wofi = 'rasi',
    ebuild = 'sh.ebuild',
    install = 'sh.install',
    promql = 'promql',
    bean = 'beancount',
    snippets = 'snippets',
    dbml = 'dbml',
    d2 = 'd2',
    ipynb = 'ipynb',
    j2 = 'jinja',
    jinja = 'jinja',
    jinja2 = 'jinja',
    djhtml = 'htmldjango',
  },
  filename = {
    ['terragrunt.hcl'] = 'terragrunt',
    ['azure-pipelines.yml'] = 'yaml.az-pl',
    ['docker-compose.yml'] = 'yaml.docker-compose',
    ['PKGBUILD'] = 'sh.PKGBUILD',
  },
  pattern = {
    -- An `ignore` file kept in a repository's `.git` directory. A `filename`
    -- key is matched only against the full path and the tail, so one with a
    -- slash in it never matches, and this takes a pattern instead. git's
    -- per-user ignore file, `$XDG_CONFIG_HOME/git/ignore`, Neovim detects
    -- on its own.
    ['.*/%.git/ignore'] = 'gitignore',

    ['.*%.hcl'] = 'terragrunt',
    ['.*terraform/.*%.hcl'] = 'terragrunt',

    ['.*/defaults/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/host_vars/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/group_vars/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/group_vars/.*/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/playbook.*%.ya?ml'] = 'yaml.ansible',
    ['.*/playbooks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/.*/tasks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/.*/handlers/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/tasks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/molecule/.*%.ya?ml'] = 'yaml.ansible',

    ['openapi.*%.ya?ml'] = 'yaml.openapi',
    ['openapi.*%.json'] = 'json.openapi',

    ['.*%.gitlab%-ci%.ya?ml'] = 'yaml.gitlab',
    ['.*%.github/workflows/.*.ya?ml'] = 'yaml.gh-action',

    ['.*%.component%.html'] = 'htmlangular',
    ['.*%.container%.html'] = 'htmlangular',

    ['.*%.tmpl'] = 'gotmpl',

    -- where Django keeps its templates; a plain HTML file elsewhere in the
    -- project is untouched
    ['.*/templates/.*%.html'] = 'htmldjango',

    ['.*/templates/.*%.tpl'] = 'helm',
    ['.*/templates/.*%.ya?ml'] = 'helm',
    ['helmfile.*%.ya?ml'] = 'helm',
    ['values.*%.yaml'] = 'yaml.helm-values',

    ['.*/hypr/.*%.conf'] = 'hyprlang',

    ['Dockerfile-.*'] = 'dockerfile',
  },
})

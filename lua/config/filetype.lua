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
  },
  filename = {
    ['.git/ignore'] = 'gitignore',
    ['terragrunt.hcl'] = 'terragrunt',
    ['azure-pipelines.yml'] = 'yaml.az-pl',
    ['PKGBUILD'] = 'sh.PKGBUILD',
  },
  pattern = {
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

    ['.*%.gitlab%-ci%.ya?ml'] = 'yaml.gl-ci',
    ['.*%.github/workflows/.*.ya?ml'] = 'yaml.gh-action',

    ['.*%.component%.html'] = 'htmlangular',
    ['.*%.container%.html'] = 'htmlangular',

    ['.*%.tmpl'] = 'gotmpl',

    ['.*/templates/.*%.tpl'] = 'helm',
    ['.*/templates/.*%.ya?ml'] = 'helm',
    ['helmfile.*%.ya?ml'] = 'helm',

    ['.*%.dbml'] = 'dbml',
    ['.*%.d2'] = 'd2',
    ['.*/hypr/.*%.conf'] = 'hyprlang',
  },
})

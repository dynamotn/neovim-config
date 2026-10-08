local h = require('helpers')

dofile(h.root .. '/ftdetect/filetype.lua')

---@param path string
---@return string?
local function match(path) return vim.filetype.match({ filename = path }) end

describe('ftdetect', function()
  local cases = {
    -- extension
    { '/p/.envrc', 'sh' },
    { '/p/sketch.ino', 'arduino' },
    { '/p/sketch.pde', 'arduino' },
    { '/p/page.gotmpl', 'gotmpl' },
    { '/p/theme.rasi', 'rasi' },
    { '/p/x.rofi', 'rasi' },
    { '/p/x.wofi', 'rasi' },
    { '/p/foo-1.0.ebuild', 'sh.ebuild' },
    { '/p/foo.install', 'sh.install' },
    { '/p/query.promql', 'promql' },
    { '/p/ledger.bean', 'beancount' },
    { '/p/lua.snippets', 'snippets' },
    { '/p/schema.dbml', 'dbml' },
    { '/p/diagram.d2', 'd2' },
    { '/p/notebook.ipynb', 'ipynb' },
    { '/p/page.j2', 'jinja' },
    { '/p/page.jinja', 'jinja' },
    { '/p/page.jinja2', 'jinja' },
    { '/p/page.djhtml', 'htmldjango' },
    { '/p/post.mdx', 'markdown.mdx' },
    -- file name
    { '/p/terragrunt.hcl', 'terragrunt' },
    { '/p/azure-pipelines.yml', 'yaml.az-pl' },
    { '/p/docker-compose.yml', 'yaml.docker-compose' },
    { '/p/PKGBUILD', 'sh.PKGBUILD' },
    -- pattern
    { '/p/live/vpc.hcl', 'terragrunt' },
    { '/p/roles/web/defaults/main.yml', 'yaml.ansible' },
    { '/p/host_vars/web.yaml', 'yaml.ansible' },
    { '/p/group_vars/all.yml', 'yaml.ansible' },
    { '/p/group_vars/all/vars.yml', 'yaml.ansible' },
    { '/p/playbook-site.yml', 'yaml.ansible' },
    { '/p/playbooks/site.yml', 'yaml.ansible' },
    { '/p/roles/web/tasks/main.yml', 'yaml.ansible' },
    { '/p/roles/web/handlers/main.yml', 'yaml.ansible' },
    { '/p/molecule/default/converge.yml', 'yaml.ansible' },
    { '/p/openapi.yaml', 'yaml.openapi' },
    { '/p/openapi-v2.json', 'json.openapi' },
    { '/p/.gitlab-ci.yml', 'yaml.gitlab' },
    { '/p/.github/workflows/ci.yml', 'yaml.gh-action' },
    { '/p/src/app.component.html', 'htmlangular' },
    { '/p/src/app.container.html', 'htmlangular' },
    { '/p/dot_bashrc.tmpl', 'gotmpl' },
    { '/p/app/templates/index.html', 'htmldjango' },
    { '/p/chart/templates/_helpers.tpl', 'helm' },
    { '/p/chart/templates/deployment.yaml', 'helm' },
    { '/p/helmfile.yaml', 'helm' },
    { '/p/values-prod.yaml', 'yaml.helm-values' },
    { '/p/.config/hypr/hyprland.conf', 'hyprlang' },
    { '/p/Dockerfile-dev', 'dockerfile' },
  }

  for _, case in ipairs(cases) do
    it(
      case[1] .. ' is ' .. case[2],
      function() assert.are.equal(case[2], match(case[1])) end
    )
  end

  it(
    '/p/.git/ignore is gitignore',
    function() assert.are.equal('gitignore', match('/p/.git/ignore')) end
  )

  it(
    'leaves a file named ignore outside .git alone',
    function() assert.is_nil(match('/p/docs/ignore')) end
  )

  it(
    'leaves a plain HTML file outside templates alone',
    function() assert.are.equal('html', match('/p/static/index.html')) end
  )

  it(
    'gives every filetype it adds to a language of the configuration',
    function()
      local known = {}
      for _, spec in pairs(require('config.languages')) do
        for _, ft in ipairs(spec.filetypes) do
          known[ft] = true
        end
      end
      -- Filetypes only detected for plugins of their own, with no tooling
      local unclaimed =
        { rasi = true, snippets = true, dbml = true, ipynb = true }
      for _, case in ipairs(cases) do
        local ft = case[2]
        assert(known[ft] or unclaimed[ft], ft .. ' belongs to no language')
      end
    end
  )
end)

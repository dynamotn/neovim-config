local present, icon = pcall(require, 'nvim-web-devicons')

if not present then
  return
end

icon.setup({
  override = {
    ino = {
      icon = ' ',
      color = '#62aeb2',
      name = 'Arduino',
    },
    pde = {
      icon = ' ',
      color = '#62aeb2',
      name = 'Arduino',
    },
    tf = {
      icon = ' ',
      color = '#63388e',
      name = 'Terraform',
    },
    hcl = {
      icon = ' ',
      color = '#202324',
      name = 'HCL',
    },
    feature = {
      icon = ' ',
      color = '#3bdf7d',
      name = 'Cucumber',
    },
  },
})

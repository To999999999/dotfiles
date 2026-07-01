
vim.opt.number = true					    --Show the numbers
vim.opt.relativenumber=true				    --Show the relative number

vim.opt.mouse = "a"					    --Can use the mouse, as much as its possible to

vim.opt.ignorecase = true				    --Ignore the case in searches
vim.opt.smartcase = true				    --Do not ignore the case if we wrote it on purpose
vim.opt.hlsearch = true					    --Highlight result of previous search


vim.opt.wrap = true					    --So we can always see the long lines (it wraps it)
vim.opt.breakindent = true				    --Those wrapped lines (virtual lines basically) still preserves the indent

vim.opt.tabstop = 2					    --The space of a Tab (default is 8)
vim.opt.shiftwidth = 2					    --The amount of space to indent a line (influences >> and <<) Makes sense to have the same value as vim.opt.tabstop (default is 8)
vim.opt.expandtab = false				    --Transforms tab into spaces
vim.opt.shiftround = true				    --So doing >> or << (indent to the right/left) will indent by the closest shiftwidth multiple available

vim.opt.scrolloff = 999					    --Keep the cursor in the middle

vim.opt.virtualedit = "block"				    --Allows to select virtual lines as a block

vim.opt.splitbelow = true				    --Opens new split below
vim.opt.splitright = true				    --Opens new split right

vim.opt.inccommand = "split"				    --Shows what is being replaced live when do s/ceci/cela

vim.opt.termguicolors = true				    --enable 24-bit RGB colors

vim.opt.signcolumn = 'yes'				    --so we always see the sign column

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } --see the whitespace characters

-- Use the clipboard natively and in ssh
local function is_mac()
  return vim.fn.has("macunix") == 1
end
local function is_ssh()
  return vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
end
if is_mac() and not is_ssh() then
  -- Native macOS Neovim: use pbcopy/pbpaste
  vim.opt.clipboard = "unnamedplus"
else
  -- Remote SSH, e.g. Debian from macOS terminal: use OSC52
  vim.g.clipboard = "osc52"
  vim.opt.clipboard = "unnamedplus"
end

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

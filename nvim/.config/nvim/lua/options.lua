
vim.opt.number = true           --Show the numbers
vim.opt.relativenumber=true     --Show the relative number

vim.opt.mouse = "a"             --Can use the mouse, as much as its possible to

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { silent = true }) --Use Esc to exit terminal mode,tnoremap <Esc> <C-\><C-n>

vim.opt.ignorecase = true       --Ignore the case in searches
vim.opt.smartcase = true        --Do not ignore the case if we wrote it on purpose
vim.opt.hlsearch = true        --Highlight result of previous search
vim.keymap.set('n', '<esc>', '<cmd>nohlsearch<CR>')


vim.opt.wrap = true             --So we can always see the long lines (it wraps it)
vim.opt.breakindent = true      --Those wrapped lines (virtual lines basically) still preserves the indent

vim.opt.tabstop = 2             --The space of a Tab (default is 8)
vim.opt.shiftwidth = 2          --The amount of space to indent a line (influences >> and <<) Makes sense to have the same value as vim.opt.tabstop (default is 8)
vim.opt.expandtab = false       --Transforms tab into spaces
vim.opt.shiftround = true       --So doing >> or << (indent to the right/left) will indent by the closest shiftwidth multiple available

vim.opt.clipboard = "unnamedplus" --Allows to use the system clipboard

vim.opt.scrolloff = 999         --Keep the cursor in the middle

vim.opt.virtualedit = "block"   --Allows to select virtual lines as a block

vim.opt.splitbelow = true       --Opens new split below
vim.opt.splitright = true       --Opens new split right

vim.opt.inccommand = "split"    --Shows what is being replaced live when do s/ceci/cela

vim.opt.termguicolors = true 	--enable 24-bit RGB colors

vim.opt.signcolumn = 'yes'	--so we always see the sign column

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } --see the whitespace characters

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
--vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
--vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
--vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
--vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})


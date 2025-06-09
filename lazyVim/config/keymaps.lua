-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
if vim.g.vscode then
       -- code formatting
       vim.keymap.set("n", "<leader>cf", "<Cmd>call VSCodeNotify('editor.action.formatDocument')<CR>")

       --tabs keymaps
       vim.keymap.set("n", "<leader>bd", "<Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>")
       vim.keymap.set("n", "<leader>ba", "<Cmd>call VSCodeNotify('workbench.action.closeAllEditors')<CR>")
       vim.keymap.set("n", "<leader>bo", "<Cmd>call VSCodeNotify('workbench.action.closeOtherEditors')<CR>")
       vim.keymap.set("n", "<leader>br", "<Cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>")
       vim.keymap.set("n", "<leader>bl", "<Cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>")
       vim.keymap.set("n", "<leader>bu", "<Cmd>call VSCodeNotify('workbench.action.closeUnmodifiedEditors')<CR>")

       --Debugging
       vim.keymap.set("n", "<leader>dd", "<Cmd>call VSCodeNotify('workbench.action.debug.start')<CR>")
       vim.keymap.set("n", "<leader>dS", "<Cmd>call VSCodeNotify('workbench.action.debug.stop')<CR>")

       --Explorer
       vim.keymap.set("n", "<leader>,", "<cmd>call vscodenotify('workbench.action.quickopen')<cr>")
       vim.keymap.set("n", "<leader>e", "<cmd>call vscodenotify('workbench.view.explorer')<cr>")
       vim.keymap.set("n", "<leader>E", "<Cmd>call VSCodeNotify('workbench.files.action.showActiveFileInExplorer')<CR>")

       --Code Actions
       vim.keymap.set("n", "gD", "<Cmd>call VSCodeNotify('editor.action.revealDefinition')<CR>")
       vim.keymap.set("n", "gI", "<Cmd>call VSCodeNotify('editor.action.goToImplementation')<CR>")
       vim.keymap.set("n", "gU", "<Cmd>call VSCodeNotify('editor.action.referenceSearch.trigger')<CR>")
       vim.keymap.set("n", "gf", "<Cmd>call VSCodeNotify('gitlens.views.fileHistory.focus')<CR>")

       --Multi Cursor
       vim.keymap.set("n", "<leader>n", "<Cmd>call VSCodeNotify('editor.action.addSelectionToNextFindMatch')<CR>")
       vim.keymap.set("x", "<leader>n", "<Cmd>call VSCodeNotify('editor.action.addSelectionToNextFindMatch')<CR>")
       vim.keymap.set("n", "<leader>N", "<Cmd>call VSCodeNotify('editor.action.selectHighlights')<CR>")
       vim.keymap.set("x", "<leader>N", "<Cmd>call VSCodeNotify('editor.action.selectHighlights')<CR>")
end
vim.keymap.set("v", "J", ":move '>+1<CR>gv-gv", { silent = true })
vim.keymap.set("v", "K", ":move '<-2<CR>gv-gv", { silent = true })

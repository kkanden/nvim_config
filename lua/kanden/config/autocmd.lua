local augroup = require("kanden.lib.nvim_api").augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight when yanking (copying) text -- from kickstart
autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    desc = "Highlight when yanking (copying) text",
    callback = function() vim.highlight.on_yank() end,
})

-- easier quit in filetypes
autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = { "help", "fugitive", "git", "gitcommit", "checkhealth" },
    callback = function() vim.keymap.set("n", "q", "<Cmd>q<CR>", { buffer = true }) end,
})

-- Set local settings for terminal buffers
autocmd("TermOpen", {
    group = augroup("custom_term_open"),
    callback = function()
        local set = vim.opt_local
        set.number = false
        set.relativenumber = false
        set.scrolloff = 0

        vim.bo.filetype = "terminal"
    end,
})

-- Show only WARN and ERROR diagnostics in R and Rmd
autocmd("FileType", {
    group = augroup("r_diagnostics"),
    pattern = { "r", "rmd" },
    callback = function()
        vim.diagnostic.config({
            virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
            signs = { severity = { min = vim.diagnostic.severity.WARN } },
            underline = { severity = { min = vim.diagnostic.severity.ERROR } },
        })
    end,
})

-- formatting options
autocmd("BufEnter", {
    group = augroup("no_comment_continue"),
    callback = function()
        vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o" } -- disable comment continuation on new line
    end,
})

-- resize splits if window got resized
autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- Show diagnostic popup on cursor hover
autocmd("CursorHold", {
    group = augroup("diagnostic_float"),
    callback = function()
        vim.defer_fn(
            function() vim.diagnostic.open_float(nil, { focusable = false }) end,
            3000
        )
    end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

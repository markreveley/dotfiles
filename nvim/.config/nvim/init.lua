-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader must be set before lazy.nvim loads plugins
vim.g.mapleader = " "

-- Plugins
require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({ "markdown", "markdown_inline", "lua", "elixir", "heex" })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "lua", "elixir", "heex" },
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-nvim")
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("render-markdown").setup({})
    end,
  },
  {
    "jghauser/follow-md-links.nvim",
    ft = "markdown",
    config = function()
      -- The plugin maps <CR> to follow the link under the cursor, but ships no
      -- "back". Its README suggests `:edit #`, which is the alternate-file
      -- toggle: it only ping-pongs between the last two files. Keep a real
      -- stack instead. Local links open in a new tab; <BS> closes that tab and
      -- returns to the exact source tab and cursor position.
      local stack = {}
      local md = require("follow-md-links")
      local follow_link = md.follow_link

      -- Upstream gates on finding an `inline` node in the markdown *block*
      -- tree. A link in a table cell sits under `pipe_table_cell`, which has no
      -- `inline` child, so the gate bails and <CR> silently does nothing. The
      -- markdown_inline tree resolves those positions fine, so read it directly
      -- as a fallback. Returns true if we actually moved.
      local function link_destination_at_cursor()
        local ok, parser = pcall(vim.treesitter.get_parser, 0, "markdown_inline")
        if not ok or not parser then
          return nil
        end
        local pos = vim.api.nvim_win_get_cursor(0)
        local row, col = pos[1] - 1, pos[2]
        local node = parser:parse()[1]:root():named_descendant_for_range(row, col, row, col)
        while node do
          local t = node:type()
          if t == "uri_autolink" then
            return (vim.treesitter.get_node_text(node, 0):gsub("^<(.*)>$", "%1"))
          elseif t == "inline_link" or t == "image" then
            for i = 0, node:named_child_count() - 1 do
              local child = node:named_child(i)
              if child:type() == "link_destination" then
                return vim.treesitter.get_node_text(child, 0)
              end
            end
          end
          node = node:parent()
        end
      end

      local function follow_from_inline_tree()
        local dest = link_destination_at_cursor()
        if not dest or dest:sub(1, 1) == "#" then
          return false
        end
        if dest:match("^https?://") then
          vim.ui.open(dest)
          return false -- browser opened; we did not move, so bank nothing
        end
        local path, line = dest, dest:match(":(%d+)$")
        if line then
          path = path:gsub(":%d+$", "")
        end
        if path:sub(1, 1) == "~" then
          path = vim.fs.normalize(path)
        elseif path:sub(1, 1) ~= "/" then
          path = vim.fn.expand("%:p:h") .. "/" .. path
        end
        if vim.fn.filereadable(path) == 0 and vim.fn.isdirectory(path) == 0 then
          if vim.fn.filereadable(path .. ".md") == 0 then
            return false
          end
          path = path .. ".md"
        end
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        if line then
          pcall(vim.api.nvim_win_set_cursor, 0, { tonumber(line), 0 })
        end
        return true
      end

      -- Wrapping the plugin's own entry point beats re-mapping <CR>: its
      -- ftplugin map resolves this field at keypress time, so the wrapper
      -- applies however and whenever that map gets set.
      md.follow_link = function(...)
        -- Opening a web URL does not change Neovim's buffer or cursor, so the
        -- movement check below cannot tell it apart from an upstream miss. If
        -- both handlers run, the browser opens the same URL twice. Handle
        -- direct web links once here; reference links still fall through to
        -- upstream, while the inline-tree fallback ignores them.
        local dest = link_destination_at_cursor()
        if dest and dest:match("^https?://") then
          vim.ui.open(dest)
          return
        end

        local file = vim.api.nvim_buf_get_name(0)
        local source_buf = vim.api.nvim_get_current_buf()
        local source_win = vim.api.nvim_get_current_win()
        local source_tab = vim.api.nvim_get_current_tabpage()
        local cursor = vim.api.nvim_win_get_cursor(0)
        follow_link(...)

        local function moved()
          return vim.api.nvim_buf_get_name(0) ~= file
            or not vim.deep_equal(vim.api.nvim_win_get_cursor(0), cursor)
        end

        -- The fallback covers links in table cells. Web links open in the
        -- browser and misses do nothing; neither creates a Neovim tab.
        if not moved() then
          follow_from_inline_tree()
        end
        if file == "" or not moved() then
          return
        end

        -- Upstream hardcodes :edit. Capture the destination it opened, put the
        -- source window back, then display that destination buffer in a new
        -- tab. This also gives same-document heading links tab semantics.
        local destination_buf = vim.api.nvim_get_current_buf()
        local destination_cursor = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_win_set_buf(source_win, source_buf)
        pcall(vim.api.nvim_win_set_cursor, source_win, cursor)
        vim.cmd("tab sbuffer " .. destination_buf)
        pcall(vim.api.nvim_win_set_cursor, 0, destination_cursor)

        table.insert(stack, {
          file = file,
          buffer = source_buf,
          window = source_win,
          tab = source_tab,
          cursor = cursor,
          opened_tab = vim.api.nvim_get_current_tabpage(),
        })
      end

      -- Global, so it still works after a link lands us in a non-markdown
      -- file. Buffer-local maps (nvim-tree's) still win over this.
      vim.keymap.set("n", "<BS>", function()
        local prev = table.remove(stack)
        if not prev then
          -- Nothing to pop: fall through to the builtin <BS> (cursor left).
          vim.api.nvim_feedkeys(vim.keycode("<BS>"), "n", false)
          return
        end
        local current_tab = vim.api.nvim_get_current_tabpage()
        local current_tab_number = vim.api.nvim_tabpage_get_number(current_tab)
        if vim.api.nvim_tabpage_is_valid(prev.tab) then
          vim.api.nvim_set_current_tabpage(prev.tab)
          if vim.api.nvim_win_is_valid(prev.window) then
            vim.api.nvim_set_current_win(prev.window)
          end
          if vim.api.nvim_buf_is_valid(prev.buffer) then
            vim.api.nvim_win_set_buf(0, prev.buffer)
          else
            vim.cmd("edit " .. vim.fn.fnameescape(prev.file))
          end
          pcall(vim.api.nvim_win_set_cursor, 0, prev.cursor)
          if current_tab == prev.opened_tab and vim.api.nvim_tabpage_is_valid(current_tab) then
            vim.cmd("tabclose " .. current_tab_number)
          end
        else
          vim.cmd("tabedit " .. vim.fn.fnameescape(prev.file))
          pcall(vim.api.nvim_win_set_cursor, 0, prev.cursor)
        end
      end, { silent = true, desc = "md-links: back" })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- telescope 0.1.x calls nvim-treesitter's removed master-branch API
      -- (parsers.ft_to_lang) to highlight preview buffers; we track the main
      -- branch rewrite, so that path errors. Fall back to regex highlighting.
      require("telescope").setup({
        defaults = {
          preview = { treesitter = false },
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- nvim 0.11 API: nvim-lspconfig ships defaults in its lsp/ dir,
      -- vim.lsp.config() merges overrides on top of them.
      vim.lsp.config("elixirls", {
        cmd = { "/opt/homebrew/bin/elixir-ls" },
      })
      vim.lsp.enable("elixirls")

      -- LSP keymaps (activate when LSP attaches to a buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      -- Treesitter textobject keymaps
      vim.keymap.set("n", "]f", function()
        require("nvim-treesitter.textobjects.move").goto_next_start("@function.outer")
      end, { silent = true })
      vim.keymap.set("n", "[f", function()
        require("nvim-treesitter.textobjects.move").goto_previous_start("@function.outer")
      end, { silent = true })
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Disable netrw (nvim-tree replaces it)
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        view = { width = 30 },
        filters = { dotfiles = false },
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")

          -- Keep nvim-tree's default mappings, including <Tab> preview.
          api.config.mappings.default_on_attach(bufnr)
          vim.keymap.set("n", "<Space>", api.node.open.preview, {
            buffer = bufnr,
            silent = true,
            desc = "nvim-tree: Open Preview",
          })
        end,
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({})
    end,
  },
})

-- Settings
vim.opt.autoread = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.mousescroll = "ver:1"

-- Word wrap for prose filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "json" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- Keymaps
-- Terminal mode: double-Esc leaves insert mode (same as <C-\><C-n>).
-- Single Esc still passes through to the program running in the terminal.
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { silent = true })

vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<leader>f", ":NvimTreeFindFile<CR>", { silent = true })

-- Telescope
vim.keymap.set("n", "<leader>p", ":Telescope find_files<CR>", { silent = true })
vim.keymap.set("n", "<leader>g", ":Telescope live_grep<CR>", { silent = true })
vim.keymap.set("n", "<leader>b", ":Telescope buffers<CR>", { silent = true })

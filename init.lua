-- 自动安装 lazy.nvim（如果还没有安装）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable", -- 最新稳定版
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 配置 lazy.nvim 来安装和管理插件
require("lazy").setup({
  -- 安装 vimtex 插件
  {
    "lervag/vimtex",
    config = function()
      -- 配置 vimtex
      vim.g.vimtex_view_method = "skim"  -- 设置 Skim 作为 PDF 查看器
      vim.g.vimtex_view_general_options = "--reuse-instance"  -- 使用现有的 Skim 窗口
      vim.g.vimtex_view_forward_search_on_start = 1  -- 启动时启用正向搜索

      -- 使用 latexmk 进行自动化编译
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "",  -- 使用当前目录
        options = {
          "-pdf", -- 生成 PDF
	  "-xelatex",
          "-interaction=nonstopmode",  -- 不停止编译
          "-synctex=1",  -- 启用同步支持
        },
      }

      -- 其他 Vimtex 配置选项
      vim.g.vimtex_quickfix_mode = 0  -- 禁用 quickfix 窗口
      vim.g.vimtex_log_debug = 1
      vim.g.vimtex_log_verbose = 1

    end
  },
  -- 安装 Treesitter 用于 LaTeX 语法高亮
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = { "latex", "c", "cpp" },  -- 安装 LaTeX 的 Treesitter 解析器
        highlight = {
          enable = true,  -- 启用 Treesitter 语法高亮
          additional_vim_regex_highlighting = false,
        },
        playground = {
          enable = true, -- 启用 playground 调试工具
          disable = {},
          updatetime = 25, -- 定时刷新时间
          persist_queries = false, -- 启动时保留查询
        },
      }
    end
  },
      {
    "hiphish/rainbow-delimiters.nvim",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          commonlisp = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },

    {
    "nvim-treesitter/playground",
    config = function()
      require "nvim-treesitter.configs".setup {
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- 刷新间隔
          persist_queries = false,
        },
      }
    end,
  },
    {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "L3MON4D3/LuaSnip" },
    },
    config = function()
      local cmp = require 'cmp'
      cmp.setup({
        completion = {
             autocomplete = false,  -- 禁用自动弹出补全框
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          ['<A-m>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),  -- 手动触发补全          
          ['<Down>'] = cmp.mapping.select_next_item(),
           ['<Up>'] = cmp.mapping.select_prev_item(),
          ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),  -- 仅限插入模式
            c = cmp.mapping.close(),  -- 仅限命令模式
          }),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),  -- 确认补全项
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
        })
      })
    cmp.setup.filetype('tex', {
        completion = {
          autocomplete = { require'cmp.types'.cmp.TriggerEvent.TextChanged },  -- 自动补全启用
        },
      })

      
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.texlab.setup({
        settings = {
          texlab = {
            build = {
              executable = "latexmk",
              args = { "-pdf", "-xelatex", "-interaction=nonstopmode", "-synctex=1", "%f" },
              onSave = true,
            },
          },
        }
      })
    end
  },
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
    {
    "cpea2506/one_monokai.nvim",
    url = "git@github.com:cpea2506/one_monokai.nvim.git",  -- 使用 SSH URL
    config = function()
        require("one_monokai").setup({
            transparent = true,  -- 启用透明背景
            colors = {
                bg = "#1e1e1e",  -- 自定义背景颜色
                fg = "#abb2bf",  -- 前景色
                red = "#e06c75",  -- 错误/操作符
                orange = "#d19a66",  -- 常量/数字
                yellow = "#e5c07b",  -- 类型
                green = "#98c379",  -- 字符串
                cyan = "#56b6c2",  -- 注释
                blue = "#61afef",  -- 函数
                purple = "#c678dd",  -- 关键字
            },
            themes = function(colors)
                return {
                    -- 常见的 C++ 语法元素高亮配置
                    comment = { fg = colors.green, italic = true },  -- 注释
                    string = { fg = colors.green },  -- 字符串
                    Function = { fg = colors.green },  -- 函数名
                    keyword = { fg = colors.purple, bold = true },  -- 关键字 (if, for, etc.)
                    Type = { fg = colors.cyan },  -- 数据类型 (int, float, etc.)
                    constant = { fg = colors.orange },  -- 常量和数字
                    identifier = { fg = colors.fg },  -- 标识符 (变量名)
                    Operator = { fg = colors.cyan },  -- 操作符 (+, -, etc.)
                    ["@type.qualifier"] = { fg = colors.purple },  -- C++ 类型限定符 (const, etc.)
                    ["@variable.builtin"] = { fg = colors.red, italic = true },  -- 内置变量
                    ["@namespace"] = { fg = colors.yellow },  -- 命名空间
                    ["@parameter"] = { fg = colors.orange },  -- 函数参数
                    ["@field"] = { fg = colors.blue },  -- 类成员变量
                    ["@type.builtin"] = { fg = colors.cyan},
                    ["@keyword.function"] = { fg = colors.purple, bold = true },  -- 函数关键字 (e.g., static, inline)
                    ["@punctuation.bracket"] = {fg = colors.yellow},
                }
            end,
            italics = false,  -- 禁用全局斜体，保留特定设置
        })

        -- require("one_monokai").setup({
        --     transparent = true,  -- enable transparent window
        --     colors = {
        --         fg = "#abb2bf",                -- 前景色
        --         red = "#e06c75",
        --         orange = "#d19a66",
        --         yellow = "#e5c07b",
        --         green = "#98c379",
        --         cyan = "#56b6c2",
        --         blue = "#61afef",
        --         purple = "#c678dd",
        --         gray = "#5c6370",
        --     },
        --     themes = function(colors)
        --         -- change highlight of some groups,
        --         -- the key and value will be passed respectively to "nvim_set_hl"
        --         return {
        --            -- Normal = { bg = colors.lmao },
        --             DiffChange = { fg = colors.white:darken(0.3) },
        --             ErrorMsg = { fg = colors.pink, standout = true },
        --             ["@lsp.type.keyword"] = { link = "@keyword" }
        --         }
        --     end,
        --     italics = true, -- disable italics
        -- })
    -- 设置主题为 One Monokai
	    vim.cmd("colorscheme one_monokai")
	    -- 使用 nvim_set_hl 来为特定语法元素定义颜色

	    -- 设置具体语法类型的颜色
	    -- vim.api.nvim_set_hl(0, "Comment", { fg = colors.gray, italic = true })    -- 注释
	    -- vim.api.nvim_set_hl(0, "String", { fg = colors.green })                   -- 字符串
	    -- vim.api.nvim_set_hl(0, "Function", { fg = colors.blue })                  -- 函数
	    -- vim.api.nvim_set_hl(0, "Keyword", { fg = colors.purple, bold = true })    -- 关键字
	    -- vim.api.nvim_set_hl(0, "Type", { fg = colors.yellow })                    -- 类型
	    -- vim.api.nvim_set_hl(0, "Constant", { fg = colors.orange })                -- 常量
	    -- vim.api.nvim_set_hl(0, "Variable", { fg = colors.fg })                    -- 变量
	    -- vim.api.nvim_set_hl(0, "Identifier", { fg = colors.cyan })                -- 标识符
	    -- vim.api.nvim_set_hl(0, "Number", { fg = colors.orange })                  -- 数字
	    -- vim.api.nvim_set_hl(0, "Boolean", { fg = colors.orange })                 -- 布尔值
	    -- vim.api.nvim_set_hl(0, "Operator", { fg = colors.red })
	    end,
  },
  -- {
  --     "Mofiqul/vscode.nvim",
  --     config = function()
  --         vim.o.background = "dark"  -- 设置主题为深色
  --         require('vscode').setup({
  --             -- 启用透明背景（可选）
  --             transparent = false,
  --
  --             -- 启用 VSCode 风格的缩进线（可选）
  --             indent_blankline = {
  --                 enabled = true,
  --             },
  --
  --             -- 配置更鲜艳的色彩
  --             color_overrides = {
  --                 vscLineNumber = "#FFFFFF",  -- 自定义行号颜色
  --             },
  --         })
  --         require('vscode').load()
  --     end
  -- },
  {
      "numToStr/Comment.nvim",
      config = function()
          require("Comment").setup()
      end
  },
 
  -- {
  --   "windwp/nvim-autopairs",
  --   config = function()
  --     require("nvim-autopairs").setup({
  --       enable_check_bracket_line = false, -- 允许在大括号中按回车自动缩进
  --     })
  --   end,
  -- },
   {
    "windwp/nvim-autopairs",
    config = function()
      local npairs = require("nvim-autopairs")

      -- 初始化 nvim-autopairs
      npairs.setup({
        check_ts = true,                    -- 启用 Treesitter 支持（可选）
        enable_check_bracket_line = false,   -- 不在同一行检查括号匹配
      })

      -- 自定义 Enter 键行为，包括 Shift+Enter
      npairs.get_rule('{')
        :with_pair(function() return true end)
        :with_move(function() return true end)
        :with_del(function() return true end)
        :with_cr(function()
          -- 仅在光标在 `{}` 中间时才触发自动换行和缩进
          local line = vim.api.nvim_get_current_line()
          local col = vim.fn.col(".")
          return col > 1 and line:sub(col - 1, col - 1) == '{' and line:sub(col, col) == '}'
        end)
        -- vim.api.nvim_set_keymap(
        -- "i",                                 -- 插入模式
        -- "<S-CR>",                            -- Shift+Enter 键
        -- "v:lua.require'nvim-autopairs'.map_cr()",
        -- { expr = true, noremap = true, silent = true }
  end,
  },
  {
      "nvim-tree/nvim-web-devicons",
      lazy = true,
  },
  {
    "nvim-tree/nvim-tree.lua",
    requires = {
      "nvim-tree/nvim-web-devicons", -- 文件图标插件（可选）
    },
    config = function()
      -- 插件配置放在这里
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          add_trailing = true,
          highlight_git = true,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        hijack_directories = {
            enable = false,             -- 禁用目录劫持，确保只打开指定目录
            auto_open = false,
        },
        filters = {
          dotfiles = true,
        },
      })
      --[[ alt-q ]]
      vim.keymap.set("n", "œ", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    end,
  },
  {
      "akinsho/bufferline.nvim",
      requires = "nvim-tree/nvim-web-devicons",
      config = function()
          require("bufferline").setup({
              options = {
                  show_buffer_close_icons = true,
                  show_close_icon = true,
              },
          })
          vim.api.nvim_set_keymap("n", "<Tab>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
          vim.api.nvim_set_keymap("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })
          vim.api.nvim_set_keymap("n", "∑", ":bp<bar>sp<bar>bn<bar>bd<CR>", { noremap = true, silent = true })
          vim.api.nvim_set_keymap("n", "˙", "<C-w>p", { noremap = true, silent = true })
      end,
  },

})

-- 4. 其他通用配置
function _G.shift_enter_with_correct_indent()
    -- 获取当前行的缩进级别
    local indent = vim.fn.indent(vim.fn.line('.'))
    local indent_str = string.rep(" ", indent)

    -- 插入换行，添加缩进，并移动光标到中间行
    local insert_text =  indent_str .. "<CR>"  .. "<Esc>O"
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(insert_text, true, false, true), "n", true)

    -- 返回空字符串，避免插入 `v:null`
    return ""
end

-- 将 Shift+Enter 映射为调用 shift_enter_with_correct_indent 函数
vim.api.nvim_set_keymap("i", "<S-CR>", "v:lua.shift_enter_with_correct_indent()",{ expr = true, noremap = true, silent = true })


-- 将 .cu 文件识别为 cpp 类型
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.cu",
  callback = function()
    vim.bo.filetype = "cpp"
  end,
})


vim.opt.tabstop = 4 -- Tab 长度为4个空格
vim.opt.tabstop = 4 -- Tab 长度为4个空格
vim.opt.shiftwidth = 4 -- 缩进长度为4
vim.opt.expandtab = true -- 将 Tab 转换为空格
vim.cmd [[filetype plugin indent on]]
vim.cmd [[syntax off]]



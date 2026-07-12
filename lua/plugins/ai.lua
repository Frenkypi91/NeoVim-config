-- =============================================================================
-- AI Chat
-- =============================================================================
return {
  {
    "olimorris/codecompanion.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        "nvim-mini/mini.nvim",
        version = false,
        config = function()
        require("mini.pick").setup()
        require("mini.diff").setup()
        end,
      },
      {
        "j-hui/fidget.nvim",
        opts = {},
      },
    },

    opts = {
      adapters = {
        anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          env = {
            api_key = vim.env.CLAUDE_API_KEY,
          },
          schema = {
            model = {
              default = "claude-sonnet-4-5",
            },
            temperature = {
              default = 0.2,
            },
            max_tokens = {
              default = 8192,
            },
          },
        })
        end,

        openai = function()
        return require("codecompanion.adapters").extend("openai", {
          env = {
            api_key = vim.env.OPENAI_API_KEY,
          },
          schema = {
            model = {
              default = "gpt-4.1",
            },
            temperature = {
              default = 0.2,
            },
            max_tokens = {
              default = 8192,
            },
          },
        })
        end,
      },

      strategies = {
        chat = {
          adapter = "anthropic",
          slash_commands = {
            ["buffer"] = {
              opts = {
                provider = "mini_pick",
              },
            },
            ["file"] = {
              opts = {
                provider = "mini_pick",
              },
            },
            ["help"] = {
              opts = {
                provider = "mini_pick",
              },
            },
            ["symbols"] = {
              opts = {
                provider = "mini_pick",
              },
            },
          },
        },

        inline = {
          adapter = "openai",
        },

        cmd = {
          adapter = "openai",
        },
      },

      display = {
        action_palette = {
          provider = "mini_pick",
        },
        chat = {
          intro_message = "CodeCompanion is ready. Claude for chat, OpenAI for inline editing.",
          show_header_separator = true,
          separator = "─",
          show_settings = true,
          show_token_count = true,
          start_in_insert_mode = false,
        },
        diff = {
          enabled = true,
          close_chat_at = 240,
          layout = "vertical",
          opts = {
            "internal",
            "filler",
            "closeoff",
            "algorithm:patience",
          },
          provider = "mini_diff",
        },
      },

      prompt_library = {
        ["Explain Code"] = {
          strategy = "chat",
          description = "Explain the selected code",
          opts = {
            index = 1,
            is_default = true,
            short_name = "explain",
            auto_submit = false,
          },
          prompts = {
            {
              role = "system",
              content = "You are a precise senior developer. Explain the code clearly and identify bugs, edge cases, limitations, and possible improvements.",
            },
            {
              role = "user",
              content = "Explain this code:\n\n```{{filetype}}\n{{selection}}\n```",
            },
          },
        },

        ["Refactor"] = {
          strategy = "inline",
          description = "Refactor the selected code",
          opts = {
            index = 2,
            short_name = "refactor",
            auto_submit = true,
          },
          prompts = {
            {
              role = "user",
              content = "Refactor this code to improve readability and maintainability. Preserve behavior exactly.\n\n```{{filetype}}\n{{selection}}\n```",
            },
          },
        },

        ["Fix Bugs"] = {
          strategy = "inline",
          description = "Fix bugs in the selected code",
          opts = {
            index = 3,
            short_name = "fix",
            auto_submit = true,
          },
          prompts = {
            {
              role = "user",
              content = "Fix bugs and correctness issues in this code. Keep the solution clean and preserve the intended behavior.\n\n```{{filetype}}\n{{selection}}\n```",
            },
          },
        },

        ["Add Tests"] = {
          strategy = "chat",
          description = "Generate tests for the selected code",
          opts = {
            index = 4,
            short_name = "tests",
            auto_submit = false,
          },
          prompts = {
            {
              role = "user",
              content = "Write a solid test suite for this code. Include edge cases and briefly explain the strategy.\n\n```{{filetype}}\n{{selection}}\n```",
            },
          },
        },

        ["Optimize"] = {
          strategy = "inline",
          description = "Optimize the selected code",
          opts = {
            index = 5,
            short_name = "optimize",
            auto_submit = true,
          },
          prompts = {
            {
              role = "user",
              content = "Optimize this code where useful. Do not make it obscure. Preserve behavior.\n\n```{{filetype}}\n{{selection}}\n```",
            },
          },
        },

        ["Julia Review"] = {
          strategy = "chat",
          description = "Review Julia code",
          opts = {
            index = 6,
            short_name = "julia",
            auto_submit = false,
          },
          prompts = {
            {
              role = "system",
              content = "You are a Julia expert. Evaluate type stability, performance, allocations, dispatch, and idiomatic style.",
            },
            {
              role = "user",
              content = "Analyze this Julia code:\n\n```julia\n{{selection}}\n```",
            },
          },
        },

        ["Python Review"] = {
          strategy = "chat",
          description = "Review Python code",
          opts = {
            index = 7,
            short_name = "python",
            auto_submit = false,
          },
          prompts = {
            {
              role = "system",
              content = "You are a Python expert. Evaluate correctness, readability, edge cases, design, and overall quality.",
            },
            {
              role = "user",
              content = "Analyze this Python code:\n\n```python\n{{selection}}\n```",
            },
          },
        },

        ["R Review"] = {
          strategy = "chat",
          description = "Review R code",
          opts = {
            index = 8,
            short_name = "r",
            auto_submit = false,
          },
          prompts = {
            {
              role = "system",
              content = "You are an R expert. Evaluate correctness, readability, performance, vectorization, and statistical quality.",
            },
            {
              role = "user",
              content = "Analyze this R code:\n\n```r\n{{selection}}\n```",
            },
          },
        },
      },
    },

    keys = {
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "AI Actions" },
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle AI Chat" },
      { "<leader>aC", "<cmd>CodeCompanionChat<cr>", desc = "New AI Chat" },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "AI Inline Prompt" },
      { "<leader>ap", "<cmd>CodeCompanionCmd<cr>", desc = "AI Prompt Library" },

      { "<leader>at", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Send Selection to Chat" },
      { "<leader>ar", "<cmd>CodeCompanion /Refactor<cr>", mode = "v", desc = "AI Refactor" },
      { "<leader>af", "<cmd>CodeCompanion /Fix Bugs<cr>", mode = "v", desc = "AI Fix Bugs" },
      { "<leader>ae", "<cmd>CodeCompanion /Explain Code<cr>", mode = "v", desc = "AI Explain Code" },
      { "<leader>aT", "<cmd>CodeCompanion /Add Tests<cr>", mode = "v", desc = "AI Add Tests" },
      { "<leader>ao", "<cmd>CodeCompanion /Optimize<cr>", mode = "v", desc = "AI Optimize" },
      { "<leader>aj", "<cmd>CodeCompanion /Julia Review<cr>", mode = "v", desc = "AI Julia Review" },
      { "<leader>ay", "<cmd>CodeCompanion /Python Review<cr>", mode = "v", desc = "AI Python Review" },
      { "<leader>aR", "<cmd>CodeCompanion /R Review<cr>", mode = "v", desc = "AI R Review" },
    },

    init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "codecompanion",
      callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.conceallevel = 0
      end,
    })
    end,
  },
}

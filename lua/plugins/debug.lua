-- =============================================================================
-- Debug
-- =============================================================================
return {
  {
    "mfussenegger/nvim-dap",
    cmd = {
      "DapContinue",
      "DapToggleBreakpoint",
      "DapStepOver",
      "DapStepInto",
      "DapStepOut",
      "DapTerminate",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Start/continue debug session" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate debug session" },
    },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(mason_path)
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
          args = { "--port", "${port}" },
        },
      }
      dap.configurations.cpp = {
        {
          name = "Launch executable",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      direction = "horizontal",
      size = 12,
      close_on_exit = false,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      local Terminal = require("toggleterm.terminal").Terminal

      local function shellescape(path) return vim.fn.shellescape(path) end
      local function ensure_written() if vim.bo.modified then vim.cmd("write") end end
      local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO) end
      local function has(bin) return vim.fn.executable(bin) == 1 end
      local function find_up(name) return vim.fn.findfile(name, ".;") end
      local function dirname(p) return vim.fn.fnamemodify(p, ":h") end

      local runner = Terminal:new({ cmd = "bash", hidden = true, direction = "horizontal", close_on_exit = false })
      local julia = Terminal:new({ cmd = "julia --project=@. --color=yes", hidden = true, direction = "horizontal", close_on_exit = false })
      local function runner_toggle() runner:toggle(12) end
      local function runner_exec(cmd) runner_toggle(); runner:send(cmd, true) end
      local function julia_toggle() julia:toggle(12) end
      local function julia_send(text) julia_toggle(); julia:send(text, true) end

      local function run_current_file(mode)
        mode = mode or "run"
        local ft = vim.bo.filetype
        local file = vim.fn.expand("%:p")
        if file == "" then
          notify("No file path for current buffer.", vim.log.levels.WARN)
          return
        end
        ensure_written()
        local f = shellescape(file)
        local is_debug = mode == "debug"
        local cmd = nil
        local function mk_out(name) return shellescape("/tmp/" .. name) end
        local function in_file_dir(prefix) return "cd " .. shellescape(dirname(file)) .. " && " .. prefix end

        if ft == "tex" then
          if has("latexmk") then
            local flags = "-pdf -synctex=1"
            flags = is_debug and (flags .. " -interaction=errorstopmode") or (flags .. " -interaction=nonstopmode")
            cmd = in_file_dir("latexmk " .. flags .. " " .. f)
          else
            notify("latexmk not found. Install it or use VimTeX.", vim.log.levels.WARN)
            return
          end
        elseif ft == "python" then
          cmd = is_debug and ("python3 -u -m pdb " .. f) or ("python3 -u " .. f)
        elseif ft == "julia" then
          cmd = is_debug and ("julia --project=@. --check-bounds=yes -g2 " .. f) or ("julia --project=@. " .. f)
        elseif ft == "r" then
          cmd = is_debug and ("R --vanilla -q -f " .. f) or ("Rscript --vanilla " .. f)
        elseif ft == "rmd" then
          if has("Rscript") then
            cmd = "Rscript --vanilla -e " .. shellescape("rmarkdown::render('" .. file .. "')")
          end
        elseif ft == "quarto" then
          if has("quarto") then cmd = in_file_dir("quarto render " .. f) end
        elseif ft == "lua" then
          cmd = "lua " .. f
        elseif ft == "sh" then
          cmd = "bash " .. f
        elseif ft == "zsh" then
          cmd = "zsh " .. f
        elseif ft == "c" then
          local out = mk_out("nvim_run_c.out")
          cmd = is_debug and ("cc " .. f .. " -O0 -g -Wall -Wextra -fsanitize=address,undefined -fno-omit-frame-pointer -o " .. out .. " && " .. out)
            or ("cc " .. f .. " -O2 -Wall -Wextra -o " .. out .. " && " .. out)
        elseif ft == "cpp" then
          local out = mk_out("nvim_run_cpp.out")
          cmd = is_debug and ("c++ " .. f .. " -O0 -g -Wall -Wextra -std=c++20 -fsanitize=address,undefined -fno-omit-frame-pointer -o " .. out .. " && " .. out)
            or ("c++ " .. f .. " -O2 -Wall -Wextra -std=c++20 -o " .. out .. " && " .. out)
        elseif ft == "fortran" then
          local fpm = find_up("fpm.toml")
          if fpm ~= "" and has("fpm") then
            cmd = is_debug and "fpm run --profile debug" or "fpm run"
          else
            local out = mk_out("nvim_run_fortran.out")
            cmd = is_debug and ("gfortran " .. f .. " -O0 -g -Wall -Wextra -std=f2008 -fcheck=all -fbacktrace -o " .. out .. " && " .. out)
              or ("gfortran " .. f .. " -O2 -Wall -Wextra -std=f2008 -o " .. out .. " && " .. out)
          end
        elseif ft == "rust" then
          local cargo = find_up("Cargo.toml")
          if cargo ~= "" and has("cargo") then
            cmd = is_debug and "cargo run" or "cargo run --release"
          else
            local out = mk_out("nvim_run_rust.out")
            cmd = is_debug and ("rustc " .. f .. " -g -C debuginfo=2 -o " .. out .. " && " .. out)
              or ("rustc " .. f .. " -O -o " .. out .. " && " .. out)
          end
        elseif ft == "html" or ft == "css" then
          if has("python3") then
            cmd = in_file_dir("python3 -m http.server 8000")
            notify("HTTP server running on http://127.0.0.1:8000 (Ctrl-C to stop)")
          else
            notify("python3 not found: cannot start http.server.", vim.log.levels.WARN)
            return
          end
        elseif ft == "markdown" then
          if has("glow") then
            cmd = "glow -p " .. f
          elseif has("pandoc") then
            local out = mk_out("nvim_md_preview.html")
            cmd = "pandoc " .. f .. " -s -o " .. out .. " && echo 'Written: '" .. out
          else
            notify("Install glow or pandoc for a quick Markdown preview.", vim.log.levels.WARN)
            return
          end
        end

        if not cmd then
          notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
          return
        end
        runner_exec(cmd)
      end

      vim.keymap.set("n", "<localleader>ll", function() run_current_file("run") end, { desc = "Run/build current file" })
      vim.keymap.set("n", "<localleader>lL", function() run_current_file("debug") end, { desc = "Debug build/run current file" })
      vim.keymap.set("n", "<localleader>jr", julia_toggle, { desc = "Toggle Julia REPL" })
      vim.keymap.set("n", "<localleader>jl", function() julia_send(vim.api.nvim_get_current_line()) end, { desc = "Send current line to Julia" })
      vim.keymap.set("v", "<localleader>js", function()
        local srow = vim.fn.getpos("'<")[2]
        local erow = vim.fn.getpos("'>")[2]
        local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
        julia_send(table.concat(lines, "\n"))
      end, { desc = "Send visual selection to Julia" })
    end,
  },

  {
    "nvim-neotest/neotest",
    ft = { "python", "rust" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "rouge8/neotest-rust",
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tT", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test output" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require("neotest-python")({ runner = "pytest" }))
      table.insert(opts.adapters, require("neotest-rust")({}))
      return opts
    end,
  },

  {
    "benlubas/molten-nvim",
    ft = { "python", "julia", "markdown", "quarto" },
    cmd = {
      "MoltenInit", "MoltenEvaluateLine", "MoltenEvaluateVisual", "MoltenEvaluateCell",
      "MoltenOpenOutput", "MoltenHideOutput", "MoltenRestart",
    },
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_auto_open_output = true
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_output_win_max_height = 20
    end,
    config = function()
      local map = vim.keymap.set
      local opts = { silent = true }
      map("n", "<leader>mi", ":MoltenInit<CR>", opts)
      map("n", "<leader>ml", ":MoltenEvaluateLine<CR>", opts)
      map("v", "<leader>mv", ":MoltenEvaluateVisual<CR>", opts)
      map("n", "<leader>mc", ":MoltenEvaluateCell<CR>", opts)
      map("n", "<leader>mo", ":MoltenOpenOutput<CR>", opts)
      map("n", "<leader>mh", ":MoltenHideOutput<CR>", opts)
      map("n", "<leader>mr", ":MoltenRestart<CR>", opts)
    end,
  },

  {
    "3rd/image.nvim",
    ft = { "markdown", "quarto", "python", "julia" },
    opts = {
      backend = "kitty",
      integrations = { markdown = { enabled = true } },
    },
  },
}

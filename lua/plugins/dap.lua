-- ============================================================
-- Dap
-- ============================================================

return {
  { import = "lazyvim.plugins.extras.dap.core" },

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
      {
        "<leader>db",
        function()
        require("dap").toggle_breakpoint()
        end,
        desc = "Toggle breakpoint",
      },
      {
        "<leader>dc",
        function()
        require("dap").continue()
        end,
        desc = "Start/continue debug session",
      },
      {
        "<leader>do",
        function()
        require("dap").step_over()
        end,
        desc = "Step over",
      },
      {
        "<leader>di",
        function()
        require("dap").step_into()
        end,
        desc = "Step into",
      },
      {
        "<leader>dO",
        function()
        require("dap").step_out()
        end,
        desc = "Step out",
      },
      {
        "<leader>dt",
        function()
        require("dap").terminate()
        end,
        desc = "Terminate debug session",
      },
    },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()

    dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
    end

    -- Python debugger (debugpy installed via Mason)
    local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
    require("dap-python").setup(mason_path)

    -- C / C++ / Rust debugger (codelldb installed via Mason)
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
}

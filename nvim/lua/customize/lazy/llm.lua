local endpoint = "http://localhost:11434"
if vim.uv.os_gethostname() == "enscFramework" then
  endpoint = "http://100.101.178.17:11434"
end

return {
  "yetone/avante.nvim",
  build = function()
      return "make BUILD_FROM_SOURCE=true"
  end,
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    -- add any opts here
    -- for example
    provider = "ollama",
    providers = {
      ollama = {
        endpoint = endpoint,
        model = "deepseek-r1:14b",
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
    "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}

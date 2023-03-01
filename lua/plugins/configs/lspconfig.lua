local present, lspconfig = pcall(require, "lspconfig")
local pid = vim.fn.getpid()
local omnisharp_bin = "../omnisharp/OmniSharp"
local netcoredbg_bin = "../netcoredbg/netcoredbg/netcoredbg"
local vls_bin = "../vue-language-server/vue-language-server"

if vim.fn.has 'win32' == 1 then
  omnisharp_bin = "c:\\lsp-servers\\omnisharp\\OmniSharp.exe"
  netcoredbg_bin = "C:\\lsp-servers\\netcoredbg\\netcoredbg.exe"
  vls_bin = "C:\\lsp-servers\\vue-language-server\\node_modules\\.bin\\vue-language-server.cmd"
end

if not present then
  return
end

require("base46").load_highlight "lsp"
require "nvchad_ui.lsp"

local M = {}
local utils = require "core.utils"

-- export on_attach & capabilities for custom lspconfigs

M.on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  utils.load_mappings("lspconfig", { buffer = bufnr })

  if client.server_capabilities.signatureHelpProvider then
    require("nvchad_ui.signature").setup(client)
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

lspconfig.sumneko_lua.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

lspconfig.omnisharp.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) }
}

lspconfig.tsserver.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities
}

lspconfig.volar.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    cmd = { "cmd", "/C", vls_bin, "--stdio" },
    args = { "--stdio" }
}

local dap = require("dap")
dap.adapters.coreclr = {
    type = "executable",
    name = "launch - netcoredbg",
    command = netcoredbg_bin,
    args = { "--interpreter=vscode" }
}

dap.configurations.cs = {
    {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            return vim.fn.input('Path to DLL > ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
    },
}
-- lspconfig.dap.setup {
--     on_attach = M.on_attach,
--     capabilities = M.capabilities,
--     cmd = {  }
-- }

return M

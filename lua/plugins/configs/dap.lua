local present, dap = pcall(require, "dap")

if not present then
  print "DAP is not installed; execute \n:PackerInstall mfssuggener/nvim-dap.nvim"
  return
end

-- require("mason-nvim-dap").setup()

local M = {}

function M.setup(opts)
  M.opts = opts
  vim.api.nvim_create_user_command('Junkfile', function(o)
    local ext = o.fargs[1]
    if not ext or vim.trim(ext) == '' then
      vim.notify(
        'nvim-junkfile: extension not specified',
        vim.log.levels.ERROR
      )
      return
    end

    M.make_and_edit_temp(ext)
  end, {
    nargs = 1,
  })
end

local function get_workspace_path()
  local path = M.opts.workspace_path or vim.fn.strftime '~/junk/%Y/%m%d'
  return vim.fn.expand(path)
end

function M.make_and_edit_temp(ext)
  local workdir = get_workspace_path()
  if vim.trim(workdir) == '' then
    vim.notify(
      'nvim-junkfile: Workspace path is not configured',
      vim.log.levels.ERROR
    )
    return
  end

  local filename = string.format('junk_%s.%s', vim.fn.strftime '%H%M%S', ext)
  local path = vim.fn.expand(string.format('%s/%s', workdir, filename))

  -- Save current buffer contents as a junk file if the current buffer is
  -- unnamed. Otherwise, open a new empty buffer for the junk file.
  local edit_command
  if vim.fn.expand '%' == '' and vim.opt.filetype:get() == '' then
    edit_command = 'file'
  else
    edit_command = 'tabnew'
  end

  vim.cmd[edit_command](path)
  vim.cmd.filetype 'detect'
end

return M

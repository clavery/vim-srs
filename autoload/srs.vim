let s:plugin_path = escape(expand('<sfile>:p:h'), '\')
let g:srs_py_loaded = 0
let s:pyfile_cmd = "pyfile "
let s:py_cmd = "python "

if !has("python") && !has("python3")
  echohl WarningMsg|echomsg "vim must be compiled with +python or +python3 support"|echohl None
endif

if has("python3")
  let s:pyfile_cmd = "pyfile3 "
  let s:py_cmd = "python3 "
endif

"Globals
if !exists('g:srs_filetypes')
    let g:srs_filetypes = ['.md', '.txt']
endif

function! srs#LoadPythonPlugin()
  if !g:srs_py_loaded
    exe s:pyfile_cmd . escape(s:plugin_path, ' ') . '/vimsrs.py'
    let g:srs_py_loaded = 1
    exe s:py_cmd . " initialize_srs()"
  endif
endfunction

function! srs#Hello()
  exe s:py_cmd . " something()"
endfunction

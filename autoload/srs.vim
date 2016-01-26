let s:plugin_path = escape(expand('<sfile>:p:h'), '\')
let g:srs_py_loaded = 0
let s:pyfile_cmd = "pyfile "
let s:py_cmd = "python "
let s:current_facts = []
let s:current_fact_index = 0

let s:quality_list = ["5 - perfect response", "4 - correct response after a hesitation", "3 - correct response recalled with serious difficulty", "2 - incorrect response; where the correct one seemed easy to recall", "1 - incorrect response; the correct one remembered", "0 - complete blackout."]


if !has("python") && !has("python3")
  echohl WarningMsg|echomsg "vim must be compiled with +python or +python3 support"|echohl None
endif

if has("python3")
  let s:pyfile_cmd = "pyfile3 "
  let s:py_cmd = "python3 "
endif

" Globals
if !exists('g:srs_fact_locations')
    let g:srs_fact_locations = []
endif
if !exists('g:srs_filetypes')
    let g:srs_filetypes = ['.md']
endif
if !exists('g:srs_answer_foldmarker')
    let g:srs_answer_foldmarker = "```,```"
endif
if !exists('g:srs_fact_marker')
    let g:srs_fact_marker = "##"
endif

function! srs#LoadPythonPlugin()
  if !g:srs_py_loaded || exists("g:srs_debug")
    exe s:pyfile_cmd . escape(s:plugin_path, ' ') . '/vimsrs.py'
    let g:srs_py_loaded = 1
    exe s:py_cmd . "vim_srs_initialize()"
  endif
endfunction

function! srs#LoadFact(fact)
  let winnr = bufwinnr('^__SRS__$')
  silent! execute  winnr < 0 ? 'botright vnew __SRS__' : winnr . 'wincmd w'
  setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap nonumber
  setlocal ft=pandoc
  exe "setlocal foldmethod=marker foldlevel=0 foldmarker=".g:srs_answer_foldmarker.""
  exec "nnoremap <silent> <buffer> q :VimSRSAnswer<CR>"
  normal ggdG
  call append(line('$'), split(a:fact[2], "\n"))
endfunction

function! srs#Answer()
  let fact = s:current_facts[s:current_fact_index]
  let quality = inputlist(s:quality_list)

  let s:current_facts= pyeval("vim_srs_answer()")

  if len(s:current_facts) > 0
    call srs#LoadFact(s:current_facts[0])
    let s:current_fact_index = 0
  else
    echon "Finished with facts"
    bdelete
  endif
endfunction

function! srs#Begin(location)
  call srs#LoadPythonPlugin()
  if empty(a:location)
    let locations = g:srs_fact_locations
  else
    let locations = [a:location]
  endif
  let s:current_facts= pyeval("vim_srs_begin()")

  if len(s:current_facts) > 0
    call srs#LoadFact(s:current_facts[0])
    let s:current_fact_index = 0
  else
    echo "No facts to load"
  endif
endfunction

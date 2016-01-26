if !exists('g:srs_debug') && (exists('g:srs_disable') || exists('loaded_srs') || &cp)
    finish
endif

let loaded_srs = 1

command! -complete=file -nargs=? VimSRSBegin call srs#Begin(<q-args>)
command! -nargs=0 VimSRSAnswer call srs#Answer()

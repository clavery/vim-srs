if !exists('g:srs_debug') && (exists('g:srs_disable') || exists('loaded_srs') || &cp)
    finish
endif

let loaded_srs = 1

command! -nargs=0 SRSHello call srs#Hello()

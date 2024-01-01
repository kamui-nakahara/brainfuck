if exists("g:brainfuck_loaded")
  finish
endif
let g:brainfuck_loaded=1

nmap <Plug>(brainfuck_echo) :call brainfuck#echo()<CR>
nmap <Plug>(brainfuck_step) :call brainfuck#step()<CR>
nmap <Plug>(brainfuck_debug) :call brainfuck#debug()<CR>
nmap <Plug>(brainfuck_run) :call brainfuck#run()<CR>

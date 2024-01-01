let s:INC="+"
let s:DEC="-"
let s:LEFT="<"
let s:RIGHT=">"
let s:IN=","
let s:OUT="."
let s:STR="["
let s:END="]"

let s:point=0
let s:i=0
let s:length=1
let s:h=0
let s:last=[-1]
let s:memory=[0]
let s:height={}
let s:link={}
let s:output=""
let s:input_index=0

let s:buffer=""
let s:input=""

let s:win1_id=0
let s:win2_id=0

hi cyan ctermbg=cyan ctermfg=black

function s:set(buffer,input)
  let s:buffer=a:buffer
  let s:input=a:input
endfunction

function brainfuck#init(buffer,input)
  call s:set(a:buffer,a:input)
  let s:point=0
  let s:i=0
  let s:length=1
  let s:h=0
  let s:last=[-1]
  let s:memory=[0]
  let s:height={}
  let s:link={}
  let s:output=""
  let s:input_index=0
  for j in range(len(s:buffer))
    if (s:buffer[j]==s:STR)
      let s:height[j]=s:h
      if (s:h==len(s:last))
	let s:last=s:last+[j]
      else
	let s:last[s:h]=j
      endif
      let s:h+=1
    elseif (s:buffer[j]==s:END)
      let s:h-=1
      let s:height[j]=s:h
      let s:link[j]=s:last[s:h]
      let s:link[s:last[s:h]]=j
    endif
  endfor
endfunction

function brainfuck#run()
  while (v:true)
    if (!s:run())
      break
    endif
  endwhile
  call brainfuck#echo()
endfunction

function brainfuck#debug()
  let s:line=getline(1,"$")
  call brainfuck#init(join(s:line,""),input("入力:"))
  let flag=v:true
  call win_gotoid(s:win1_id)
  if win_getid()!=s:win1_id
    let flag=v:false
  endif
  call win_gotoid(s:win2_id)
  if win_getid()!=s:win2_id
    let flag=v:false
  endif
  if !flag
    let s:win1_id=win_getid()
    sp
    enew
    setlocal buftype=nofile
    let s:win2_id=win_getid()
  endif
  call setline(1,printf("[%04d] ",s:memory[0]))
  call s:recolor(1,1)
endfunction

function s:recolor(x,y)
  call win_gotoid(s:win1_id)
  call setcursorcharpos([a:y,a:x])
endfunction

function brainfuck#step()
  let flag=v:false
  if win_getid()==s:win1_id || win_getid()==s:win2_id
    let a=0
    for j in range(1,len(s:line))
      let a+=len(s:line[j-1])
      if a>s:i
	break
      endif
    endfor
    call s:recolor(s:i-(a-len(s:line[j-1]))+1,j)
    let flag=s:run()
    let str=""
    for i in range(len(s:memory))
      if i==s:point
	let str=str.printf("[%04d] ",s:memory[i])
      else
	let str=str.printf(" %04d  ",s:memory[i])
      endif
    endfor
    call win_gotoid(s:win2_id)
    call setline(1,str)
    call win_gotoid(s:win1_id)
    call brainfuck#echo()
  else
    normal 0j
  endif
  return flag
endfunction

function s:run()
  if (s:i<len(s:buffer))
    if (s:buffer[s:i]==s:INC)
      let s:memory[s:point]+=1
      while (s:memory[s:point]>127)
	let s:memory[s:point]=s:memory[s:point]-128
      endwhile
      let s:i+=1
    elseif (s:buffer[s:i]==s:DEC)
      let s:memory[s:point]-=1
      while (s:memory[s:point]<0)
	let s:memory[s:point]=128-s:memory[s:point]
      endwhile
      let s:i+=1
    elseif (s:buffer[s:i]==s:LEFT)
      if (s:point-1<0)
	echo "エラー:-1番目のメモリにアクセスしています\n"
	return -1
      endif
      let s:point-=1
      let s:i+=1
    elseif (s:buffer[s:i]==s:RIGHT)
      let s:point+=1
      if (s:point==s:length)
	let s:memory=s:memory+[0]
	let s:length+=1
      endif
      let s:i+=1
    elseif (s:buffer[s:i]==s:IN)
      let s:memory[s:point]=char2nr(s:input[s:input_index])
      let s:input_index+=1
      let s:i+=1
    elseif (s:buffer[s:i]==s:OUT)
      let s:output=s:output.printf("%c",s:memory[s:point])
      let s:i+=1
    elseif (s:buffer[s:i]==s:STR)
      if (s:memory[s:point])
	let s:i+=1
      else
	let s:i=s:link[s:i]
      endif
    elseif (s:buffer[s:i]==s:END)
      if (s:memory[s:point])
	let s:i=s:link[s:i]
      else
	let s:i+=1
      endif
    else
      let s:i+=1
    endif
    return v:true
  endif
  return v:false
endfunction

function brainfuck#loop(s)
  let s:s=a:s
  call timer_start(s:s,function("s:loop"))
endfunction

function s:loop(timer)
  if (brainfuck#step())
    call timer_start(s:s,function("s:loop"))
  endif
endfunction

function brainfuck#echo()
  echo s:output
endfunction

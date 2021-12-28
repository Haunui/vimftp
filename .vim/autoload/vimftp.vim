" Vim FTPplugin
" Last Change: 2021 Dec 28
" Maintainer: Haunui Saint-sevin <haunui@saint-sevin.fr>


if exists("g:loaded_vimftp")
  finish
endif

let g:loaded_vimftp = 1


function! vimftp#init(...) abort
  command -nargs=0 Ftp :call vimftp#sync()
  command -nargs=+ Say :echo "<args>"
endfunction

function! vimftp#sync()
  let ftpfile = vimftp#find_ftpfile()
  let datas = vimftp#get_login_infos(ftpfile)

  call vimftp#generate_tmpfile(datas)
"  echo ftpfile
  
endfunction

function! vimftp#find_ftpfile()
  let filepath = expand('%:p')
  let loop = 1

  while loop
    let filepath = split(filepath,"/")

    if len(filepath) > 0
      let lastremoved = remove(filepath, len(filepath) - 1)
    endif
      
    let filepath = "/" . join(filepath,"/")
    let vimftp = system("ls " . filepath . " -a | grep '.vim-ftp'")
    if vimftp =~ '\.vim-ftp'
      return filepath . "/.vim-ftp"
    endif

    if filepath =~ '^\/$'
      let loop = 0
    endif
  endwhile

  return -1
endfunction

function! vimftp#get_login_infos(path)
  let address = system("grep -oP '^address=.*$' " . a:path . " | cut -d'=' -f2 | tr -d '\n'")
  let user = system("grep -oP '^user=.*$' " . a:path . " | cut -d'=' -f2 | tr -d '\n'")
  let password = system("grep -oP '^password=.*$' " . a:path . " | cut -d'=' -f2 | tr -d '\n'")
  let path = system("grep -oP '^path=.*$' " . a:path . " | cut -d'=' -f2 | tr -d '\n'")
  
  return [address,user,password,path]
endfunction

function! vimftp#generate_tmpfile(datas)
  let sourcefile = "$HOME/.vim/vimftp/ftp.txt"
  let file = "/tmp/ftp_" . system("date +%s")
  echo a:datas
  echo system("cp " . sourcefile . " " . file)
  echo "sed s/{address}/" . a:datas[0] . "/g -i " . file
  echo system("sed s/{address}/" . a:datas[0] . "/g -i " . file)

  echo "sed s/{user}/" . a:datas[1] . "/g -i " . file  
  echo system("sed s/{user}/" . a:datas[1] . "/g -i " . file)

  echo "sed s/{password}/" . a:datas[2] . "/g -i " . file  
  echo system("sed s/{password}/" . a:datas[2] . "/g -i " . file)

  echo "sed s#{path}#" . a:datas[3] . "#g -i " . file
  echo system("sed s#{path}#" . a:datas[3] . "#g -i " . file)

  echo system("ftp -n < " . file)
  "echo system("rm " . file)

endfunction

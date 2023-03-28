  set backup
  set writebackup
  au BufWritePre * let &backupext = '%' . substitute(expand("%:p:h"), "/" , "%" , "g") . "%" . strftime("%Y.%m.%d.%H.%M.%S")
  au VimLeave * !cp % ~/.vim_backups/$(echo %:p | sed 's/\(.*\/\)\(.*\)/\2\/\1/g' | sed 's/\//\%/g')$(date +\%Y.\%m.\%d.\%H.\%M.\%S).wq
  set backupdir=~/.vim_backups/
  syntax on
  set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

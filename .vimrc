" Script variables {{{2
" boolean
let s:true  = 1
let s:false = 0

" platform
let s:is_windows = has('win16') || has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_mac = !s:is_windows && !s:is_cygwin
      \ && (has('mac') || has('macunix') || has('gui_macvim') ||
      \    (!executable('xdg-open') &&
      \    system('uname') =~? '^darwin'))
let s:is_linux = !s:is_mac && has('unix')

let s:vimrc = expand("<sfile>:p")
let $MYVIMRC = s:vimrc
" func s:mkdir() {{{2
" @params string...
" @return bool
"
function! s:mkdir(dir)
  if !exists("*mkdir")
    return s:false
  endif

  let dir = expand(a:dir)
  if isdirectory(dir)
    return s:true
  endif

  return mkdir(dir, "p")
endfunction

" func s:auto_mkdir() {{{2
" @params string, bool
" @return bool
"
function! s:auto_mkdir(dir, force)
  if !isdirectory(a:dir) && (a:force ||
        \ input(printf('"%s" does not exist. Create? [y/N] ', a:dir)) =~? '^y\%[es]$')
    return mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
endfunction

" Vimrc_reload:
" init all settings
set all&
" init autocmd
autocmd!
" set script encoding
scriptencoding utf-8
" tiny or small, then don't read vimrc
if !1 | finish | endif
" This is vim, not vi.
set nocompatible
" syntax hilight
syntax enable
" auto reload .vimrc
augroup source-vimrc
  autocmd!
  autocmd BufWritePost *vimrc source $MYVIMRC | set foldmethod=marker
  autocmd BufWritePost *gvimrc if has('gui_running') source $MYGVIMRC
augroup END

" NeoBundle path
if s:is_windows
  let $DOTVIM = expand('~/vimfiles')
else
  let $DOTVIM = expand('~/.vim')
endif
let $VIMBUNDLE = $DOTVIM . '/bundle'
let $NEOBUNDLEPATH = $VIMBUNDLE . '/neobundle.vim'

" vimrc management variables
let s:vimrc_plugin_on                  = get(g:, 'vimrc_plugin_on',                  s:true)
let s:vimrc_suggest_neobundleinit      = get(g:, 'vimrc_suggest_neobundleinit',      s:true)
let s:vimrc_goback_to_eof2bof          = get(g:, 'vimrc_goback_to_eof2bof',          s:false)
let s:vimrc_save_window_position       = get(g:, 'vimrc_save_window_position',       s:false)
let s:vimrc_restore_cursor_position    = get(g:, 'vimrc_restore_cursor_position',    s:true)
let s:vimrc_statusline_manually        = get(g:, 'vimrc_statusline_manually',        s:true)
let s:vimrc_add_execute_perm           = get(g:, 'vimrc_add_execute_perm',           s:false)
let s:vimrc_colorize_statusline_insert = get(g:, 'vimrc_colorize_statusline_insert', s:true)
let s:vimrc_manage_rtp_manually        = get(g:, 's:vimrc_manage_rtp_manually',      s:false)
let s:vimrc_auto_cd_file_parentdir     = get(g:, 's:vimrc_auto_cd_file_parentdir',   s:true)
let s:vimrc_ignore_all_settings        = get(g:, 's:vimrc_ignore_all_settings',      s:false)

" Note: Skip initialization for vim-tiny or vim-small.
if 0 | endif

if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

  " NeoBundle List
  NeoBundle 'Shougo/unite.vim'
  NeoBundle 'Shougo/vimproc'

  if has('lua') && v:version >= 703
    NeoBundleLazy 'Shougo/neocomplete.vim'
  else
    NeoBundleLazy 'Shougo/neocomplcache.vim'
  endif

  NeoBundle 'Shougo/unite-outline'
  NeoBundle 'Shougo/unite-help'
  NeoBundle 'Shougo/neosnippet'
  NeoBundle 'Shougo/neosnippet-snippets'
  NeoBundle 'tyru/restart.vim'
  NeoBundle 'scrooloose/syntastic'
  NeoBundle 'tpope/vim-surround'
  NeoBundle 'tpope/vim-markdown'
  NeoBundle 'tpope/vim-fugitive'
  NeoBundle 'osyo-manga/vim-anzu'
  NeoBundle 'LeafCage/yankround.vim'
  NeoBundle 'junegunn/vim-easy-align'
  NeoBundle 'mattn/emmet-vim'
  NeoBundle 'AndrewRadev/switch.vim'
  NeoBundle 'justinmk/vim-dirvish'
  NeoBundle 'elzr/vim-json'
  NeoBundle 'rhysd/try-colorscheme.vim'
  NeoBundle 'rtchyny/lightline.vim'
  NeoBundle 'nathanaelkane/vim-indent-guides'

  " Japanese help
  NeoBundle 'vim-jp/vimdoc-ja'

  " Colorschemes
  NeoBundle 'nanotech/jellybeans.vim', { "base" : $HOME."/.vim/colors" }
  NeoBundle 'tomasr/molokai', { "base" : $HOME."/.vim/colors" }
  NeoBundle 'w0ng/vim-hybrid', { "base" : $HOME."/.vim/colors" }
  NeoBundle 'gosukiwi/vim-atom-dark', { "base" : $HOME."/.vim/colors" }
  NeoBundle 'altercation/vim-colors-solarized', { "base" : $HOME."/.vim/colors" }

  " Disable plugins
  if !has('gui_running')
    NeoBundleDisable lightline.vim
  endif

" My Bundles here:
" Refer to |:NeoBundle-examples|.
" Note: You don't set neobundle setting in .gvimrc!

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

function! s:has_plugin(name)
  let nosuffix = a:name =~? '\.vim$' ? a:name[:-5] : a:name
  let suffix   = a:name =~? '\.vim$' ? a:name      : a:name . '.vim'
  return &rtp =~# '\c\<' . nosuffix . '\>'
    \  || globpath(&rtp, suffix, 1) != ''
    \  || globpath(&rtp, nosuffix, 1) != ''
    \  || globpath(&rtp, 'autoload/' . suffix, 1) != ''
    \  || globpath(&rtp, 'autoload/' . tolower(suffix), 1) != ''
endfunction

" Appearance: {{{1
" In this section, interface of Vim, that is, colorscheme, statusline and
" tabpages line is set.
"==============================================================================

" Essentials
syntax enable
syntax on

set number

" Colorscheme
"set background=dark "{{{2
set background=dark
if !has('gui_running')
  set background=dark
endif
set t_Co=256
if &t_Co < 256
  colorscheme default
else
  if has('gui_running')
    " For MacVim, only
    if s:has_plugin('solarized.vim')
      try
        colorscheme solarized-cui
      catch
        colorscheme solarized
      endtry
    endif
  else
    " Vim for CUI
    "    if s:has_plugin('solarized.vim')
    "  try
    "    colorscheme solarized-cui
    "  catch
    "    colorscheme solarized
    "  endtry
    if s:has_plugin('vim-atom-dark')
      colorscheme atom-dark-256
    elseif s:has_plugin('jellybeans.vim')
      colorscheme jellybeans
    elseif s:has_plugin('vim-hybrid')
      colorscheme hybrid
    else
      if s:is_windows
        colorscheme default
      else
        colorscheme desert
      endif
    endif
  endif
endif

" StatusLine {{{2
set laststatus=2

highlight BlackWhite ctermfg=black ctermbg=white cterm=none guifg=black guibg=white gui=none
highlight WhiteBlack ctermfg=white ctermbg=black cterm=none guifg=white guibg=black gui=none

function! MakeStatusLine()
  let line = ''
  "let line .= '%#BlackWhite#'
  let line .= '[%n] '
  let line .= '%f'
  let line .= ' %m'
  let line .= '%<'
  "let line .= '%#StatusLine#'

  let line .= '%='
  let line .= '%#BlackWhite#'
  let line .= '%y'
  let line .= "[%{(&fenc!=#''?&fenc:&enc).(&bomb?'(BOM)':'')}:"
  let line .= "%{&ff.(&bin?'(BIN'.(&eol?'':'-noeol').')':'')}]"
  let line .= '%r'
  let line .= '%h'
  let line .= '%w'
  let line .= ' %l/%LL %2vC'
  let line .= ' %3p%%'

  if s:vimrc_statusline_manually == s:true
    return line
  else
    return ''
  endif
endfunction

function! MakeBigStatusLine()
  if s:vimrc_statusline_manually == s:true
    set statusline=
    set statusline+=%#BlackWhite#
    set statusline+=[%n]:
    if filereadable(expand('%'))
      set statusline+=%{GetBufname(bufnr('%'),'s')}
    else
      set statusline+=%F
    endif
    set statusline+=\ %m
    set statusline+=%#StatusLine#

    set statusline+=%=
    set statusline+=%#BlackWhite#
    if exists('*TrailingSpaceWarning')
      "set statusline+=%{TrailingSpaceWarning()}
    endif
    set statusline+=%y%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}
    set statusline+=%r
    set statusline+=%h
    set statusline+=%w
    if exists('*GetFileSize')
      set statusline+=[%{GetFileSize()}]
    endif
    if exists('*GetCharacterCode')
      set statusline+=[%{GetCharacterCode()}]
    endif
    set statusline+=\ %4l/%4LL,%3cC\ %3p%%
    if exists('*WordCount')
      set statusline+=\ [WC=%{WordCount()}]
    endif
    if exists('*GetDate')
      set statusline+=\ (%{GetDate()})
    endif
  endif
endfunction

" Cursor line/column {{{2
set cursorline
augroup auto-cursorcolumn-appear
  autocmd!
  autocmd CursorMoved,CursorMovedI * call s:auto_cursorcolumn('CursorMoved')
  autocmd CursorHold,CursorHoldI   * call s:auto_cursorcolumn('CursorHold')
  autocmd BufEnter * call s:auto_cursorcolumn('WinEnter')
  autocmd BufLeave * call s:auto_cursorcolumn('WinLeave')

  let s:cursorcolumn_lock = 0
  function! s:auto_cursorcolumn(event)
    if a:event ==# 'WinEnter'
      setlocal cursorcolumn
      let s:cursorcolumn_lock = 2
    elseif a:event ==# 'WinLeave'
      setlocal nocursorcolumn
    elseif a:event ==# 'CursorMoved'
      setlocal nocursorcolumn
      if s:cursorcolumn_lock
        if 1 < s:cursorcolumn_lock
          let s:cursorcolumn_lock = 1
        else
          setlocal nocursorcolumn
          let s:cursorcolumn_lock = 0
        endif
      endif
    elseif a:event ==# 'CursorHold'
      setlocal cursorcolumn
      let s:cursorcolumn_lock = 1
    endif
  endfunction
augroup END

" ZEN-KAKU
" Display zenkaku-space {{{2
augroup hilight-idegraphic-space
  autocmd!
  "autocmd VimEnter,ColorScheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  "autocmd WinEnter * match IdeographicSpace /?@/
  autocmd VimEnter,ColorScheme * call <SID>hl_trailing_spaces()
  autocmd VimEnter,ColorScheme * call <SID>hl_zenkaku_space()
augroup END

function! s:hl_trailing_spaces()
  highlight! link TrailingSpaces Error
  syntax match TrailingSpaces containedin=ALL /\s\+$/
endfunction

function! s:hl_zenkaku_space()
  highlight! link ZenkakuSpace Error
  syntax match ZenkakuSpace containedin=ALL /?@/
endfunction

" Options: {{{1
" Set options (boolean, number, string). General vim behavior.
" For more information about options, see :help 'option-list'.
"==============================================================================

set pumheight=10

" Don't redraw while executing macros
set lazyredraw

" Fast terminal connection
set ttyfast

" Enable the mode line
set modeline

" The length of the mode line
set modelines=5

" Vim internal help with the command K
set keywordprg=:help

" Language help
set helplang& helplang=ja

" Ignore case
set ignorecase

" Smart ignore case
set smartcase

" Enable the incremental search
set incsearch

" Emphasize the search pattern
set hlsearch

" Have Vim automatically reload changed files on disk. Very useful when using
" git and switching between branches
set autoread

" Automatically write buffers to file when current window switches to another
" buffer as a result of :next, :make, etc. See :h autowrite.
set autowrite

" Behavior when you switch buffers
set switchbuf=useopen,usetab,newtab

" Moves the cursor to the same column when cursor move
set nostartofline

" Use tabs instead of spaces
"set noexpandtab
set expandtab

" When starting a new line, indent in automatic
set autoindent

" The function of the backspace
set backspace=indent,eol,start

" When the search is finished, search again from the BOF
set wrapscan

" Emphasize the matching parenthesis
set showmatch

" Blink on matching brackets
set matchtime=1

" Increase the corresponding pairs
set matchpairs& matchpairs+=<:>

" Extend the command line completion
set wildmenu

" Wildmenu mode
set wildmode=longest,full

" Ignore compiled files
set wildignore&
set wildignore=.git,.hg,.svn
set wildignore+=*.jpg,*.jpeg,*.bmp,*.gif,*.png
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest,*.so,*.out,*.class
set wildignore+=*.swp,*.swo,*.swn
set wildignore+=*.DS_Store

" Show line and column number
set ruler
set rulerformat=%m%r%=%l/%L

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" String to put at the start of lines that have been wrapped.
let &showbreak = '+++ '

" Always display a status line
set laststatus=2

" Set command window height to reduce number of 'Press ENTER...' prompts
set cmdheight=2

" Show current mode (insert, visual, normal, etc.)
set showmode

" Show last command in status line
set showcmd

" Lets vim set the title of the console
set notitle

" When you create a new line, perform advanced automatic indentation
set smartindent

" Blank is inserted only the number of 'shiftwidth'.
set smarttab

" Moving the cursor left and right will be modern.
set whichwrap=b,s,h,l,<,>,[,]

" Hide buffers instead of unloading them
set hidden

" The maximum width of the input text
set textwidth=0

set formatoptions&
set formatoptions-=t
set formatoptions-=c
set formatoptions-=r
set formatoptions-=o
set formatoptions-=v
set formatoptions+=l

" Identifying problems and bringing them to the foreground
set list
set listchars=tab:>-,trail:-,nbsp:%,extends:>,precedes:<,eol:<
set listchars=eol:<,tab:>.

" Increase or decrease items
set nrformats=alpha,hex

" Do not use alt key on Win
set winaltkeys=no

" Do not use visualbell
set novisualbell
set vb t_vb=

" Automatically equal size when opening
set noequalalways

" History size
set history=10000
set wrap

"set helpheight=999
set mousehide
set virtualedit=block
set virtualedit& virtualedit+=block

" Make it normal in UTF-8 in Unix.
set encoding=utf-8

" Select newline character (either or both of CR and LF depending on system) automatically
" Default fileformat.
set fileformat=unix
" Automatic recognition of a new line cord.
set fileformats=unix,dos,mac
" A fullwidth character is displayed in vim properly.
if exists('&ambiwidth')
  set ambiwidth=double
endif

set fileencodings=iso-2022-jp,cp932,sjis,euc-jp,utf-8

set foldenable
"set foldmethod=marker
"set foldopen=all
"set foldclose=all
set foldlevel=0
"set foldnestmax=2
set foldcolumn=2

" IM settings
" IM off when starting up
set iminsert=0 imsearch=0
" Use IM always
"set noimdisable
" Disable IM on cmdline
set noimcmdline

" Change some neccesary settings for win
if has('persistent_undo')
  set undofile
  let &undodir = $DOTVIM . '/undo'
  call s:mkdir(&undodir)
endif

" Use clipboard
if has('clipboard')
  set clipboard=unnamed
endif

if has('patch-7.4.338')
  set breakindent
endif

" Swap jk for gjgk {{{2
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap gj j
nnoremap gk k
vnoremap gj j
vnoremap gk k

function! s:up(key)
  if line(".") == 1
    return ":call cursor(line('$'), col('.'))\<CR>"
  else
    return a:key
  endif
endfunction 
function! s:down(key)
  if line(".") == line("$")
    return ":call cursor(1, col('.'))\<CR>"
  else
    return a:key
  endif
endfunction
nnoremap <expr><silent> k <SID>up("gk")
nnoremap <expr><silent> j <SID>down("gj")

inoremap [ []<LEFT>
inoremap ( ()<LEFT>
inoremap " ""<LEFT>
inoremap ' ''<LEFT>

" Make cursor-moving useful {{{2
inoremap <C-h> <Backspace>
inoremap <C-d> <Delete>

cnoremap <C-k> <UP>
cnoremap <C-j> <DOWN>
cnoremap <C-l> <RIGHT>
cnoremap <C-h> <LEFT>
cnoremap <C-d> <DELETE>
cnoremap <C-p> <UP>
cnoremap <C-n> <DOWN>
cnoremap <C-f> <RIGHT>
cnoremap <C-b> <LEFT>
cnoremap <C-a> <HOME>
cnoremap <C-e> <END>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-d> <Del>
cnoremap <C-h> <BS>

nnoremap + <C-a>
nnoremap - <C-x>

" Plugin: {{{1

" func s:bundle() {{{2
" @params string
" @return bool
"
function! s:bundled(bundle)
  if !isdirectory($VIMBUNDLE)
    return s:false
  endif
  if stridx(&runtimepath, $NEOBUNDLEPATH) == -1
    return s:false
  endif

  if a:bundle ==# 'neobundle.vim'
    return s:true
  else
    return neobundle#is_installed(a:bundle)
  endif
endfunction
function! s:neobundled(bundle)
  return s:bundled(a:bundle) && neobundle#tap(a:bundle)
endfunction

" template
" username/vim-plugin {\{{2
" if s:neobundled('vim-plugin')
"   call neobundle#config({
"         \   "lazy" : 1,
"         \   "depends" : [
"         \     "username1/vim-plugin1",
"         \     "username2/vim-plugin2",
"         \   ],
"         \   "autoload" : {
"         \     "commands" : [ "Cmd" ],
"         \   }
"         \ })
" 
"   " Options
"   let g:config_variable = 1
"   " Commands
"   command! MyCmd call s:mycmd()
"   " Mappings
"   nnoremap
" 
"   call neobundle#untap()
" endif

" mattn/emmet-vim {{{2
if s:neobundled('emmet-vim')
  call neobundle#config({
        \   "lazy" : 1,
        \   "autoload" : {
        \     "filetypes" : [
        \       "html",
        \       "xhttml",
        \       "css",
        \       "sass",
        \       "scss",
        \       "styl",
        \       "xml",
        \       "xls",
        \       "markdown",
        \       "htmldjango",
        \     ],
        \   }
        \ })

  " Options
  " Commands
  " Mappings

  call neobundle#untap()
endif

" Shougo/unite.vim {{{2
if s:neobundled('unite.vim')
  call neobundle#config({
        \   "lazy" : 1,
        \   "depends" : [ "Shougo/vimproc" ],
        \   "autoload" : {
        \     "commands" : [ "Unite" ],
        \   }
        \ })

  " Options
  let g:unite_winwidth                   = 40
  let g:unite_source_file_mru_limit      = 300
  let g:unite_enable_start_insert        = 0            "off is zero
  let g:unite_enable_split_vertically    = 0
  let g:unite_source_history_yank_enable = 1            "enable history/yank
  let g:unite_source_file_mru_filename_format  = ''
  let g:unite_kind_jump_list_after_jump_scroll = 0
  let g:unite_split_rule = 'botright'
  " Commands
  "nnoremap <silent>[Space]j :Unite file_mru -direction=botright -toggle<CR>
  "nnoremap <silent>[Space]o :Unite outline  -direction=botright -toggle<CR>
  nnoremap <silent>[Space]o :Unite outline -vertical -winwidth=40 -toggle<CR>
  "nnoremap <silent>[Space]o :Unite outline -vertical -no-quit -winwidth=40 -toggle<CR>
  " Grep
  nnoremap <silent> ,g  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
  " Grep word on cursor
  nnoremap <silent> ,cg :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
  " Re-call grep results
  nnoremap <silent> ,r  :<C-u>UniteResume search-buffer<CR>

  if executable('pt')
    let g:unite_source_grep_command = 'pt'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor'
    let g:unite_source_grep_recursive_opt = ''
  elseif executable('ag')
    " Use ag in unite grep source.
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts =
          \ '--line-numbers --nocolor --nogroup --hidden --ignore ' .
          \  '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
    let g:unite_source_grep_recursive_opt = ''
  elseif executable('ack')
  elseif executable('jvgrep')
    " For jvgrep.
    let g:unite_source_grep_command = 'jvgrep'
    let g:unite_source_grep_default_opts = '--exclude ''\.(git|svn|hg|bzr)'''
    let g:unite_source_grep_recursive_opt = '-R'
  endif

  " Mappings

  call neobundle#untap()
endif

" Shougo/neocomplete {{{2
if s:neobundled('neocomplete.vim')
  call neobundle#config({
        \   "lazy" : 1,
        \   "autoload" : {
        \     "insert" : 1,
        \   },
        \   'disabled' : !has('lua'),
        \   'vim_version' : '7.3.885'
        \ })

  function! neobundle#tapped.hooks.on_source(bundle) "{{{
    " Use smartcase.
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#enable_camel_case = 1
    let g:neocomplete#enable_underbar_completion = 1

    " Use fuzzy completion.
    let g:neocomplete#enable_fuzzy_completion = 1

    " Set minimum syntax keyword length.
    let g:neocomplete#sources#syntax#min_keyword_length = 3
    " Set auto completion length.
    let g:neocomplete#auto_completion_start_length = 2
    " Set manual completion length.
    let g:neocomplete#manual_completion_start_length = 0
    " Set minimum keyword length.
    let g:neocomplete#min_keyword_length = 3

    " Set neosnippet competion length.
    "call neocomplete#custom#source('neosnippet', 'min_pattern_length', 1)

    let g:neocomplete#disable_auto_select_buffer_name_pattern =
    \ '\[Command Line\]'

    if !exists('g:neocomplete#force_omni_input_patterns')
      let g:neocomplete#force_omni_input_patterns = {}
    endif
    let g:jedi#auto_vim_configuration = 0
    let g:neocomplete#sources#omni#input_patterns = {
    \ 'ruby' : '[^. *\t]\.\w*\|\h\w*::',
    \}
    let g:neocomplete#force_omni_input_patterns = {
    \ 'python': '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
    \}
    " \ 'ruby' : '[^. *\t]\.\|\h\w*::',
    let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scala' : $HOME.'/.vim/myplugin/vim-scala-dict/dict/scala.dict',
    \ }
  endfunction
  "}}}

  " Options
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_ignore_case = 1
  let g:neocomplete#enable_smart_case = 1
  if !exists('g:neocomplete#keyword_patterns')
      let g:neocomplete#keyword_patterns = {}
  endif
  let g:neocomplete#keyword_patterns._ = '\h\w*'
  " Commands
  inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
  " Mappings

  " Other {{{
  "inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
  "inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
  "highlight Pmenu      ctermbg=lightcyan ctermfg=black
  "highlight PmenuSel   ctermbg=blue      ctermfg=black
  "highlight PmenuSbari ctermbg=darkgray
  "highlight PmenuThumb ctermbg=lightgray
  "}}}

  call neobundle#untap()
endif

" itchyny/lightline.vim {{{2
if s:neobundled('lightline.vim')
  let g:lightline = {
        \ 'colorscheme': 'solarized',
        \ 'mode_map': {'c': 'NORMAL'},
        \ 'active': {
        \   'left':  [ [ 'mode', 'paste' ], [ 'fugitive' ], [ 'filename' ] ],
        \   'right' : [ [ 'date' ], [ 'filetype', 'fileencoding', 'fileformat', 'lineinfo', 'percent' ], [ 'filepath' ] ],
        \ },
        \ 'component_function': {
        \   'modified': 'MyModified',
        \   'readonly': 'MyReadonly',
        \   'fugitive': 'MyFugitive',
        \   'filepath': 'MyFilepath',
        \   'filename': 'MyFilename',
        \   'fileformat': 'MyFileformat',
        \   'filetype': 'MyFiletype',
        \   'fileencoding': 'MyFileencoding',
        \   'mode': 'MyMode',
        \   'date': 'MyDate'
        \ }
        \ }

  function! MyDate()
    return strftime("%Y/%m/%d %H:%M")
  endfunction

  function! MyModified()
    return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
  endfunction

  function! MyReadonly()
    return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
  endfunction

  function! MyFilepath()
    return substitute(getcwd(), $HOME, '~', '')
  endfunction

  function! MyFilename()
    return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
          \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
          \  &ft == 'unite' ? unite#get_status_string() :
          \  &ft == 'vimshell' ? vimshell#get_status_string() :
          \ '' != expand('%:p:~') ? expand('%:p:~') : '[No Name]') .
          \ ('' != MyModified() ? ' ' . MyModified() : '')
  endfunction

  function! MyFugitive()
    try
      if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
        return fugitive#head()
      endif
    catch
    endtry
    return ''
  endfunction

  function! MyFileformat()
    return winwidth(0) > 70 ? &fileformat : ''
  endfunction

  function! MyFiletype()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'NONE') : ''
  endfunction

  function! MyFileencoding()
    return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
  endfunction

  function! MyMode()
    return winwidth(0) > 60 ? lightline#mode() : ''
  endfunction

  call neobundle#untap()
endif

" nathanaelkane/vim-indent-guides {{{2
if s:neobundled('vim-indent-guides')
  hi IndentGuidesOdd  ctermbg=DarkGreen
  hi IndentGuidesEven ctermbg=Black
  let g:indent_guides_enable_on_vim_startup = 0
  let g:indent_guides_start_level = 1
  let g:indent_guides_auto_colors = 0
  let g:indent_guides_guide_size = 1
endif

" tpope/vim-markdown {{{2
if s:neobundled('vim-markdown')
  call neobundle#config({
        \   "lazy" : 1,
        \   "autoload" : {
        \     "filetypes" : [ "markdown" ],
        \   }
        \ })

  " Options
  " Commands
  " Mappings

  call neobundle#untap()
endif

" tpope/vim-fugutive {{{2
if s:neobundled('vim-fugitive')
  call neobundle#config({
        \   "lazy" : 1,
        \   "autoload" : {
        \     "commands" : [
        \       "gstatus",
        \       "gcommit",
        \       "gwrite",
        \       "gdiff",
        \       "gblame",
        \       "git",
        \       "ggprep",
        \     ],
        \   }
        \ })

  " Options
  "nnoremap ;gs :<c-u>gstatus<cr>
  "nnoremap ;gc :<c-u>gcommit -v<cr>
  "nnoremap ;ga :<c-u>gwrite<cr>
  "nnoremap ;gd :<c-u>gdiff<cr>
  "nnoremap ;gb :<c-u>gblame<cr>
  " Commands
  " Mappings

  let s:bundle = neobundle#get('vim-fugitive')
  function! s:bundle.hooks.on_post_source(bundle)
    doautoall fugitive bufnewfile
  endfunction

  call neobundle#untap()
endif

" Misc: {{{1
" Experimental setup and settings that do not belong to any section
" will be described in this section.
"==============================================================================

" EXPERIMENTAL: Experimental code is described here

" MISC: Useful code that does not enter the section are described here

set fileencoding=japan
set fileencodings=iso-2022-jp,utf-8,euc-jp,ucs-2le,ucs-2,cp932

" __END__ {{{1
" Must be written at the last.  see :help 'secure'.
set secure

" vim:fdm=marker expandtab fdc=3 ft=vim ts=2 sw=2 sts=2:


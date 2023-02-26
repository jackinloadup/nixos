" Global
set mouse=a " Enable the mouse
highlight Normal guibg=none " set background to be terminals
" https://stackoverflow.com/questions/62702766/termguicolors-in-vim-makes-everything-black-and-white#62703167
set termguicolors " Render the colors correctly. Enable 24-bit true colors
set title " Show the filename in the window titlebar

" review gruvbox settings later for 256 color ect
" https://github.com/gruvbox-community/gruvbox/wiki/Terminal-specific
colorscheme gruvbox
"let g:context_nvim_no_redraw = 1
set background=dark

let g:airline_powerline_fonts = 1

" Searching
set ignorecase " Ignore case of searches
set smartcase " Ignore 'ignorecase' if search patter contains uppercase characters
set wrapscan " Searches wrap around end of file

" Right Column
set relativenumber " Relative line numbers
set number " Enable line numbers

" Scrolling
set sidescrolloff=3 " Start scrolling three columns before vertical border of window
set scrolloff=3 " Start scrolling three lines before horizontal border of window

" Buffer
syntax on
set cursorline " Highlight current line
set nowrap " Do not wrap lines
set list " Show tabs and spaces via listchars
if has("multi_byte")
        set listchars=eol:¶,tab:˾˾,trail:˽,extends:↦,precedes:↤,nbsp:˽
        "set listchars=eol:¶,tab:˾˾,trail:˽,extends:↦,precedes:↤,nbsp:˽,space:·
else
        set listchars=eol:$,tab:>-,trail:-,extends:>,precedes:<,nbsp:%
        "set listchars=eol:$,tab:>-,trail:-,extends:>,precedes:<,nbsp:%,space:·
endif

" Splits
"set splitbelow " New window goes below
"set splitright " New windows goes right
"set winminheight=0 " Allow splits to be reduced to a single line

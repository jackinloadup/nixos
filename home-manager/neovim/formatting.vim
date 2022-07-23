set textwidth=80 " A longer line will be broken after white space to get this width
set expandtab " Expand tabs to spaces

" :help fo-table
set formatoptions=
set formatoptions+=c " Format comments
set formatoptions+=r " Continue comments by default
set formatoptions+=o " Make comment when using o or O from comment line
set formatoptions+=/ " Used with 'o' dont make new comment if the comment doesn't start the line
set formatoptions+=q " Format comments with gq
set formatoptions+=n " Recognize numbered lists
set formatoptions+=2 " Use indent from 2nd line of a paragraph
set formatoptions+=l " Don't break lines that are already long
set formatoptions+=1 " Break before 1-letter words
set formatoptions+=j " Where it makes sense, remove a comment leader when joining lines

set formatexpr=v:lua.vim.lsp.formatexpr()

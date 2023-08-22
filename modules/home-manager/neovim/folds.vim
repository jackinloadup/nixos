" :help foldenable

set foldenable " Enable folding
"set foldcolumn=0 " Column to show folds
set foldlevel=2 " Folds with a higher level will be closed
"set foldmethod=syntax " Syntax are used to specify folds
set foldminlines=5 " Allow folding single lines
set foldnestmax=2 " Set max fold nesting level
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

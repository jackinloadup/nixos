" Set completeopt to have a better completion experience
" :help completeopt
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

" Avoid showing extra messages when using completion
" don't give |ins-completion-menu| messages.  For example,
"  "-- XXX completion (YYY)", "match 1 of 2", "The only match",
"  "Pattern not found", "Back at original", etc.
set shortmess+=c

{ config
, pkgs
, ...
}: {
  config = {
    home.packages = [
      # needed to compile treesitter plugins, somewhat guess but works
      pkgs.gcc # should be included automatically
      #pkgs.clang # can't have them both. some kind of namespace collision
    ];

    programs.nixvim = {

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      autoCmd = [
        {
          event = "VimEnter";
          command = "set nofoldenable";
          desc = "Unfold All";
        }
        {
          event = "BufWrite";
          command = "%s/\\s\\+$//e";
          desc = "Remove Whitespaces";
        }
        {
          event = "FileType";
          pattern = [ "markdown" "org" "norg" ];
          command = "setlocal conceallevel=2";
          desc = "Conceal Syntax Attribute";
        }
        {
          event = "FileType";
          pattern = [ "markdown" "org" "norg" ];
          command = "setlocal spell spelllang=en";
          desc = "Spell Checking";
        }
        # Broken, keeping as a reminder to fix
        #{
        #  event = "FileType";
        #  pattern = [ "markdown" "org" "norg" ];
        #  command = ":TableModeEnable";
        #  desc = "Table Mode";
        #}
        {
          event = "FileType";
          pattern = [ "markdown" ];
          command = "setlocal scrolloff=30";
          desc = "Fixed cursor location on markdown (for preview)";
        }
      ];


      opts = {
        hidden = true;
        shiftwidth = 2;
        tabstop = 2;
        softtabstop = 2;
        autoindent = true;
        sidescroll = 40;
        pumheight = 15;
        fileencoding = "utf-8";
        swapfile = false;
        timeoutlen = 2500;
        conceallevel = 3;
        # confirmed this is needed but I couldn't confirm if its working
        # nix-instantiate --eval -E 'builtins.readFile ./bar'
        #nofixendofline = true; # don't add newline to end of file


        ## Right Column
        relativenumber = true; # Relative line numbers
        number = true; # Enable line numbers

        ## Scrolling
        sidescrolloff = 3; # Start scrolling three columns before vertical border of window
        scrolloff = 3; # Start scrolling three lines before horizontal border of window

        ## Buffer
        #syntax on
        cursorline = true; # Highlight current line
        wrap = false; # Do not wrap lines
        list = true; # Show tabs and spaces via listchars
        #if has(#multi_byte#)
        #        set listchars=eol:¶,tab:˾˾,trail:˽,extends:↦,precedes:↤,nbsp:˽
        #        #set listchars=eol:¶,tab:˾˾,trail:˽,extends:↦,precedes:↤,nbsp:˽,space:·
        #else
        #        set listchars=eol:$,tab:>-,trail:-,extends:>,precedes:<,nbsp:%
        #        #set listchars=eol:$,tab:>-,trail:-,extends:>,precedes:<,nbsp:%,space:·
        #endif

        ## Splits
        ## Open new split panes to right and bottom, which feels more natural
        splitbelow = true; # New window goes below
        splitright = true; # New windows goes right
        winminheight = 0; # Allow splits to be reduced to a single line

        ## Wildmenu - commandline completion menu
        wildmenu = true;
        wildmode = "longest:full,full";

        ## Make pane navigation available in one keystroke
        #nnoremap <C-J> <C-W><C-J>
        #nnoremap <C-K> <C-W><C-K>
        #nnoremap <C-L> <C-W><C-L>
        #nnoremap <C-H> <C-W><C-H>
        #
        ## Center cursor on screen when moving half pages
        #nnoremap <C-d> <C-d>zz
        #nnoremap <C-u> <C-u>zz
        #
        ## Center cursor on screen when searching forward/backward
        #nnoremap n nzzzv
        #nnoremap N Nzzzv
        #
        #
        ## :help splits
        ##
        ##  Resizing splits
        ##
        ## Vim’s defaults are useful for changing split shapes:
        ##
        ## #Max out the height of the current split
        ## ctrl + w _
        ##
        ## #Max out the width of the current split
        ## ctrl + w |
        ##
        ## #Normalize all split sizes, which is very handy when resizing terminal
        ## ctrl + w =
        ##
        ## More split manipulation
        ##
        ## #Swap top/bottom or left/right split
        ## Ctrl+W R
        ##
        ## #Break out current window into a new tabview
        ## Ctrl+W T
        ##
        ## #Close every window in the current tabview but the current one
        ## Ctrl+W o

        ##################
        # User Interface
        ##################

        ##################
        # Formatting
        ##################
        textwidth = 80; # A longer line will be broken after white space to get this width
        expandtab = true; # Expand tabs to spaces

        ## :help fo-table
        #formatoptions=
        #formatoptions+=c # Format comments
        #formatoptions+=r # Continue comments by default
        #formatoptions+=o # Make comment when using o or O from comment line
        #formatoptions+=/ # Used with 'o' dont make new comment if the comment doesn't start the line
        #formatoptions+=q # Format comments with gq
        #formatoptions+=n # Recognize numbered lists
        #formatoptions+=2 # Use indent from 2nd line of a paragraph
        #formatoptions+=l # Don't break lines that are already long
        #formatoptions+=1 # Break before 1-letter words
        #formatoptions+=j # Where it makes sense, remove a comment leader when joining lines

        formatexpr = "v:lua.vim.lsp.formatexpr()";


        ##################
        # Completion
        ##################
        # Set completeopt to have a better completion experience
        # :help completeopt
        # menuone: popup even when there's only one match
        # noinsert: Do not insert text until a selection is made
        # noselect: Do not select, force user to select one from the menu
        completeopt = [ "menu" "menuone" "noselect" ];
        #
        # Avoid showing extra messages when using completion
        # don't give |ins-completion-menu| messages.  For example,
        #  "-- XXX completion (YYY)", "match 1 of 2", "The only match",
        #"  "Pattern not found", "Back at original", etc.
        #shortmess+=c

        ##################
        # Searching
        ##################
        ignorecase = true; # Ignore case of searches
        smartcase = true; # Ignore 'ignorecase' if search patter contains uppercase characters
        wrapscan = true; # Searches wrap around end of file

        # :help foldenable
        foldenable = true; # Enable folding
        #foldcolumn=0; # Column to show folds
        foldlevel = 2; # Folds with a higher level will be closed
        #foldmethod=syntax; # Syntax are used to specify folds
        foldminlines = 5; # Allow folding single lines
        foldnestmax = 2; # max fold nesting level
        foldmethod = "expr";
        foldexpr = "nvim_treesitter#foldexpr()";

        ##################
        # Spell Checking
        ##################
        spell = true;
        spelllang = "en_us";
      };

      clipboard = {
        register = "unnamedplus";
        providers.wl-copy.enable = true;
      };

      colorschemes.gruvbox.enable = true;
      #colorschemes.onedark = {
      #  enable = true;
      #  package = pkgs.vimPlugins.onedarkpro-nvim;
      #};

      globals = {
        mapleader = ";";
        maplocalleader = ";";
      };

      match = {
        ExtraWhitespace = "\\s\\+$";
      };

      plugins = {
        avante = {
          enable = true;
          settings = {
            debug = false;
            provider = "ollama";
            auto_suggestions_provider = "ollama";
            tokenizer = "tiktoken";
            system_prompt = ''
              You are an excellent programming expert.
            '';
            providers = {
              ollama = {
                endpoint = "http://ollama.home.lucasr.com:${toString config.services.ollama.port}";
                model = "codellama:latest";
                #model = "qwq:32b";
              };
              #openai = {
              #  endpoint = "https://api.openai.com/v1";
              #  model = "gpt-4o";
              #  timeout = 30000;
              #  temperature = 0;
              #  max_tokens = 4096;
              #};
              #copilot = {
              #  endpoint = "https://api.githubcopilot.com";
              #  model = "gpt-4o-2024-05-13";
              #  proxy = null;
              #  allow_insecure = false;
              #  timeout = 30000;
              #  temperature = 0;
              #  max_tokens = 4096;
              #};
              #azure = {
              #  endpoint = "";
              #  deployment = "";
              #  api_version = "2024-06-01";
              #  timeout = 30000;
              #  temperature = 0;
              #  max_tokens = 4096;
              #};
              #claude = {
              #  endpoint = "https://api.anthropic.com";
              #  model = "claude-3-5-sonnet-20240620";
              #  timeout = 30000;
              #  temperature = 0;
              #  max_tokens = 8000;
              #};
              #gemini = {
              #  endpoint = "https://generativelanguage.googleapis.com/v1beta/models";
              #  model = "gemini-1.5-flash-latest";
              #  timeout = 30000;
              #  temperature = 0;
              #  max_tokens = 4096;
              #};
              #cohere = {
              #  endpoint = "https://api.cohere.com/v1";
              #  model = "command-r-plus-08-2024";
              #  timeout = 30000;
              #  temperature = 0;
              #  max_tokens = 4096;
              #};
              #copilot = {
              #  endpoint = "https://api.githubcopilot.com";
              #  model = "gpt-4o-2024-05-13";
              #  proxy = null;
              #  allow_insecure = false;
              #  timeout = 30000;
              #  temperature = 0;
              #  max_tokens = 4096;
              #};
              #azure = {
              #  endpoint = "";
              #  deployment = "";
              #  api_version = "2024-06-01";
              #  timeout = 30000;
              #  temperature = 0;
              #  max_tokens = 4096;
              #};
              #claude = {
              #  endpoint = "https://api.anthropic.com";
              #  model = "claude-3-5-sonnet-20240620";
              #  timeout = 30000;
              #  temperature = 0;
              #  max_tokens = 8000;
              #};
              #gemini = {
              #  endpoint = "https://generativelanguage.googleapis.com/v1beta/models";
              #  model = "gemini-1.5-flash-latest";
              #  timeout = 30000;
              #  temperature = 0;
              #  max_tokens = 4096;
              #};
              #cohere = {
              #  endpoint = "https://api.cohere.com/v1";
              #  model = "command-r-plus-08-2024";
              #  timeout = 30000;
              #  temperature = 0;
              #  max_tokens = 4096;
              #};
            };
            vendors = { };
            behaviour = {
              auto_suggestions = false;
              auto_set_highlight_group = true;
              auto_set_keymaps = true;
              auto_apply_diff_after_generation = false;
              support_paste_from_clipboard = false;
            };
            history = {
              storage_path.__raw = "vim.fn.stdpath('state') .. '/avante'";
              paste = {
                extension = "png";
                filename = "pasted-%Y-%m-%d-%H-%M-%S";
              };
            };
            highlights = {
              diff = {
                current = "DiffText";
                incoming = "DiffAdd";
              };
            };
            mappings = {
              diff = {
                ours = "co";
                theirs = "ct";
                all_theirs = "ca";
                both = "cb";
                cursor = "cc";
                next = "]x";
                prev = "[x";
              };
              suggestion = {
                accept = "<M-l>";
                next = "<M-]>";
                prev = "<M-[>";
                dismiss = "<C-]>";
              };
              jump = {
                next = "]]";
                prev = "[[";
              };
              submit = {
                normal = "<CR>";
                insert = "<C-s>";
              };
              ask = "<leader>aa";
              edit = "<leader>ae";
              refresh = "<leader>ar";
              toggle = {
                default = "<leader>at";
                debug = "<leader>ad";
                hint = "<leader>ah";
                suggestion = "<leader>as";
              };
              sidebar = {
                switch_windows = "<Tab>";
                reverse_switch_windows = "<S-Tab>";
              };
            };
            windows = {
              position = "right";
              wrap = true;
              width = 30;
              height = 30;
              sidebar_header = {
                align = "center";
                rounded = true;
              };
              input = {
                prefix = "> ";
              };
              edit = {
                border = "rounded";
              };
            };
            diff = {
              autojump = true;
            };
            hints = {
              enabled = true;
            };
          };
        };

        # buffer tabbar. didn't end up liking this.
        #barbar.enable = true;

        #cmp-treesitter.enable = true;
        #cmp-path.enable = true;
        #cmp-spell.enable = true;
        #cmp-nvim-lua.enable = true;
        ##cmp-nvim-lsp.enable = true;
        #cmp_luasnip.enable = true;
        ##cmp-dap.enable = true; # not sure how dap is integrated and used

        #copilot-cmp.enable = true;
        #cmp-ai.enable = true;
        comment.enable = true;

        fugitive.enable = true;
        gitgutter.enable = true;

        indent-blankline = {
          enable = true;
          settings.scope.enabled = true;
        };

        lastplace.enable = true;
        lightline.enable = true;
        lsp-lines.enable = true;

        lsp = {
          enable = true;
          servers = {
            nixd.enable = true;
            rust_analyzer = {
              enable = true;
              installCargo = true;
              installRustc = true;
            };
            lua_ls.enable = true;
            ts_ls.enable = true; # typescript
            html.enable = false; # failing
            cssls.enable = false; # failing
            pyright.enable = false;
            java_language_server.enable = true;
          };
        };

        lualine.enable = true;
        markdown-preview.enable = true;

        neogit.enable = true;
        neo-tree = {
          enable = true;
          settings = {
            window.width = 30;
            closeIfLastWindow = true;
            extraOptions = {
              filesystem = {
                filtered_items = {
                  visible = true;
                };
              };
            };
          };
        };

        nix.enable = true;
        nvim-autopairs.enable = true;
        numbertoggle.enable = true;

        web-devicons.enable = true;
        telescope = {
          enable = true;
          settings = {
            pickers.find_files = {
              hidden = true;
            };
          };
          keymaps = {
            "<leader>ff" = "find_files";
            "<leader>fg" = "live_grep";
            "<leader>fb" = "buffers";
            "<leader>fh" = "help_tags";
          };
        };

        tmux-navigator.enable = true;
        #rustaceanvim.enable = true;

        treesitter = {
          enable = true;
          #lazyLoad.enable = true;
          nixvimInjections = true;
          folding = false;
          nixGrammars = true;
          settings = {
            # breaks pre-compiled from nixGrammers
            #ensure_installed = "all";
            indent.enable = true;
            incremental_selection.enable = true;
          };
        };

        treesitter-refactor = {
          enable = true;
        };

        undotree = {
          enable = true;
          settings = {
            FocusOnToggle = true;
            HighlightChangedText = true;
          };
        };
      };


      keymaps = [
        {
          key = "<C-s>";
          action = "<CMD>w<CR>";
          options.desc = "Save";
        }
        {
          key = "<leader>s";
          action = "<CMD>w<CR>";
          options.desc = "Save";
        }
        {
          key = "<leader>q";
          action = "<CMD>q<CR>";
          options.desc = "quit";
        }
        {
          key = "<F2>";
          action = "<CMD>Neotree toggle<CR>";
          options.desc = "Toggle NeoTree";
        }
        {
          key = "<leader>e";
          action = "<CMD>Neotree toggle<CR>";
          options.desc = "Toggle NeoTree";
        }
        {
          key = "<leader>fs";
          action = "<CMD>Neotree toggle<CR>";
          options.desc = "Toggle NeoTree";
        }
        {
          key = "<F3>";
          action = "<CMD>UndotreeToggle<CR>";
          options.desc = "Toggle Undotree";
        }
        {
          key = "<leader>sh";
          action = "<C-w>s";
          options.desc = "Split Horizontal";
        }
        {
          key = "<leader>sv";
          action = "<C-w>v";
          options.desc = "Split Vertical";
        }
        {
          key = "<leader><Left>";
          action = "<C-w>h";
          options.desc = "Select Window Left";
        }
        {
          key = "<leader>h";
          action = "<C-w>h";
          options.desc = "Select Window Left";
        }
        {
          key = "<leader><Right>";
          action = "<C-w>l";
          options.desc = "Select Window Right";
        }
        {
          key = "<leader>l";
          action = "<C-w>l";
          options.desc = "Select Window Right";
        }
        {
          key = "<leader><Down>";
          action = "<C-w>j";
          options.desc = "Select Window Below";
        }
        {
          key = "<leader>j";
          action = "<C-w>j";
          options.desc = "Select Window Below";
        }
        {
          key = "<leader><Up>";
          action = "<C-w>k";
          options.desc = "Select Window Above";
        }
        {
          key = "<leader>k";
          action = "<C-w>k";
          options.desc = "Select Window Above";
        }
        {
          key = "<leader>t";
          action = "<C-w>w";
          options.desc = "Cycle Between Windows";
        }
        # Not an editor command
        #{
        #  key = "<leader>bb";
        #  action = "<CMD>BufferPick<CR>";
        #  options.desc = "View Open Buffer";
        #}
        #{
        #  key = "<leader>bc";
        #  action = "<CMD>BufferClose<CR>";
        #  options.desc = "View Open Buffer";
        #}
        #{
        #  key = "<leader>bn";
        #  action = "<CMD>:bnext<CR>";
        #  options.desc = "Next Buffer";
        #}
        #{
        #  key = "<leader>bp";
        #  action = "<CMD>:bprev<CR>";
        #  options.desc = "Previous Buffer";
        #}
        {
          mode = "v";
          key = "<";
          action = "<gv";
          options.desc = "Tab Text Right";
        }
        {
          mode = "v";
          key = ">";
          action = ">gv";
          options.desc = "Tab Text Left";
        }
        {
          mode = "n";
          key = "<C-/>";
          action = "<Plug>(comment_toggle_linewise_current)";
          options.desc = "(Un)comment in Normal Mode";
        }
        {
          mode = "v";
          key = "<C-/>";
          action = "<Plug>(comment_toggle_linewise_visual)";
          options.desc = "(Un)comment in Visual Mode";
        }
        {
          mode = "n";
          key = "<C-S-/>";
          action = "<Plug>(comment_toggle_blockwise_current)";
          options.desc = "(Un)comment in Normal Mode";
        }
        {
          mode = "v";
          key = "<C-S-/>";
          action = "<Plug>(comment_toggle_blockwise_visual)";
          options.desc = "(Un)comment in Visual Mode";
        }
        {
          mode = "n";
          key = "gd";
          action = "<CMD>lua vim.lsp.buf.hover()<CR>";
        }
        {
          mode = "n";
          key = "gD";
          action = "<CMD>lua vim.lsp.buf.definition()<CR>";
        }
        {
          mode = "n";
          key = "gr";
          action = "<CMD>lua vim.lsp.buf.references()<CR>";
        }
        {
          mode = "n";
          key = "ga";
          action = "<CMD>lua vim.lsp.buf.code_action()<CR>";
        }
        {
          mode = "n";
          key = "ge";
          action = "<CMD>lua vim.diagnostic.open_float()<CR>";
        }
        {
          mode = "n";
          key = "<leader>gi";
          action = "<cmd>Neogit<cr>";
        }
        {
          mode = "n";
          key = "<leader>r";
          action = ":! ";
        }
        {
          mode = "n";
          key = "<leader>z";
          action.__raw = ''
            function()
              if vim.t.zoomed then
                vim.cmd('tabclose')
              else
                vim.cmd('tab split')
                vim.t.zoomed = true
              end
            end
          '';
          options = {
            desc = "Toggle zoom";
            silent = true;
          };
        }
      ];
    };
  };
}

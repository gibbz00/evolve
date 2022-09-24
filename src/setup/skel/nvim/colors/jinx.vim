"    ------------------- jinx ----------------------     "
"       Written by Nathaniel Maia, December 2017         "
"    -----------------------------------------------     "
" vim:fdm=marker

" ---------- Setup and Checks ----------- " {{{1

if exists('syntax_on')
	highlight clear
	syntax reset
endif

let g:colors_name = 'jinx'

" Colors {{{1

" empty color dictionary
let s:jinx = {}

" NOTE: For those looking to edit the theme
"
" Color definition is done for both true color
" and 256 color. The format is in ['HEX', 256color, 16color]
"
" let s:jinx.black = ['#000000', 0, 0]

" completion menu, wildmenu, and status/tab lines
let s:jinx.menu_bgr    = ['#050505', 238, 8]
let s:jinx.menu_fgr    = ['#808080', 102, 15]
let s:jinx.menusel_bgr = ['#1F2326', 235, 0]
let s:jinx.menusel_fgr = ['#E1E1E1', 251, 7]
let s:jinx.menualt_fgr = ['#E1E1E1', 251, 7]
let s:jinx.menualt_bgr = ['#37383D', 237, 0]
let s:jinx.tabsel_bgr  = ['#8DBC8D', 108, 2]

" terminal colours for :terminal {{{

let g:terminal_ansi_colors = [
            \ '#4D545E', '#FF777A', '#8DBC8D', '#FFEB56', '#6699CC', '#CC99CC', '#5DD5FF', '#E1E1E1',
            \ '#4D545E', '#FF777A', '#8DBC8D', '#FFEB56', '#6699CC', '#CC99CC', '#5DD5FF', '#E1E1E1'
            \ ]
let s:i = 0
for s:color in g:terminal_ansi_colors
    let g:terminal_color_{s:i} = s:color
    let s:i += 1
endfor

"}}}

" background, foreground, line, visual selection, folds,
" and comments as well as standard 1-7 colors: red, green,
" yellow, blue, purple, cyan, and orange (instead of white)
if exists('g:jinx_colors') && g:jinx_colors =~? 'day' "{{{
    set background=light
    let s:jinx.fgr    = ['#050505', 238, 0]
    let s:jinx.bgr    = ['#E1E1E1', 254, 7]
    let s:jinx.line   = ['#D0D0D0', 252, 15]
    let s:jinx.select = ['#D0D0D0', 252, 15]
    let s:jinx.folded = ['#B2B2B2', 249, 15]
    let s:jinx.commnt = ['#808080', 244, 15]

    let s:jinx.red    = ['#EF7878', 210, 1]
    let s:jinx.green  = ['#78A078', 108, 2]
    let s:jinx.yellow = ['#CE9D00', 178, 3]
    let s:jinx.blue   = ['#4E88CF',  32, 4]
    let s:jinx.purple = ['#AF86C8', 140, 5]
    let s:jinx.cyan   = ['#00AFAF',  37, 6]
    let s:jinx.orange = ['#E0914C', 166, 9]

    let g:terminal_color_1 = '#EF7878'
    let g:terminal_color_2 = '#78A078'
    let g:terminal_color_3 = '#CE9D00'
    let g:terminal_color_4 = '#4E88CF'
    let g:terminal_color_5 = '#AF86C8'
    let g:terminal_color_6 = '#00AFAF'
    let g:terminal_color_9  = '#FF777A'
    let g:terminal_color_10 = '#8DBC8D'
    let g:terminal_color_11 = '#FFEB56'
    let g:terminal_color_12 = '#6699CC'
    let g:terminal_color_13 = '#CC99CC'
    let g:terminal_color_14 = '#5DD5FF'
    let g:terminal_ansi_colors = [
                \ '#E1E1E1', '#EF7878', '#78A078', '#CE9D00', '#4E88CF', '#AF86C8', '#00AFAF', '#4D545E',
                \ '#E1E1E1', '#FF777A', '#8DBC8D', '#FFEB56', '#6699CC', '#CC99CC', '#5DD5FF', '#4D545E'
                \ ]
    let s:i = 0
    for s:color in g:terminal_ansi_colors
        let g:terminal_color_{s:i} = s:color
        let s:i += 1
    endfor

elseif exists('g:jinx_colors') && g:jinx_colors =~? 'midnight'
    let s:jinx.menu_bgr    = ['#2c3135', 237, 0]

    set background=dark
    let s:jinx.fgr    = ['#E1E1E1', 253, 7]
    let s:jinx.bgr    = ['#1E2125', 234, 0]
    let s:jinx.line   = ['#2c3135', 237, 15]
    let s:jinx.select = ['#2c3135', 237, 15]
    let s:jinx.folded = ['#414449', 240, 15]
    let s:jinx.commnt = ['#B9B9B9', 102, 15]

    let s:jinx.red    = ['#FF777A', 210, 1]
    let s:jinx.green  = ['#8DBC8D', 108, 2]
    let s:jinx.yellow = ['#FFEB56', 220, 3]
    let s:jinx.blue   = ['#6699CC',  32, 4]
    let s:jinx.purple = ['#CC99CC', 140, 5]
    let s:jinx.cyan   = ['#5DD5FF',  81, 6]
    let s:jinx.orange = ['#FF9157', 208, 9]

else
    " night
    set background=dark
    let s:jinx.fgr    = ['#E1E1E1', 254, 7]
    let s:jinx.bgr    = ['#4D545E', 237, 0]
    let s:jinx.line   = ['#5F6772', 243, 8]
    let s:jinx.select = ['#5F6772', 243, 1]
    let s:jinx.folded = ['#414449', 239, 8]
    let s:jinx.commnt = ['#B9B9B9', 250, 8]

    let s:jinx.red    = ['#FF777A', 210, 1]
    let s:jinx.green  = ['#8DBC8D', 108, 2]
    let s:jinx.yellow = ['#FFEB56', 220, 3]
    let s:jinx.blue   = ['#6699CC',  32, 4]
    let s:jinx.purple = ['#CC99CC', 140, 5]
    let s:jinx.cyan   = ['#5DD5FF',  81, 6]
    let s:jinx.orange = ['#FF9157', 208, 9]

endif "}}}

function! <SID>HighLight(GRP, FG, BG, ATT) abort  " {{{1
    if a:FG !=# ''
        let l:fg_col  = get(s:jinx, a:FG)
        let l:fg_true = l:fg_col[0]
        if $TERM =~? 'linux' || &t_Co < 256
            let l:fg_term = l:fg_col[2]
        else
            let l:fg_term = l:fg_col[1]
        endif
        exec 'highlight! '.a:GRP.' guifg='.l:fg_true.' ctermfg='.l:fg_term
    endif
    if a:BG !=# ''
        let l:bg_col  = get(s:jinx, a:BG)
        let l:bg_true = l:bg_col[0]
        if $TERM =~? 'linux' ||  &t_Co < 256
            let l:bg_term = l:bg_col[2]
        else
            let l:bg_term = l:bg_col[1]
        endif
        exec 'highlight! '.a:GRP.' guibg='.l:bg_true.' ctermbg='.l:bg_term
    endif
    if a:ATT !=# '' && &t_Co >= 256
        exec 'highlight! '.a:GRP.' gui='.a:ATT.' cterm='.a:ATT
    endif
endfunction


" ---------- Highlight Groups ------------ " {{{1

" Editor {{{2

call <SID>HighLight('Title',       'commnt',    'bgr',  'bold')
call <SID>HighLight('Visual',       '',         'select',   '')
call <SID>HighLight('SignColumn',   '',         'line',     '')
call <SID>HighLight('CursorLine',   '',         'line', 'none')
call <SID>HighLight('CursorColumn', '',         'line',     '')
call <SID>HighLight('CursorLineNr', 'cyan',     'line',     '')
call <SID>HighLight('LineNr',       'commnt',   'line',     '')
call <SID>HighLight('ColorColumn',  'fgr',      'red',      '')
call <SID>HighLight('Error',        'red',      'bgr',      '')
call <SID>HighLight('ErrorMsg',     'red',      'bgr',      '')
call <SID>HighLight('WarningMsg',   'red',      'bgr',      '')
call <SID>HighLight('MatchParen',   'yellow',   'bgr',  'bold')
call <SID>HighLight('ModeMsg',      'cyan',     'bgr',      '')
call <SID>HighLight('MoreMsg',      'cyan',     'bgr',      '')
call <SID>HighLight('Directory',    'blue',     'bgr',      '')
call <SID>HighLight('Question',     'green',    'bgr',      '')
call <SID>HighLight('NonText',      'commnt',   'bgr',      '')
call <SID>HighLight('SpecialKey',   'commnt',   'bgr',      '')
call <SID>HighLight('Folded',       'commnt',   'folded',   '')
call <SID>HighLight('Search',       'bgr',      'blue',     '')
call <SID>HighLight('HLNext',       'bgr',      'red',  'bold')
call <SID>HighLight('Normal',       'fgr',      'bgr',      '')
call <SID>HighLight('VertSplit',    'menu_bgr', 'menu_fgr', '')

" Tabline {{{2

call <SID>HighLight('TabLine',      'menusel_fgr', 'menu_bgr',    'none')
call <SID>HighLight('TabLineFill',  'menu_bgr',    'menu_bgr',        '')
call <SID>HighLight('TabLineSel',   'menu_bgr',    'tabsel_bgr',  'bold')
call <SID>HighLight('WildMenu',     'menusel_fgr', 'menu_bgr',    'bold')
call <SID>HighLight('Pmenu',        'menusel_fgr', 'menu_bgr',    'bold')
call <SID>HighLight('PmenuSel',     'menusel_bgr', 'menusel_fgr', 'bold')
call <SID>HighLight('PmenuSbar',    'menu_fgr',    'menu_bgr',        '')
call <SID>HighLight('PmenuThumb',   'menu_fgr',    'menu_bgr',        '')
call <SID>HighLight('StatusLine',   'menu_bgr',    'menusel_fgr',     '')
call <SID>HighLight('StatusLineNC', 'menu_bgr',    'menu_fgr',        '')

" Spelling {{{2
call <SID>HighLight('SpellBad',   '', '', 'underline')
call <SID>HighLight('SpellLocal', '', '', 'underline')
call <SID>HighLight('SpellRare',  '', '', 'underline')

" Ctrl-P {{{2
call <SID>HighLight('CtrlPNoEntries', 'red',      '',         'bold')
call <SID>HighLight('CtrlPMatch',     'blue',     '',         'bold')
call <SID>HighLight('CtrlPLinePre',   'blue',     'menu_bgr', 'none')
call <SID>HighLight('CtrlPPrtBase',   'blue',     '',         'none')
call <SID>HighLight('CtrlPPrtCursor', 'menu_fgr', 'menu_bgr', 'bold')
call <SID>HighLight('CtrlPMode1',     'menu_fgr', 'menu_bgr', 'bold')
call <SID>HighLight('CtrlPMode2',     'menu_fgr', 'menu_bgr', 'bold')
call <SID>HighLight('CtrlPStats',     'menu_fgr', 'menu_bgr', 'bold')

" ALE linter {{{2

call <SID>HighLight('ALEErrorSign',    'red',    'line',  '')
call <SID>HighLight('ALEWarningSign',  'orange', 'line',  '')
call <SID>HighLight('ALEError',        'red',    '',      'underline')
call <SID>HighLight('ALEWarning',      'red',    '',      'underline')
call <SID>HighLight('ALEStyleError',   'orange', '',      'underline')
call <SID>HighLight('ALEStyleWarning', 'orange', '',      'underline')

" Generic {{{2

call <SID>HighLight('Comment',      'commnt',  '',    '')
call <SID>HighLight('Todo',         'red',     'bgr', 'bold')
call <SID>HighLight('Float',        'cyan',    '',    '')
call <SID>HighLight('Character',    'cyan',    '',    '')
call <SID>HighLight('String',       'cyan',    '',    '')
call <SID>HighLight('Number',       'cyan',    '',    'bold')
call <SID>HighLight('Boolean',      'cyan',    '',    'bold')
call <SID>HighLight('Exception',    'blue',    '',    'bold')
call <SID>HighLight('Include',      'blue',    '',    '')
call <SID>HighLight('Operator',     'blue',    '',    'bold')
call <SID>HighLight('Label',        'green',   '',    '')
call <SID>HighLight('Repeat',       'green',   '',    '')
call <SID>HighLight('Statement',    'green',   '',    '')
call <SID>HighLight('Conditional',  'green',   '',    '')
call <SID>HighLight('Keyword',      'green',   '',    'bold')
call <SID>HighLight('Structure',    'purple',  '',    'bold')
call <SID>HighLight('StorageClass', 'purple',  '',    'bold')
call <SID>HighLight('Type',         'purple',  '',    'bold')
call <SID>HighLight('Tag',          'purple',  '',    'bold')
call <SID>HighLight('Macro',        'purple',  '',    'bold')
call <SID>HighLight('Special',      'purple',  '',    'bold')
call <SID>HighLight('TypeDef',      'purple',  '',    'bold')
call <SID>HighLight('Define',       'yellow',  '',    'bold')
call <SID>HighLight('Constant',     'purple',  '',    'bold')
call <SID>HighLight('PreProc',      'yellow',  '',    '')
call <SID>HighLight('Identifier',   'yellow',  '',    'bold')
call <SID>HighLight('PreCondit',    'yellow',  '',    '')
call <SID>HighLight('Function',     'orange',  '',    'bold')
call <SID>HighLight('Conceal',      'orange',  '',    '')

" Vim {{{2

call <SID>HighLight('vimCommand',     'green',  '', 'bold')
call <SID>HighLight('vimVar',         'yellow', '', 'bold')
call <SID>HighLight('vimGroup',       'yellow', '', 'bold')
call <SID>HighLight('vimGroupName',   'yellow', '', 'bold')
call <SID>HighLight('VimFunction',    'orange', '', 'bold')
call <SID>HighLight('VimFunctionKey', 'orange', '', 'bold')
call <SID>HighLight('vimMapModKey',   'purple', '', 'bold')
call <SID>HighLight('vimBracket',     'purple', '', 'bold')
call <SID>HighLight('vimOption',      'purple', '', 'bold')
call <SID>HighLight('vimMapMod',      'purple', '', '')
call <SID>HighLight('vimNotation',    'purple', '', '')

" Shell {{{2

call <SID>HighLight('shSet',          'green',  '', 'bold')
call <SID>HighLight('shLoop',         'green',  '', 'bold')
call <SID>HighLight('shTestOpr',      'green',  '', 'bold')
call <SID>HighLight('shConstant',     'yellow', '', 'bold')
call <SID>HighLight('shFunctionKey',  'orange', '', 'bold')
call <SID>HighLight('shStatement',    'green',  '', 'bold')
call <SID>HighLight('shKeyword',      'purple', '', 'bold')
call <SID>HighLight('zshStatement',   'green',  '', 'bold')
call <SID>HighLight('zshOption',      'green',  '', 'bold')
call <SID>HighLight('zshFunction',    'orange', '', 'bold')
call <SID>HighLight('zshVariableDef', 'yellow', '', '')
call <SID>HighLight('zshOperator',    'blue',   '', 'bold')

" C {{{2

call <SID>HighLight('cConditional',  'green',  '', '')
call <SID>HighLight('cRepeat',       'purple', '', '')
call <SID>HighLight('cStorageClass', 'purple', '', '')
call <SID>HighLight('cType',         'yellow', '', '')

" PHP {{{2

call <SID>HighLight('phpMemberSelector', 'blue',   '', '')
call <SID>HighLight('phpVarSelector',    'red',    '', '')
call <SID>HighLight('phpConditional',    'green',  '', '')
call <SID>HighLight('phpStatement',      'green',  '', 'bold')
call <SID>HighLight('phpKeyword',        'purple', '', 'bold')
call <SID>HighLight('phpRepeat',         'purple', '', '')

" Ruby {{{2

call <SID>HighLight('rubyInclude',                'blue',   '', '')
call <SID>HighLight('rubyAttribute',              'blue',   '', '')
call <SID>HighLight('rubySymbol',                 'green',  '', '')
call <SID>HighLight('rubyStringDelimiter',        'green',  '', '')
call <SID>HighLight('rubyRepeat',                 'purple', '', '')
call <SID>HighLight('rubyControl',                'purple', '', '')
call <SID>HighLight('rubyConditional',            'purple', '', '')
call <SID>HighLight('rubyException',              'purple', '', '')
call <SID>HighLight('rubyCurlyBlock',             'orange', '', '')
call <SID>HighLight('rubyLocalVariableOrMethod',  'orange', '', '')
call <SID>HighLight('rubyInterpolationDelimiter', 'orange', '', '')
call <SID>HighLight('rubyAccess',                 'yellow', '', '')
call <SID>HighLight('rubyConstant',               'yellow', '', '')

" Python {{{2

call <SID>HighLight('pythonRun',             'red',    '', '')
call <SID>HighLight('pythonOperator',        'blue',   '', 'bold')
call <SID>HighLight('pythonClass',           'blue',   '', '')
call <SID>HighLight('pythonClassParameters', 'purple', '', '')
call <SID>HighLight('pythonParam',           'purple', '', '')
call <SID>HighLight('pythonDecorator',       'blue',   '', 'bold')
call <SID>HighLight('pythonExClass',         'blue',   '', '')
call <SID>HighLight('pythonException',       'blue',   '', 'bold')
call <SID>HighLight('pythonExceptions',      'blue',   '', 'bold')
call <SID>HighLight('pythonBrackets',        'blue',   '', '')
call <SID>HighLight('pythonEscape',          'blue',   '', '')
call <SID>HighLight('pythonImport',          'green',  '', 'bold')
call <SID>HighLight('pythonRepeat',          'green',  '', '')
call <SID>HighLight('pythonCoding',          'green',  '', '')
call <SID>HighLight('pythonInclude',         'green',  '', 'bold')
call <SID>HighLight('pythonPreCondit',       'green',  '', '')
call <SID>HighLight('pythonStatement',       'green',  '', 'bold')
call <SID>HighLight('pythonConditional',     'green',  '', '')
call <SID>HighLight('pythonDef',             'yellow', '', 'bold')
call <SID>HighLight('pythonSelf',            'blue',   '', 'bold')
call <SID>HighLight('pythonBuiltinType',     'purple', '', 'bold')
call <SID>HighLight('pythonBuiltin',         'purple', '', 'bold')
call <SID>HighLight('pythonBuiltinObj',      'purple', '', 'bold')
call <SID>HighLight('pythonBuiltinFunc',     'orange', '', 'bold')
call <SID>HighLight('pythonDot',             'orange', '', 'bold')
call <SID>HighLight('pythonLambda',          'orange', '', '')
call <SID>HighLight('pythonLambdaExpr',      'orange', '', '')
call <SID>HighLight('pythonFunction',        'orange', '', 'bold')
call <SID>HighLight('pythonDottedName',      'orange', '', '')
call <SID>HighLight('pythonBuiltinObjs',     'orange', '', '')

" LaTeX {{{2

call <SID>HighLight('texZone',        'red',    '', 'none')
call <SID>HighLight('texStatement',   'blue',   '', 'none')
call <SID>HighLight('texRefLabel',    'blue',   '', 'none')
call <SID>HighLight('texRefZone',     'green',  '', 'none')
call <SID>HighLight('texMath',        'orange', '', 'none')
call <SID>HighLight('texMathZoneX',   'orange', '', 'none')
call <SID>HighLight('texMathZoneA',   'orange', '', 'none')
call <SID>HighLight('texMathZoneB',   'orange', '', 'none')
call <SID>HighLight('texMathZoneC',   'orange', '', 'none')
call <SID>HighLight('texMathZoneD',   'orange', '', 'none')
call <SID>HighLight('texMathZoneE',   'orange', '', 'none')
call <SID>HighLight('texMathMatcher', 'orange', '', 'none')
call <SID>HighLight('texDelimiter',   'purple', '', 'none')
call <SID>HighLight('texComment',     'commnt', '', 'none')

" JavaScript {{{2

call <SID>HighLight('javaScriptNumber',      'cyan',   '', 'bold')
call <SID>HighLight('javascriptNull',        'red',    '', 'bold')
call <SID>HighLight('javascriptStatement',   'green',  '', '')
call <SID>HighLight('javaScriptConditional', 'green',  '', '')
call <SID>HighLight('javaScriptRepeat',      'purple', '', '')
call <SID>HighLight('javaScriptBraces',      'purple', '', 'bold')
call <SID>HighLight('javascriptGlobal',      'yellow', '', 'bold')
call <SID>HighLight('javaScriptFunction',    'orange', '', 'bold')
call <SID>HighLight('javaScriptMember',      'orange', '', 'bold')

" HTML {{{2

call <SID>HighLight('htmlTag',       'red',    '', '')
call <SID>HighLight('htmlTagName',   'red',    '', 'bold')
call <SID>HighLight('htmlLink',      'blue',   '', 'bold')
call <SID>HighLight('htmlArg',       'green',  '', 'bold')
call <SID>HighLight('htmlScriptTag', 'purple', '', 'bold')
call <SID>HighLight('htmlTitle',     'blue',   '', 'bold')
call <SID>HighLight('htmlH1',        'blue',   '', 'bold')
call <SID>HighLight('htmlH2',        'cyan',   '', '')
call <SID>HighLight('htmlH3',        'cyan',   '', '')
call <SID>HighLight('htmlH4',        'green',  '', '')
call <SID>HighLight('htmlH5',        'green',  '', '')

" YAML {{{2

call <SID>HighLight('yamlKey',            'red',   '', '')
call <SID>HighLight('yamlAnchor',         'red',   '', '')
call <SID>HighLight('yamlAlias',          'blue',  '', '')
call <SID>HighLight('yamlDocumentHeader', 'green', '', '')

" Markdown {{{2

call <SID>HighLight('markdownHeadingRule',       'red',    '', '')
call <SID>HighLight('markdownHeadingDelimiter',  'red',    '', '')
call <SID>HighLight('markdownListMarker',        'blue',   '', '')
call <SID>HighLight('markdownOrderedListMarker', 'blue',   '', '')
call <SID>HighLight('markdownCode',              'purple', '', '')
call <SID>HighLight('markdownCodeBlock',         'purple', '', 'bold')
call <SID>HighLight('markdownCodeDelimiter',     'orange', '', 'bold')
call <SID>HighLight('markdownH1',                'blue',   '', 'bold')
call <SID>HighLight('markdownH2',                'blue',   '', 'bold')
call <SID>HighLight('markdownH3',                'cyan',   '', '')
call <SID>HighLight('markdownH4',                'cyan',   '', '')
call <SID>HighLight('markdownH5',                'green',  '', '')

" ShowMarks {{{2

call <SID>HighLight('ShowMarksHLm', 'cyan',   '', '')
call <SID>HighLight('ShowMarksHLl', 'orange', '', '')
call <SID>HighLight('ShowMarksHLo', 'purple', '', '')
call <SID>HighLight('ShowMarksHLu', 'yellow', '', '')

" Lua {{{2

call <SID>HighLight('luaRepeat',     'purple', '', '')
call <SID>HighLight('luaStatement',  'purple', '', '')
call <SID>HighLight('luaCond',       'green',  '', '')
call <SID>HighLight('luaCondEnd',    'green',  '', '')
call <SID>HighLight('luaCondStart',  'green',  '', '')
call <SID>HighLight('luaCondElseif', 'green',  '', '')

" Go {{{2

call <SID>HighLight('goDeclType',    'blue',   '', '')
call <SID>HighLight('goLabel',       'purple', '', '')
call <SID>HighLight('goRepeat',      'purple', '', '')
call <SID>HighLight('goBuiltins',    'purple', '', '')
call <SID>HighLight('goStatement',   'purple', '', '')
call <SID>HighLight('goDirective',   'purple', '', '')
call <SID>HighLight('goDeclaration', 'purple', '', '')
call <SID>HighLight('goConditional', 'purple', '', '')
call <SID>HighLight('goTodo',        'yellow', '', '')
call <SID>HighLight('goConstants',   'orange', '', '')

" Clojure {{{2

call <SID>HighLight('clojureException', 'red',    '', '')
call <SID>HighLight('clojureParen',     'cyan',   '', '')
call <SID>HighLight('clojureCond',      'blue',   '', '')
call <SID>HighLight('clojureFunc',      'blue',   '', '')
call <SID>HighLight('clojureMeta',      'blue',   '', '')
call <SID>HighLight('clojureMacro',     'blue',   '', '')
call <SID>HighLight('clojureDeref',     'blue',   '', '')
call <SID>HighLight('clojureQuote',     'blue',   '', '')
call <SID>HighLight('clojureRepeat',    'blue',   '', '')
call <SID>HighLight('clojureRepeat',    'blue',   '', '')
call <SID>HighLight('clojureUnquote',   'blue',   '', '')
call <SID>HighLight('clojureAnonArg',   'blue',   '', '')
call <SID>HighLight('clojureDispatch',  'blue',   '', '')
call <SID>HighLight('clojureString',    'green',  '', '')
call <SID>HighLight('clojureRegexp',    'green',  '', '')
call <SID>HighLight('clojureKeyword',   'green',  '', '')
call <SID>HighLight('clojureDefine',    'purple', '', '')
call <SID>HighLight('clojureSpecial',   'purple', '', '')
call <SID>HighLight('clojureVariable',  'yellow', '', '')
call <SID>HighLight('clojureBoolean',   'orange', '', '')
call <SID>HighLight('clojureNumber',    'orange', '', '')
call <SID>HighLight('clojureConstant',  'orange', '', '')
call <SID>HighLight('clojureCharacter', 'orange', '', '')

" Scala {{{2

call <SID>HighLight('scalaPackage',         'red',    '', '')
call <SID>HighLight('scalaVar',             'cyan',   '', '')
call <SID>HighLight('scalaDefName',         'blue',   '', '')
call <SID>HighLight('scalaBackTick',        'blue',   '', '')
call <SID>HighLight('scalaMethodCall',      'blue',   '', '')
call <SID>HighLight('scalaXml',             'green',  '', '')
call <SID>HighLight('scalaString',          'green',  '', '')
call <SID>HighLight('scalaBackTick',        'green',  '', '')
call <SID>HighLight('scalaEmptyString',     'green',  '', '')
call <SID>HighLight('scalaStringEscape',    'green',  '', '')
call <SID>HighLight('scalaMultiLineString', 'green',  '', '')
call <SID>HighLight('scalaTypeSpecializer', 'yellow', '', '')
call <SID>HighLight('scalaDefSpecializer',  'yellow', '', '')
call <SID>HighLight('scalaType',            'yellow', '', '')
call <SID>HighLight('scalaCaseType',        'yellow', '', '')
call <SID>HighLight('scalaAnnotation',      'orange', '', '')
call <SID>HighLight('scalaSymbol',          'orange', '', '')
call <SID>HighLight('scalaUnicode',         'orange', '', '')
call <SID>HighLight('scalaBoolean',         'orange', '', '')
call <SID>HighLight('scalaNumber',          'orange', '', '')
call <SID>HighLight('scalaChar',            'orange', '', '')
call <SID>HighLight('scalaImport',          'purple', '', '')
call <SID>HighLight('scalaDef',             'purple', '', '')
call <SID>HighLight('scalaVal',             'purple', '', '')
call <SID>HighLight('scalaClass',           'purple', '', '')
call <SID>HighLight('scalaTrait',           'purple', '', '')
call <SID>HighLight('scalaObject',          'purple', '', '')
call <SID>HighLight('scalaKeywordModifier', 'purple', '', '')
call <SID>HighLight('scalaDocComment',      'commnt', '', '')
call <SID>HighLight('scalaComment',         'commnt', '', '')
call <SID>HighLight('scalaDocTags',         'commnt', '', '')
call <SID>HighLight('scalaLineComment',     'commnt', '', '')

" Diff {{{2

call <SID>HighLight('DiffDelete', 'red',   '',  '')
call <SID>HighLight('DiffChange', 'blue',  '',  '')
call <SID>HighLight('DiffAdd',    'green', '',  '')
call <SID>HighLight('DiffText',   'line',  'blue', 'bold')

" Cleanup {{{2

" Remove the highlight function as it's no longer needed.
" Will cause problems reloading the theme if not deleted.
delfunction <SID>HighLight

# Many of the environment are taken from:
# https://wiki.archlinux.org/index.php/XDG_Base_Directory_support
# https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html

export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc

export _Z_DATA="$XDG_DATA_HOME/z"

alias wget='"wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'
export WGETRC="$XDG_CONFIG_HOME/wgetrc"

export GNUPGHOME="$XDG_DATA_HOME"/gnupg

export OCTAVE_HISTFILE="$XDG_CACHE_HOME/octave-hsts"
export OCTAVE_SITE_INITFILE="$XDG_CONFIG_HOME/octave/octaverc"

export CARGO_HOME="$XDG_DATA_HOME"/cargo
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup

export GEM_HOME="$XDG_DATA_HOME"/gem
export GEM_SPEC_CACHE="$XDG_CACHE_HOME"/gem
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME"/bundle
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME"/bundle
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME"/bundle
export RBENV_ROOT="$XDG_DATA_HOME/rbenv"
export PATH="$XDG_DATA_HOME/rbenv/bin:$PATH"
export PATH="$XDG_DATA_HOME/rbenv/plugins/ruby-build/bin:$PATH"

export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc

export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter

export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java

export PATH="$XDG_DATA_HOME/perl5/bin${PATH:+:${PATH}}"
export PERL5LIB="$XDG_DATA_HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL_LOCAL_LIB_ROOT="$XDG_DATA_HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_MB_OPT="--install_base \"$XDG_DATA_HOME/perl5\""
export PERL_MM_OPT="INSTALL_BASE=$XDG_DATA_HOME/perl5" 

export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle

export ELECTRUMDIR="$XDG_DATA_HOME/electrum"

export GOPATH="$XDG_DATA_HOME"/go
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
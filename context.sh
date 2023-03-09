set -e 

. ./evolve.env
. ./utils.sh

# Used internally by the evolve scrips and not meant to be configured!
# Otherwise the install process might very well break.
_ssh_initial_root_passwd='root'

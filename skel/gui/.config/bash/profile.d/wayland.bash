
# More info at: https://wiki.archlinux.org/title/wayland#GUI_libraries

# GTK3
# https://docs.gtk.org/gtk3/wayland.html
export GDK_BACKEND=wayland
# Qt - requires the qt5-wayland and qt6-wayland plugins
export QT_QPA_PLATFORM=wayland
# Clutter - discontinued, but adding anyways in case a clutter program happens to get installed.
export CLUTTER_BACKEND=wayland
# SDL2 - check wiki article if having issues with proprietary games
# https://wiki.archlinux.org/title/wayland#SDL2
export SDL_VIDEODRIVER=wayland

# Electron
# TODO: electron Wayland support
# check out https://wiki.archlinux.org/title/wayland#Configuration_file
#   Tried to quickly create electron-flags.conf but didn't check if it actually worked
#   Adding non-sensical flags showed no error messages

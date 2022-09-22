# Features

# Asumptions

* Setup in a fresh Arch Linux installation with a stable network connection. I would recommend `wifi-menu` for setting up wireless networks, mostly for it's ease of use. 

# Installation
 
1. Make sure that an internet conneciton is set up.

2. Download the setup scripts and their helper files

`$ curl --location <url>/evolve.zip | zip -d evolve`

3. Make the scripts executable. 

`$ cd evolve`
`$ chmod +x setup.*.sh`

4. Run setup scripts. *.gui is a extension of *.tui. GUI systems must in other words run both setup scripts.  

TUI (headless) only: 

`# In evolve/`
`$ sh ./evolve/setup.tui.sh`

GUI:

`# In evolve/`
`$ sh ./evolve/setup.tui.sh`
`$ sh ./evolve/setup.gui.sh`

# jgd.cfg
my dotfiles, settings/configs, custom git binaries, etc...

fresh box steps:
1. install wsl
3. setup an ssh key (see the `sshme`, `sshmekeygen` aliases)
4. clone jgd.cfg
5. isntall ruby, dos2unix `sudo apt install rbenv dos2unix`
6. install tmuxinator `gem install tmuxinator`
7. run `setup` script
8. run `source ~/.bashrc`

Windows PowerShell uses the native WezTerm multiplexer for persistent terminals. `install.ps1` installs it automatically via winget; if winget is unavailable, install it manually with `winget install --id wez.wezterm`.

- `main` or `start_main` attaches to (or creates) the `main` session
- `ml` lists sessions
- `ma <name>` attaches to a session
- `md <name>` removes a session

Run `main` to open or reconnect to the persistent `main` workspace. Close the WezTerm window whenever you like; processes remain alive in the mux server. Open a new PowerShell window and run `main` to reconnect.

- [How to solve `Operation not permitted` on cloning repository](https://askubuntu.com/questions/1115564/wsl-ubuntu-distro-how-to-solve-operation-not-permitted-on-cloning-repository)

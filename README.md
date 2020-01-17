# dotfiles
Mah dotfiles, stored as described in this excellent article: https://www.atlassian.com/git/tutorials/dotfiles

# Installation

First, set an alias in your `.bashrc`, `.zsh` or `.profile` as appropriate. Also define it in the local shell scope: 

```bash
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

Make sure your source repository ignores the folder it's cloned into, to avoid weird recursion problems: 

```bash
echo ".cfg" >> .gitignore
```

From there on, download the repo: 

```bash
git clone --bare https://github.com/togald/dotfiles.git $HOME/.cfg
```

Then checkout the contents to your actual home: 

```bash
config checkout
```
The above command might fail with an error message like: 

```bash
error: The following untracked working tree files would be overwritten by checkout:
    .bashrc
    .gitignore
Please move or remove them before you can switch branches.
Aborting
```

This is because your `$HOME` might already have some config files which would be overwritten by GIT. The solution is simple: back up the files if you care, remove them if you don't. A crude solution: 

```bash
mkdir -p .config-backup && \
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}
```

Set the flag `showUntrackedFiles` to no on this specific (local) repository: 

```bash
config config --local status.showUntrackedFiles no
```

Short snippet to do all of this in one go: 

```bash
git clone --bare https://github.com/togald/dotfiles.git $HOME/.cfg
function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}
mkdir -p .config-backup
config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
config checkout
config config status.showUntrackedFiles no
```

From there on, it's all git. Make changes, check them out as different branches for different machines if you want to, and occasionally merge them into your upstream! 

## Dependencies

- xmonad
- xmobar
- pulseaudio
- dmenu
- feh
- xorg-server
- xrandr
- sddm

## Optdepends

- dolphin
- gpicview
- galculator
- chromium
- arandr

## Bootstrap examples

Requirements:
- git

Clones dotfiles at ~ and create links of my dotfiles.

If dotfiles already exist then it's backed with the ".bakpdot" extension. 

### For specific dotfiles like nvim and zsh
```bash
git clone https://github.com/To999999999/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./pdot.sh zsh nvim
```
### For all my dotfiles
```bash
git clone https://github.com/To999999999/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./pdot.sh
```
### Directly remove existing dotfiles without backing them up
```bash
git clone https://github.com/To999999999/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./pdot.sh -d
```
### Reverse the process and activate the machine's dotfiles back (using the ".bakpdot" extensions)
```bash
./pdot.sh -r
```

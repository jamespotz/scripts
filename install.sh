#!/bin/bash

# Update system and upgrade
sudo apt update && sudo apt upgrade -y

# Install zsh
sudo apt install zsh

# Install essential packages for programming
sudo apt install curl wget git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev snapd flatpak gedit gdebi fdfind steam vlc zstd zram-config gnome-tweaks tilix transmission

# Install oh-my-zsh
echo "Installing oh-my-zsh and zsh-syntax-highlighting"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Configure zsh
echo "Configuring zsh as default shell..."
sudo chsh -s /usr/bin/zsh $USER

# Install n, package manager for node
echo "Installing n for nodejs..."
curl -L https://git.io/n-install | bash
# Install node LTS version
echo "Installing latest nodejs LTS version..."
n lts

# install Rbenv
echo 'Installing rbenv...'
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.zshrc

# Install current ruby version
zsh
rbenv install 2.6.5
rbenv global 2.6.5

# Install bundler and rehash
echo "gem: --no-document" >> ~/.gemrc
gem install bundler && rbenv rehash

# Install rust lang
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install starship exa

# Add path to .zshrc
cat >> ~/.zshrc <<-EOF
export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

eval "$(starship init zsh)"

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte-2.91.sh
fi

alias fd="fdfind"
alias work="cd ~/Documents"
alias ls="exa"
EOF

# Install snap apps
echo "Installing snap heroku, vscode and spotify..."
sudo snap install code heroku --classic
sudo snap install winds spotify

# Install flatpack apps
echo "Setup flathut..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Install gnomit, franz, postman, quickdocs, pulseeffects and peek..."
flatpak install flathub ind.ie.Gnomit com.meetfranz.Franz com.getpostman.Postman com.github.mdh34.quickdocs com.uploadedlobster.peek com.github.wwmm.pulseeffects

# install kitty terminal
echo "Installing kitty terminal..."
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications
sudo cp ~/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png /usr/share/icons/hicolor/256x256/apps/

# update icon cache
echo "Updating icon cache..."
sudo gtk-update-icon-cache -f /usr/share/icons/hicolor/

# Sound tweaks
echo "Setting up sound tweaks..."
cat >> ~/.config/pulse/daemon.conf <<- EOF
default-sample-format = s16le
default-sample-rate = 48000
alternate-sample-rate = 44100
default-sample-channels = 2
default-channel-map = front-left,front-right
default-fragments = 4
default-fragment-size-msec = 25
resample-method = speex-float-1
enable-lfe-remixing = no
high-priority = yes
nice-level = -11
realtime-scheduling = yes
realtime-priority = 9
rlimit-rtprio = 9
daemonize = no
EOF

cat >> /etc/asound.conf <<- EOF
# Use PulseAudio plugin hw
pcm.!default {
   type plug
   slave.pcm hw
}
EOF


# install obs
echo "Installing obs-studio..."
sudo add-apt-repository ppa:obsproject/obs-studio
sudo apt-get update && sudo apt install obs-studio

# Setting up git
cat > ~/.gitmessage <<-EOF


# 50-character subject line
#
# 72-character wrapped longer description. This should answer:
#
# * Why was this change necessary?
# * How does it address the problem?
# * Are there any side effects?
#
# Include a link to the ticket, if any.
#
# Add co-authors if you worked on this code with others:
#
# Co-authored-by: Full Name <email@example.com>
# Co-authored-by: Full Name <email@example.com>
EOF

cat > ~/.gitignore <<-EOF
!tags/
*.pyc
*.sw[nop]
.DS_Store
.bundle
.byebug_history
.env
.git/
/bower_components/
/log
/node_modules/
/tmp
/vendor
db/*.sqlite3
log/*.log
rerun.txt
tags
tmp/**/*
EOF

cat > ~/.gitconfig <<-EOF
[push]
  default = current
[color]
  ui = auto
[alias]
  aa = add --all
  ap = add --patch
  branches = for-each-ref --sort=-committerdate --format=\"%(color:blue)%(authordate:relative)\t%(color:red)%(authorname)\t%(color:white)%(color:bold)%(refname:short)\" refs/remotes
  ci = commit -v
  co = checkout
  pf = push --force-with-lease
  st = status
[core]
  excludesfile = ~/.gitignore
  autocrlf = input
  editor = flatpak run ind.ie.Gnomit
[merge]
  ff = only
[commit]
  template = ~/.gitmessage
[fetch]
  prune = true
[rebase]
  autosquash = true
[diff]
  colorMoved = zebra
EOF

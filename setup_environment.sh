#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -d "$DIR/tmux-resurrect" ]; then
  git clone https://github.com/tmux-plugins/tmux-resurrect $DIR/tmux-resurrect
else
  cd $DIR/tmux-resurrect
  git pull
  cd $DIR
fi

# Use the appropriate ros verison
CODENAME=`sed -n -e '/DISTRIB_CODENAME/ s/.*\= *//p' /etc/lsb-release`
SOURCE_CMD=""
if [ "$CODENAME" = "trusty" ] || [ "$CODENAME" = "rosa" ] || [ "$CODENAME" = "rafaela" ] || [ "$CODENAME" = "rebecca" ] || [ "$CODENAME" = "qiana" ] ; then
  SOURCE_CMD=". /opt/ros/indigo/setup.bash"
elif [ "$CODENAME" = "xenial" ] || [ "$CODENAME" = "sylvia" ] || [ "$CODENAME" = "sonya" ] || [ "$CODENAME" = "serena" ] || [ "$CODENAME" = "sarah" ] ; then
  SOURCE_CMD=". /opt/ros/kinetic/setup.bash"
fi

sed -i '/# Custom Settings (ayoungs)/Q' ~/.bashrc
cat <<EOT >> ~/.bashrc
# Custom Settings (ayoungs)

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Sets history to append mode
shopt -s histappend
# Writes to history every time command prompt is returned
PROMPT_COMMAND="history -a;\$PROMPT_COMMAND"

# Identify workspaces by using tmux session names
tmux_session=\`tmux display-message -p "#S" 2> /dev/null\` 
if [ -f ~/workspaces/\$tmux_session/devel/setup.bash ]; then
  . ~/workspaces/\$tmux_session/devel/setup.bash
else
  LAST_SOURCE="\$(grep -aE '^(\.|source) [a-zA-Z0-9_/~\]*setup.bash' \$HISTFILE | tail -1)"
  \${LAST_SOURCE/\~/\$HOME}
fi

# This grabs the last ROS_MASTER_URI exported
# Todo: fix this to use a function
\$(grep -a '^export ROS_MASTER_URI=' \$HISTFILE | tail -1)
EOT

touch ~/.bash_eternal_history
./dotfiles/link_dotfiles.sh
sudo $DIR/scripts/install_scripts.sh

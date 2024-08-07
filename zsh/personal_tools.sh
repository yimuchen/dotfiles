# Required for ltex-ls
# export LD_LIBRARY_PATH=/usr/lib/jvm/$(archlinux-java get)/lib/:$LD_LIBRARY_PATH

# For changing system theme when opening GUI program from command line
export XDG_CONFIG_HOME=$HOME/.config # KDE command line application theming

# Firefox hardware acceleration
export MOZ_X11_EGL=1
export MOZ_ENABLE_WAYLAND=1

# Input methods
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx



# Package management helper functions
alias pacsize="expac -H M '%m\t%n' | sort -h"

function pacupdate() {
   local lock_file=$HOME/.update.lock
   local prev=$(date -d "$(cat ${lock_file})" +%s)
   local now=$(date +%s)
   if [[ $((now - prev)) -gt $((3600 * 24 * 7)) ]]; then
      echo "Performing system update"
      paru
      sudo pacdiff
      paru --query --unrequired --deps --quiet | paru --remove --nosave --recursive -
      date "+%Y-%m-%d" >${lock_file}
   else
      echo "Previous update was at $(cat ${lockfile}), less than a week ago"
      echo "You can still manually update by explicit paru calls"
   fi
}

function rankpac() {
   {
      curl --silent "https://archlinux.org/mirrorlist/?country=US&protocol=https&ip_version=4" &
      curl --silent "https://archlinux.org/mirrorlist/?country=TW&protocol=https&ip_version=4" &
      curl --silent "https://archlinux.org/mirrorlist/?country=CH&protocol=https&ip_version=4" &
      curl --silent "https://archlinux.org/mirrorlist/?country=DE&protocol=https&ip_version=4" &
      curl --silent "https://archlinux.org/mirrorlist/?country=FR&protocol=https&ip_version=4"
   } |
      sed --expression='s/^#Server/Server/' --expression='/^#/d' |
      rankmirrors -n 10 --verbose -
}

# System reboot helpers
alias efireboot='systemctl reboot --firmware-setup'

function winreboot() {
   local WINDOWS_TITLE=$(sudo grep -i 'windows' /boot/grub/grub.cfg | cut -d"'" -f2)
   sudo grub-reboot "$WINDOWS_TITLE"
   sudo reboot
}

# Networking and SSH related function

lf_() {
   ## Short hand for generating local forwarding string for SSH commands
   port=$1
   str="-L localhost:${port}:localhost:${port}"
   printf "%s" ${str}
}

function rootremote() {
   local remotefile=$1
   scp $remotefile /tmp
   root /tmp/$(basename $remotefile)
}


function update_clock() {
   sudo ntpd -qg
   sudo hwclock -w
}

if [ -f $HOME/.zsh/network_alias.sh ]; then
   ## Some network shorthands contains potentially sensitive and should not be passed to open source handlers.
   source $HOME/.zsh/network_alias.sh
fi

# Virtual machine manager network startup
alias virt_network_start='sudo virsh net-start default'

# Docker clean up function
function docker_clear_container() {
   docker container rm $(docker container ls --all | tail -n +2 | awk '{print $1}')
}
function docker_clear_image() {
   docker image rm $(docker image ls --all | tail -n +2 | awk '{print $3}')
}
function docker_clear_all() {
   docker_clear_container
   docker_clear_image
}

# Method for quickly starting the xfreerdp session (with typical settings)
alias fwd_xrdp="xfreerdp /w:1920 /h:1080 /v:localhost:9900"

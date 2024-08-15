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

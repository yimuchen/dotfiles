# Additional utility function
function get_jupyter_url() {
   # Getting the url of the of the jupyter server session that is running in
   # this directory
   local json_file=$(ls -1t ${PWD}/.local/share/jupyter/runtime/jpserver-*.json | head -n 1)
   local token=$(jq -r '.token' ${json_file})
   local port=$(jq -r '.port' ${json_file})
   # Assuming that localhost is used to expose the runtime
   echo "http://localhost:${port}/?token=${token}"
}

function show_term_color() {
  for i in {0..255}; do
    print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'};
  done
}

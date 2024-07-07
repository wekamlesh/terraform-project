cat << EOF >> ~/.ssh/config

HOST $(hostname)
    hostName $(hostname)
    User $(user)
    IdentityFile $(identityfile)
EOF
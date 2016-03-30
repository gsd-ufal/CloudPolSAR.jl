#!/bin/bash

###=============================================================================
#
#          FILE: install.sh
# 
#         USAGE: chmod +x install.sh && ./install.sh
# 
#   DESCRIPTION: install CloudArrayDaemon service
# 
#       OPTIONS: ---
#  DEPENDENCIES: 
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raphael P. Ribeiro
#  ORGANIZATION: GSD-UFAL
#       CREATED: 2016-03-30 11:00
###=============================================================================

# Make sure only root can run the script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if ! which julia >/dev/null; then
    julia_install
fi

function install_julia()
{
    mkdir -p /opt/julia_0.4.0 && \
    curl -s -L https://julialang.s3.amazonaws.com/bin/linux/x64/0.4/julia-0.4.0-linux-x86_64.tar.gz | tar -C /opt/julia_0.4.0 -x -z --strip-components=1 -f -

    ln -fs /opt/julia_0.4.0 /opt/julia

    echo "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/julia/bin\"" > /etc/environment && \
    echo "export PATH" >> /etc/environment && \
    echo "source /etc/environment" >> /root/.bashrc
}

julia -e "Pkg.build(\"MbedTLS\")"
julia -e "Pkg.add(\"HttpServer\")"
cp cloudarraydaemon /usr/bin/cloudarraydaemon && chmod +x /usr/bin/cloudarraydaemon
cp cloudarraydaemon.init /usr/bin/cloudarraydaemon.init && chmod +x /usr/bin/cloudarraydaemon.init
cp cloudarraydaemon.service /etc/systemd/system/cloudarraydaemon.service
systemctl daemon-reload && systemctl enable cloudarraydaemon && systemctl start cloudarraydaemon

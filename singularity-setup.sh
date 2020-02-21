#! /usr/bin/env bash

# should be run as root

# install dependencies
apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git \
    cryptsetup

# install GO

# download the most recent version
wget https://dl.google.com/go/go1.13.8.linux-amd64.tar.gz
# extract to the /usr/local/ dir > creates a `go` tree in the directory
tar -C /usr/local -xzf go1.13.8.linux-amd64.tar.gz

# add to path
cat "export PATH=$PATH:/usr/local/go/bin" | tee -a /etc/profile

# reload the profile
source /etc/profile

# clean up
rm go1.13.8.linux-amd64.tar.gz

# download the singularity source
wget https://github.com/sylabs/singularity/releases/download/v3.5.3/singularity-3.5.3.tar.gz
tar xzf singularity-3.5.3.tar.gz
cd singularity
./mconfig && \
    make -C builddir && \
    sudo make -C builddir install

# cleanup
cd ..
rm -rf singularity-3.5.3.tar.gz singularity

# and singularity should now be installed
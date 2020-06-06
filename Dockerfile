FROM rubensa/ubuntu-tini-x11
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# Suppress the Wine debug messages
ENV WINEDEBUG -all

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Enable 32 bit architecture, configure apt and install packages
RUN dpkg --add-architecture i386 && apt-get update && apt-get -y upgrade \
    # 
    # Install software and needed libraries
    && apt-get -y install --no-install-recommends software-properties-common winbind libncurses5:i386 2>&1 \
    #
    # Add Repos
    #
    # Wine repo
    && curl https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    && add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' \
    #
    # faudio backport repo
    && curl -L https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key | apt-key add - \
    && add-apt-repository 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/ ./' \
    #
    # Install software
    && apt-get update && apt-get -y upgrade && apt-get -y install --install-recommends winehq-stable winetricks 2>&1 \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

# Tell docker that all future commands should be run as the non-root user
USER ${USER_NAME}

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME /home/${USER_NAME}

# Set default working directory to user home directory
WORKDIR ${HOME}

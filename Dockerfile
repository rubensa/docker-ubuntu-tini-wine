FROM rubensa/ubuntu-tini-x11
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt
RUN apt-get update

# Configure apt and install packages
RUN echo "# Installing Microsoft fonts..." \
  #
  # Install Micro$oft Fonts
  #
  && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
  && apt-get -y install --no-install-recommends ttf-mscorefonts-installer 2>&1 

# Install wine dependencies
RUN echo "# Enabling 32 bit architecture (needed by wine apps)..." \
  #
  # Enable 32 bit architecture
  && dpkg --add-architecture i386 \
  && apt-get update && apt-get -y install --no-install-recommends libncurses6:i386 libpulse0:i386 libdbus-1-3:i386 libsdl2-2.0-0:i386 software-properties-common winbind zenity 2>&1 

# Suppress the Wine debug messages
ENV WINEDEBUG -all
# Add winehq repo
RUN mkdir -p /etc/apt/keyrings/ \
  && curl -sSL https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq.gpg  \
  && printf "deb [signed-by=/etc/apt/keyrings/winehq.gpg] https://dl.winehq.org/wine-builds/ubuntu/ jammy main" > /etc/apt/sources.list.d/wine.list  \
  # Install wine and winetricks
  && echo "# Installing wine and winetricks..." \
  # No stable version yet for Ubuntu 22.04 (Jammy Jellyfish)
  # see: https://forum.winehq.org/viewtopic.php?t=36501
  # and: https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/main/binary-i386/
  # Looks like devel version is always preferred over stable
  # see: https://wiki.winehq.org/FAQ#Which_version_of_Wine_should_I_use.3F
  && apt-get update && apt-get -y install --install-recommends wine-devel winehq-devel winetricks 2>&1

# Clean up apt
RUN apt-get autoremove -y \
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

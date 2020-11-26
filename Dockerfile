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

# Configure apt and install packages
RUN apt-get update \
    #
    # Install Micro$oft Fonts
    #
    # fontforge is required to convert TTC files into TTF
    && apt-get -y install fontforge \
    #
    # Windows Core fonts:
    # Andale Mono, Arial Black, Arial (Bold, Italic, Bold Italic), Comic Sans MS (Bold), Courier New (Bold, Italic, Bold Italic)
    # Georgia (Bold, Italic, Bold Italic), Impact, Times New Roman (Bold, Italic, Bold Italic), Trebuchet (Bold, Italic, Bold Italic)
    # Verdana (Bold, Italic, Bold Italic), Webdings
    && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
    && apt-get -y install ttf-mscorefonts-installer \
    # Microsoft’s ClearType fonts (Windows Vista Fonts):
    # Calibri (Bold, Italic, Bold Italic), Consolas (Bold, Italic, Bold Italic), Candara (Bold, Italic, Bold Italic)
    # Corbel (Bold, Italic, Bold Italic), Constantia (Bold, Italic, Bold Italic), Cambria (Bold, Italic, Bold Italic)
    # Cambria Math
    && mkdir -p /tmp/fonts \
    && curl -o /tmp/fonts/PowerPointViewer.exe -sSL https://sourceforge.net/projects/mscorefonts2/files/cabs/PowerPointViewer.exe/download \
    && cabextract -F ppviewer.cab /tmp/fonts/PowerPointViewer.exe -d /tmp/fonts \
    && cabextract -L -F '*.tt?' /tmp/fonts/ppviewer.cab -d /tmp/fonts \
    && fontforge -lang=ff -c 'Open("/tmp/fonts/cambria.ttc(Cambria)"); Generate("/tmp/fonts/cambria.ttf"); Close(); Open("/tmp/fonts/cambria.ttc(Cambria Math)"); Generate("/tmp/fonts/cambriamath.ttf"); Close();' \
    # Microsoft Tahoma
    && mkdir -p /tmp/fonts \
    && curl -o /tmp/fonts/IELPKTH.CAB -sSL https://sourceforge.net/project/corefonts/OldFiles/IELPKTH.CAB/download \
    && cabextract -F 'tahoma*ttf' /tmp/fonts/IELPKTH.CAB -d /tmp/fonts \
    # Wine Tahoma
    && mkdir -p /tmp/fonts \
    && curl -o /tmp/fonts/tahoma.ttf -sSL http://source.winehq.org/source/fonts/tahoma.ttf?_raw=1 \
    && curl -o /tmp/fonts/tahomabd.ttf -sSL http://source.winehq.org/source/fonts/tahomabd.ttf?_raw=1 \
    #
    # Segoe UI
    # regular
    && curl -o /tmp/fonts/segoeui.ttf -sSL https://github.com/rubensa/clide/blob/master/doc/fonts/segoeui.ttf?raw=true \
    # bold
    && curl -o /tmp/fonts/segoeuib.ttf -sSL https://github.com/rubensa/clide/blob/master/doc/fonts/segoeuib.ttf?raw=true \
    # italic
    && curl -o /tmp/fonts/segoeuii.ttf -sSL https://github.com/rubensa/clide/blob/master/doc/fonts/segoeuib.ttf?raw=true \
    # bold italic
    && curl -o /tmp/fonts/segoeuiz.ttf -sSL https://github.com/rubensa/clide/blob/master/doc/fonts/segoeuiz.ttf?raw=true \
    # light
    && curl -o /tmp/fonts/segoeuil.ttf -sSL https://github.com/rubensa/clide/blob/master/doc/fonts/segoeuil.ttf?raw=true \
    # light italic
    && curl -o /tmp/fonts/seguili.ttf -sSL https://github.com/rubensa/clide/blob/master/doc/fonts/seguili.ttf?raw=true \
    # semilight
    && curl -o /tmp/fonts/segoeuisl.ttf -sSL https://github.com/rubensa/clide/blob/master/doc/fonts/segoeuisl.ttf?raw=true \
    # semilight italic
    && curl -o /tmp/fonts/seguisli.ttf -sSL https://github.com/rubensa/clide/blob/master/doc/fonts/seguisli.ttf?raw=true \
    # semibold
    && curl -o /tmp/fonts/seguisb.ttf -sSL https://github.com/rubensa/clide/blob/master/doc/fonts/seguisb.ttf?raw=true \
    # semibold italic
    && curl -o /tmp/fonts/seguisbi.ttf -sSL https://github.com/rubensa/clide/blob/master/doc/fonts/seguisbi.ttf?raw=true \
    #
    # WPS Office Fonts (Symbol fonts)
    && curl -o /tmp/fonts/WEBDINGS.TTF -sSL https://github.com/rubensa/ttf-wps-fonts/raw/master/WEBDINGS.TTF \
    && curl -o /tmp/fonts/WINGDNG2.ttf -sSL https://github.com/rubensa/ttf-wps-fonts/raw/master/WINGDNG2.ttf \
    && curl -o /tmp/fonts/WINGDNG3.ttf -sSL https://github.com/rubensa/ttf-wps-fonts/raw/master/WINGDNG3.ttf \
    && curl -o /tmp/fonts/mtextra.ttf -sSL https://github.com/rubensa/ttf-wps-fonts/raw/master/mtextra.ttf \
    && curl -o /tmp/fonts/symbol.ttf -sSL https://github.com/rubensa/ttf-wps-fonts/raw/master/symbol.ttf \
    && curl -o /tmp/fonts/wingding.ttf -sSL https://github.com/rubensa/ttf-wps-fonts/raw/master/wingding.ttf \
    #
    && mkdir -p /usr/share/fonts/truetype/msttcorefonts/ \
    && cp -f /tmp/fonts/*.ttf /usr/share/fonts/truetype/msttcorefonts \
    && cp -f /tmp/fonts/*.TTF /usr/share/fonts/truetype/msttcorefonts \
    && fc-cache -f /usr/share/fonts/truetype/msttcorefonts \
    && rm -rf /tmp/fonts \
    #
    # Sans-serif font metric-compatible with Calibri font
    && apt-get -y install --no-install-recommends fonts-crosextra-carlito 2>&1 \
    # 
    # Install software and needed libraries
    && apt-get -y install --no-install-recommends software-properties-common winbind 2>&1 \
    #
    # Add Repos
    #
    # Wine repo
    && curl -sSL https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    && add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' \
    #
    # Enable 32 bit architecture
    && dpkg --add-architecture i386 \
    #
    # Install software
    && apt-get update && apt-get -y upgrade 2>&1 && apt-get -y install --install-recommends libncurses6:i386 winehq-stable zenity winetricks 2>&1 \
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

# This Dockerfile is used to build an headles vnc image based on Ubuntu

FROM ubuntu:18.04

ENV REFRESHED_AT 2018-10-29

LABEL io.k8s.description="Headless VNC Container with Xfce window manager, firefox and chromium" \
    io.k8s.display-name="Headless VNC Container based on Ubuntu" \
    io.openshift.expose-services="6901:http,5901:xvnc" \
    io.openshift.tags="vnc, ubuntu, xfce" \
    io.openshift.non-scalable=true

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

### Envrionment config
ENV HOME=/headless \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    NO_VNC_HOME=/headless/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false
WORKDIR $HOME

### Add all install scripts for further steps
ADD ./src/common/install/ $INST_SCRIPTS/
ADD ./src/ubuntu/install/ $INST_SCRIPTS/
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN $INST_SCRIPTS/tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install custom fonts
RUN $INST_SCRIPTS/install_custom_fonts.sh

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $INST_SCRIPTS/tigervnc.sh
RUN $INST_SCRIPTS/no_vnc.sh

### Install firefox and chrome browser
RUN $INST_SCRIPTS/firefox.sh
RUN $INST_SCRIPTS/chrome.sh

### Install Python3.8
RUN $INST_SCRIPTS/python.sh

### Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD ./src/common/xfce/ $HOME/

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

### Switch to root user to install additional software
USER 0

### Install sudo and curl for later use
RUN apt-get update && \
    apt-get -y install sudo && \
    apt install -y curl

### Install a Java 8 and gcj-jdk
RUN apt-get install -y openjdk-8-jdk

### Install pip for python
RUN sudo apt install -y python3-pip && \
    apt-get clean;

### Install packages in requirement.txt using pip
COPY ./jars/requirement.txt /tmp/requirements.txt
RUN python3.8 -m pip install --upgrade pip && \
    pip install --requirement /tmp/requirements.txt

### Install node js and Typescript
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - && \
    sudo apt-get install -y nodejs
RUN npm install -g typescript
RUN node --version | npm --version 

RUN apt-get install -y build-essential && \
    apt-get -y auto-remove
USER 1000

### Copy required files
COPY ./jars/BrilliantCalculator-1.0.0.jar /headless/Desktop/app.jar
ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
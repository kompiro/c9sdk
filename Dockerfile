FROM buildpack-deps:jessie

ENV C9_HOME=/opt/c9sdk
ENV WORKSPACE=/workspace

RUN \
  # add docker
  apt-get update -qq && \
  apt-get install -y apt-transport-https ca-certificates curl \
    gnupg2 software-properties-common sudo && \
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
  apt-key fingerprint 0EBFCD88 && \
  add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable" && \
  # user setting
  useradd -ms /bin/bash c9 && \
  echo "c9:c9" | chpasswd && \
  adduser c9 sudo && \
  mkdir $C9_HOME && mkdir $WORKSPACE && \
  chown c9:c9 $C9_HOME && chown c9:c9 $WORKSPACE && \
  # add developer tools
  apt-get update -qq && apt-get install -y less vim docker-ce

USER c9
WORKDIR $C9_HOME

RUN \
  # cloud9
  git clone https://github.com/c9/core.git . && \
  scripts/install-sdk.sh && \
  sed -i -e 's_127.0.0.1_0.0.0.0_g' $C9_HOME/configs/standalone.js

VOLUME /home/c9
EXPOSE 8080
WORKDIR /home/c9
CMD ["/home/c9/.c9/node/bin/node", "/opt/c9sdk/server.js", "-p", "8080", "-l", "0.0.0.0", "-a", ":", "-w", "/workspace"]

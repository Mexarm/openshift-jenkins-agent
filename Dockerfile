FROM openshift/jenkins-slave-base-centos7

ENV PYTHON_VERSION=3.7 \
    PATH=$HOME/.local/bin/:/usr/src/sonar-scanner-4.3.0.2102-linux/bin/:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PIP_NO_CACHE_DIR=off 

# install python 3.7.7 and SonarScanner
WORKDIR /usr/src
RUN yum -y install epel-release && \
    INSTALL_PKGS="gcc openssl-devel bzip2-devel libffi-devel make \
    libsqlite3x-devel libsqlite3x" && \
    yum -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*' && \
    wget https://www.sqlite.org/2020/sqlite-autoconf-3310100.tar.gz && \
    tar -zxvf sqlite-autoconf-3310100.tar.gz && \
    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.3.0.2102-linux.zip && \
    unzip sonar-scanner-cli-4.3.0.2102-linux.zip && \
    cd sqlite-autoconf-3310100 && \
    ./configure && make && make install && \
    cd .. && \
    wget https://www.python.org/ftp/python/3.7.7/Python-3.7.7.tgz && \
    tar xzf Python-3.7.7.tgz && \
    cd Python-3.7.7 && \
    LD_RUN_PATH=/usr/local/lib ./configure --enable-loadable-sqlite-extensions --enable-optimizations && \
    LD_RUN_PATH=/usr/local/lib make altinstall && \
    rm -rf /usr/src/Python-3.7.7 && \
    rm /usr/src/Python-3.7.7.tgz && \
    rm -rf /usr/src/sqlite-autoconf-3310100 && \
    rm /usr/src/sqlite-autoconf-3310100.tar.gz && \
    rm /usr/src/sonar-scanner-cli-4.3.0.2102-linux.zip && \
    chmod -R 775 /usr/local/lib/ && \
    chmod -R 775 /usr/local/bin/

#ENV JAVA_TOOL_OPTIONS="-XX:+UnlockExperimentalVMOptions"
ENV JAVA_TOOL_OPTIONS=-XX:+UnlockExperimentalVMOptions -Dsun.zip.disableMemoryMapping=true
# Healthcheck and version stats
RUN set -x && \
    python3.7 --version && \
    sonar-scanner --version 

# syntax=docker/dockerfile:1.3-labs
FROM nyamisty/docker-wine-dotnet:win64-devel
MAINTAINER NyaMisty

ARG PYTHON_VER=3.9.6
ARG USE_IDAPYSWITCH=1
ARG IDA_LICENSE_NAME=docker-wine-ida
ARG DOCKER_PASSWORD=DockerWineIDA

SHELL ["/bin/bash", "-c"]

WORKDIR /root

VOLUME /root/host

# Configure profile for Wine
RUN true \
    && echo "root:$DOCKER_PASSWORD" | chpasswd

# Install Python first
RUN --security=insecure true \
    && (entrypoint true; sleep 0.5; wineboot --init) \
    && (entrypoint true; sleep 0.5; winetricks -q win10) \
    && while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done \
    && if [[ $PYTHON_VER == 2* ]]; then \
           wget "https://www.python.org/ftp/python/${PYTHON_VER}/python-${PYTHON_VER}.amd64.msi" \
           && (wine cmd /c msiexec /i python-*.amd64.msi /qn /L*V! python_inst.log; ret=$?; cat python_inst.log; rm python_inst.log; exit $ret); \
       else \
           wget "https://www.python.org/ftp/python/${PYTHON_VER}/python-${PYTHON_VER}-amd64.exe" \
           && (wine cmd /c python*.* /quiet /log python_inst.log InstallAllUsers=1 PrependPath=1; ret=$?; cat python_inst.log; rm python_inst.log; exit $ret); \
       fi \
    && while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done \
    && winetricks -q win7 \
    && while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done \
    && rm -rf $HOME/.cache/winetricks && rm python*


# Configure IDA
ADD . /root/.wine/drive_c/IDA
RUN true \
    && if [ "$USE_IDAPYSWITCH" = "1" ]; then (echo 0 | wine 'C:\IDA\idapyswitch.exe'); fi \
    && wine cmd /c reg add 'HKCU\Software\Hex-Rays\IDA' /v "License $IDA_LICENSE_NAME" /t REG_DWORD /d 1 /f \
    && while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done

# Configure ipyida
RUN true \
    && wine cmd /c pip install ipykernel \
    && wine cmd /c pip install https://github.com/NyaMisty/ipyida/zipball/master \
    && if [[ $PYTHON_VER == 3* ]]; then ( \
        echo "Pyzmq 22.X introduces EPOLL for windows, causing wine failing, changing version!"; \
        wine pip uninstall --yes pyzmq; \
        wine pip install --no-index --find-links=https://github.com/NyaMisty/pyzmq/releases pyzmq \
      ); \
    fi \
    && wget -O ~/.wine/drive_c/IDA/plugins/ipyida_plugin_stub.py https://raw.githubusercontent.com/NyaMisty/ipyida/master/ipyida/ipyida_plugin_stub.py

# Configure jupyter
RUN true \
    && apt-get update && apt-get -y install python3 python3-pip \
    && pip3 install notebook \
    && wget -O /opt/wine_ida_wrap.sh https://raw.githubusercontent.com/NyaMisty/docker-wine-ida/master/jupyter_helpers/wine_ida_wrap.sh \
    && chmod +x /opt/wine_ida_wrap.sh \
    && mkdir -p /usr/local/share/jupyter/kernels/ida64 \
    && mkdir -p /usr/local/share/jupyter/kernels/ida32 \
    && wget -O /usr/local/share/jupyter/kernels/ida32/kernel.json https://raw.githubusercontent.com/NyaMisty/docker-wine-ida/master/jupyter_helpers/ida32.json \
    && wget -O /usr/local/share/jupyter/kernels/ida64/kernel.json https://raw.githubusercontent.com/NyaMisty/docker-wine-ida/master/jupyter_helpers/ida64.json \
    && echo '#!/bin/bash' > ~/start_notebook.sh \
    && passhash=$(python3 -c 'from notebook.auth import passwd; print(passwd("'$DOCKER_PASSWORD'", "sha1"))') \
    && echo "python3 -m jupyter notebook --notebook-dir /root --allow-root --no-browser --port 8080 --ip 0.0.0.0 --NotebookApp.password=\"$passhash\"" >> ~/start_notebook.sh \
    && chmod +x ~/start_notebook.sh


CMD ["/root/start_notebook.sh"]
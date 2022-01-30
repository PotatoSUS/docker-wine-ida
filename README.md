# docker-wine-ida

![Docker IDA](docker-ida-logo.png)
---

Dockerized Windows IDA running on Wine, with Xvfb/X11/Xrdp, IDAPython Jupyter Notebook support! 

Prebuilt image also available!

## Features

- Xvfb/X11/Xrdp support builtin: based on scottyhardy/docker-wine, offering a easy-to-use Wine environment
- IDAPython Jupyter Notebook: (Python3 only)
    - IDAPython integrated as Jupyter Notebook kernel using ipyida. 
    - Notebook server available at port 8080, with password "DockerWineIDA"
- Prebuilt leaked IDA version available at [nyamisty/docker-wine-ida](https://hub.docker.com/r/nyamisty/docker-wine-ida)


## Usage

- Select one version to begin with
  ```
  docker pull nyamisty/docker-wine-ida:7.7sp1
  
  docker pull nyamisty/docker-wine-ida:7.6sp1
  
  docker pull nyamisty/docker-wine-ida:7.5sp3
  
  docker pull nyamisty/docker-wine-ida:7.0
  ```

- Basic info
  - By default docker-wine-ida starts Jupyter Notebook server at 8080 port if no command supplied
    - Make sure you map the path needed under /root: Jupyter Notebook server uses /root as root directory
      - I prepared a /root/host volume as host sharing path, you can actually do `-v /:/root/host`
    - note: you'll also need to expose the 8080 port using `-p 8080:8080`
  - IDA locates at C:\\IDA

- You can run docker-wine-ida in several mode:
  - Xvfb: no IDA windows output, only console
  - X11: showing IDA windows through X11 (through X11/VcXsrv/WSLg)
  - Xrdp: showing IDA windows through a Xrdp RDP session
  - (Because docker-wine-ida is based on scottyhardy/docker-wine, more usage can be found in [the manual-running part](https://github.com/scottyhardy/docker-wine#manually-running-with-docker-run-commands) of docker-wine's documentation.)

## Examples

All these examples spins up a jupyter server. Add command to the end if you want to do other things.

- Run with Xvfb
    - Without mapping dir:
    ```
    docker run --name docker-ida -p 8080:8080 -v "/:/root/host" -it nyamisty/docker-wine-ida:7.6sp1
    ```
    - Map current directory to Z:\root\host
    ```
    docker run --name docker-ida -p 8080:8080 -v "/:/root/host" -it nyamisty/docker-wine-ida:7.6sp1
    ```

- Run with X11 forward:
    ```
    docker run --name docker-ida -p 8080:8080 -v "/:/root/host" --hostname="$(hostname)" --env="USE_XVFB=no" --env="DISPLAY" --volume="${XAUTHORITY:-${HOME}/.Xauthority}:/root/.Xauthority:ro" --volume="/tmp/.X11-unix:/tmp/.X11-unix:ro" -it nyamisty/docker-wine-ida:7.6sp1
    ```

- Run with Xrdp:
    1. Run the container, and export the RDP port 3389.
    ```
    docker run --name docker-ida -p 8080:8080 -v "/:/root/host" -p "3389:3389/tcp" --hostname="$(hostname)" --env="RDP_SERVER=yes" -it nyamisty/docker-wine-ida:7.6sp1
    ```
    2. Connect to RDP server with credentials:
    - user: root
    - pass: DockerWineIDA
    3. Run IDA in the terminal:
    ```
    wine C:\\IDA\\ida.exe
    wine C:\\IDA\\ida64.exe
      ```

## Credits
- Prebuilted versions are leaked IDA Pro 7.0/7.5sp3/7.6sp1
    - IDA 7.0: https://down.52pojie.cn/Tools/Disassemblers/IDA.txt
    - IDA 7.5 & 7.6: https://fuckilfakp5d6a5t.onion (now migrated to https://fckilfkscwusoopguhi7i6yg3l6tknaz7lrumvlhg5mvtxzxbbxlimid.onion)
    - IDA 7.7: Dr.Far-Far
- IPyIDA built by eset and adapted by me
- Thanks scottyhardy/docker-wine for Wine's docker image
- Thanks other projects for referencing:
    - https://github.com/intezer/docker-ida
    - https://github.com/thawsystems/docker-ida
    - https://gist.github.com/williballenthin/1c6ae0fbeabae075f1a4
    - https://github.com/nicolaipre/idapro-docker


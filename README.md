# mkdomoticz
Make a persistent domoticz container PDQ

### Requirements

docker

## Contributing

Feel free to make an issue or pull request [here](https://github.com/joshuacox/mkdomoticz)

### Usage

`make run`

should ask you any pertinent questions and bring up a container running domoticz

### DockerHub Usage

```
docker pull joshuacox/mkdomoticz
````

#### Temporary demo of domoticz1

```
 @docker run --name=domoticz \
        --privileged \
        --cidfile="cid" \
        -d \
        -p 8080:8080 \
        -v $(DATADIR)/config:/config \
        -t joshuacox/mkdomoticz
```

or simply use the `temp` recipe from  the Makefile

```
make temp
```

#### Persistence

First run an instance like above with `make init` and then use the 'grab' recipe to `make grab` it's data dirctory:

```
make grab
```

or manually

```
        mkdir -p datadir/domoticz
        docker cp `cat cid`:/config  - |sudo tar -C datadir/ -pxf -
```

Note this only need be done once to `grab` the files and directory
structure from within `/config` in the running image and write them out
to our volume mount

then kill off the original container and run the persistent image

```
make clean
make run
```

or manually

```
 @docker run --name=domoticz \
        --privileged \
        -d \
        -p 8080:8080 \
        -v `pwd`/datadir/config:/config \
        -t joshuacox/mkdomoticz
```

### Branches

##### master / stretch
- pulls and runs `joshuacox/mkdomoticz` from github by default

##### arm
- pulls and runs `joshuacox/mkdomoticz:arm` from github by default

##### local-stretch
- builds locally using local-debian this branch should work on any
  architecture given debian also runs there (and therefore debootstrap)

there are branches for raspberryPi as well, checkout the `arm` branch to pull my image from docker hub, or use the `local-stretch` to build 
locally though it should be noted you'll need a locally built stretch image named `local-stretch`, I have another [Makefile 
repo](https://github.com/joshuacox/local-debian) for that as  well.  Merely `make stretch` and a local stretch image can be built using 
debootstrap (which is available in most distribution [even ones not based on debian])

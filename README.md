# mkdomoticz
Make a persistent domoticz container PDQ

### Requirements

docker

## Contributing

Feel free to make an issue or pull request [here](https://github.com/joshuacox/mkdomoticz)

### Usage

`make auto`

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
        -v $(LOGDIR)/log:/log \
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

### CLI options

You can add command lines opts by adding them to `DOMOTICZ_OPTS`

i.e. to change `verbosity` to `debug`

```
echo '-verbose 2'
```

Here's the current list of opts:

```
Usage: Domoticz -www port -verbose x
        -www port (for example -www 8080, or -www 0 to disable http)
        -wwwbind address (for example -wwwbind 0.0.0.0 or -wwwbind 192.168.0.20)
        -sslwww port (for example -sslwww 443, or -sslwww 0 to disable https)
        -sslcert file_path (for example /opt/domoticz/server_cert.pem)
        -sslkey file_path (if different from certificate file)
        -sslpass passphrase (to access to server private key in certificate)
        -sslmethod method (for SSL method)
        -ssloptions options (for SSL options, default is 'default_workarounds,no_sslv2,no_sslv3,no_tlsv1,no_tlsv1_1,single_dh_use')
        -ssldhparam file_path (for SSL DH parameters)
        -wwwroot file_path (for example /opt/domoticz/www)
        -dbase file_path (for example /opt/domoticz/domoticz.db)
        -userdata file_path (for example /opt/domoticz)
        -webroot additional web root, useful with proxy servers (for example domoticz)
        -verbose x (where x=0 is none, x=1 is all important, x=2 is debug)
        -startupdelay seconds (default=0)
        -nowwwpwd (in case you forgot the web server username/password)
        -nocache (do not return appcache, use only when developing the web pages)
        -log file_path (for example /var/log/domoticz.log)
        -loglevel (0=All, 1=Status+Error, 2=Error , 3= Trace )
        -debug    allow log trace level 3
        -notimestamps (do not prepend timestamps to logs; useful with syslog, etc.)
        -php_cgi_path (for example /usr/bin/php-cgi)
        -daemon (run as background daemon)
        -pidfile pid file location (for example /var/run/domoticz.pid)
        -syslog [user|daemon|local0 .. local7] (use syslog as log output, defaults to facility 'user')
```

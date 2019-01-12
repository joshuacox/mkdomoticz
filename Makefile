.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container
	@echo ""   2. make build     - build docker container
	@echo ""   3. make clean     - kill and remove docker container
	@echo ""   4. make enter     - execute an interactive bash in docker container
	@echo ""   3. make logs      - follow the logs of docker container

build: NAME TAG builddocker

# run a plain container
run:  TZ PORT LOGDIR DATADIR rundocker

prod: run

temp: init

init: DATADIR TZ PORT config pull initdocker

auto: init next

initdocker:
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval TAG := $(shell cat TAG))
	$(eval DOMOTICZ_OPTS := $(shell cat DOMOTICZ_OPTS))
	$(eval TZ := $(shell cat TZ))
	chmod 777 $(TMP)
	@docker run --name=$(NAME)-init \
	--cidfile="cid" \
	-e TZ=$(TZ) \
	-e DOMOTICZ_OPTS=$(DOMOTICZ_OPTS) \
	-v $(TMP):/tmp \
	--device=/dev/ttyUSB0 \
	--device=/dev/pts/0 \
	--privileged \
	--device=/dev/ttyUSB0 \
	--device=/dev/pts/0 \
	-d \
	-p $(PORT):8080 \
	-t $(TAG)

debugdocker:
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval TAG := $(shell cat TAG))
	$(eval DOMOTICZ_OPTS := $(shell cat DOMOTICZ_OPTS))
	$(eval TZ := $(shell cat TZ))
	chmod 777 $(TMP)
	@docker run --name=$(NAME)-init \
	--cidfile="cid" \
	-e TZ=$(TZ) \
	-e DOMOTICZ_OPTS=$(DOMOTICZ_OPTS) \
	-v $(TMP):/tmp \
	--privileged \
	--device=/dev/ttyUSB0 \
	--device=/dev/pts/0 \
	-d \
	-p $(PORT):8080 \
	-t $(TAG) /bin/bash


rundocker:
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval TZ := $(shell cat TZ))
	$(eval DOMOTICZ_OPTS := $(shell cat DOMOTICZ_OPTS))
	$(eval DATADIR := $(shell cat DATADIR))
	$(eval LOGDIR := $(shell cat LOGDIR))
	$(eval PORT := $(shell cat PORT))
	$(eval TAG := $(shell cat TAG))
	chmod 777 $(TMP)
	@docker run --name=$(NAME) \
	--cidfile="cid" \
	-v $(TMP):/tmp \
	-e TZ=$(TZ) \
	-e DOMOTICZ_OPTS=$(DOMOTICZ_OPTS) \
	--privileged \
	-d \
	--device=/dev/ttyUSB0 \
	--device=/dev/pts/0 \
	-p $(PORT):8080 \
	-v $(DATADIR)/config:/config \
	-v $(LOGDIR)/log:/log \
	-t $(TAG)

builddocker:
	docker build -t `cat TAG` .

kill:
	-@docker kill `cat cid`

rm-image:
	-@docker rm `cat cid`
	-@rm cid

rm: kill rm-image

clean: rm

enter:
	docker exec -i -t `cat cid` /bin/bash

logs:
	docker logs -f `cat cid`

rmall: rm

config: datadir/domoticz.db

datadir/domoticz.db:
	tar jxvf domoticz.db.tz2
	mkdir -p datadir
	mv domoticz.db datadir/

TZ:
	@while [ -z "$$TZ" ]; do \
		read -r -p "Enter the timezone you wish to associate with this container [America/Denver]: " TZ; echo "$$TZ">>TZ; cat TZ; \
	done ;

DOMOTICZ_OPTS:
	@while [ -z "$$DOMOTICZ_OPTS" ]; do \
		read -r -p "Enter the domoticz options you wish to associate with this container: " DOMOTICZ_OPTS; echo "$$DOMOTICZ_OPTS">>DOMOTICZ_OPTS; cat DOMOTICZ_OPTS; \
	done ;

PORT:
	@while [ -z "$$PORT" ]; do \
		read -r -p "Enter the port you wish to associate with this container [PORT]: " PORT; echo "$$PORT">>PORT; cat PORT; \
	done ;

LOGDIR:
	@while [ -z "$$LOGDIR" ]; do \
		read -r -p "Enter the datadir you wish to associate with this container (i.e. /exports/mkdomoticz) [LOGDIR]: " LOGDIR; echo "$$LOGDIR">>LOGDIR; cat LOGDIR; \
	done ;

DATADIR:
	@while [ -z "$$DATADIR" ]; do \
		read -r -p "Enter the datadir you wish to associate with this container (i.e. /exports/mkdomoticz) [DATADIR]: " DATADIR; echo "$$DATADIR">>DATADIR; cat DATADIR; \
	done ;

REGISTRY:
	@while [ -z "$$REGISTRY" ]; do \
		read -r -p "Enter the registry you wish to associate with this container [REGISTRY]: " REGISTRY; echo "$$REGISTRY">>REGISTRY; cat REGISTRY; \
	done ;

REGISTRY_PORT:
	@while [ -z "$$REGISTRY_PORT" ]; do \
		read -r -p "Enter the port of the registry you wish to associate with this container, usually 5000 [REGISTRY_PORT]: " REGISTRY_PORT; echo "$$REGISTRY_PORT">>REGISTRY_PORT; cat REGISTRY_PORT; \
	done ;

grab: DATADIR GRABDATADIR

GRABDATADIR:
	-@mkdir -p datadir/domoticz
	docker cp `cat cid`:/config  - |sudo tar -C datadir/ -pxf -

push: TAG REGISTRY REGISTRY_PORT
	$(eval TAG := $(shell cat TAG))
	$(eval REGISTRY := $(shell cat REGISTRY))
	$(eval REGISTRY_PORT := $(shell cat REGISTRY_PORT))
	docker tag $(TAG) $(REGISTRY):$(REGISTRY_PORT)/$(TAG)
	docker push $(REGISTRY):$(REGISTRY_PORT)/$(TAG)

pull:
	docker pull `cat TAG`

next: waitforport grab clean place run

place:
	$(eval DATADIR := $(shell cat DATADIR))
	mkdir -p $(DATADIR)
	sudo mv datadir $(DATADIR)/
	echo "$(DATADIR)/datadir" > DATADIR
	sync
	@echo "Moved datadir to $(DATADIR)"

waitforport:
	$(eval PORT := $(shell cat PORT))
	@echo "Waiting for port to become available"
	@while ! curl --output /dev/null --silent --head --fail http://127.0.0.1:$(PORT); do sleep 10 && echo -n .; done;
	@echo "check port $(PORT), it appears that now it is up!"

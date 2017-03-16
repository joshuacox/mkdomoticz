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
run:  TZ PORT rundocker

prod: run

temp: init

init: TZ PORT config pull initdocker

auto: init next

initdocker:
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval PORT := $(shell cat PORT))
	$(eval TAG := $(shell cat TAG))
	chmod 777 $(TMP)
	@docker run --name=$(NAME)-init \
	--cidfile="cid" \
	-v $(TMP):/tmp \
	--privileged \
	-d \
	-p $(PORT):8080 \
	-t $(TAG)

rundocker:
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval TZ := $(shell cat TZ))
	$(eval DATADIR := $(shell cat DATADIR))
	$(eval PORT := $(shell cat PORT))
	$(eval TAG := $(shell cat TAG))
	chmod 777 $(TMP)
	@docker run --name=$(NAME) \
	--cidfile="cid" \
	-v $(TMP):/tmp \
	-e TZ=$(TZ) \
	--privileged \
	-d \
	-p $(PORT):8080 \
	-v $(DATADIR)/config:/config \
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

PORT:
	@while [ -z "$$PORT" ]; do \
		read -r -p "Enter the port you wish to associate with this container [PORT]: " PORT; echo "$$PORT">>PORT; cat PORT; \
	done ;

REGISTRY:
	@while [ -z "$$REGISTRY" ]; do \
		read -r -p "Enter the registry you wish to associate with this container [REGISTRY]: " REGISTRY; echo "$$REGISTRY">>REGISTRY; cat REGISTRY; \
	done ;

REGISTRY_PORT:
	@while [ -z "$$REGISTRY_PORT" ]; do \
		read -r -p "Enter the port of the registry you wish to associate with this container, usually 5000 [REGISTRY_PORT]: " REGISTRY_PORT; echo "$$REGISTRY_PORT">>REGISTRY_PORT; cat REGISTRY_PORT; \
	done ;

grab: DATADIR

DATADIR:
	-@mkdir -p datadir/domoticz
	docker cp `cat cid`:/config  - |sudo tar -C datadir/ -pxf -
	echo `pwd`/datadir > DATADIR

push: TAG REGISTRY REGISTRY_PORT
	$(eval TAG := $(shell cat TAG))
	$(eval REGISTRY := $(shell cat REGISTRY))
	$(eval REGISTRY_PORT := $(shell cat REGISTRY_PORT))
	docker tag $(TAG) $(REGISTRY):$(REGISTRY_PORT)/$(TAG)
	docker push $(REGISTRY):$(REGISTRY_PORT)/$(TAG)

armbuild: build
	docker tag joshuacox/mkdomoticz joshuacox/mkdomoticz:arm
	docker push joshuacox/mkdomoticz:arm

pull:
	docker pull `cat TAG`

next: waitforport grab clean place run

place:
	mkdir -p /exports/mkdomoticz
	mv datadir /exports/mkdomoticz/
	echo '/exports/mkdomoticz/datadir' > DATADIR
	sync
	echo 'Moved datadir to /exports/mkdomoticz'

waitforport:
	$(eval PORT := $(shell cat PORT))
	@echo "Waiting for port to become available"
	@while ! curl --output /dev/null --silent --head --fail http://localhost:$(PORT); do sleep 10 && echo -n .; done;
	@echo "check port $(PORT), it appears that now it is up!"

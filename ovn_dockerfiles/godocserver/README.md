# GODOC SERVER


### About the **Selfcontained Godoc Server** use case

* Godoc server is contianerized to make it flexible and update based on the need
* Godoc server serves the new golang repositories
* Godoc refresh issue:- Server doesn't refresh even if the new files are pulled from bitbucket. The reason behind this is the browser. The browser sometimes cache the files, which makes the user feel that godoc server hasn't refreshed. 
* Above mentioned issue has been taken care by restarting the godoc server, whenever code is pulled from bitbucket.

#### Defaults
* Godoc server runs on 6060 port by default. 
* Currently Godoc server pulls the following repos:-
	*  ovn-client-profile
	*  ovn-components
	*  ovn-hsm-simulator
	*  ovn-iso-message
	*  ovn-mp-rules
	*  ovn-workspace
	*  ovn_config
	*  ovn_hsmwrapper
	*  ovn_mediator_new
	*  ovn_mptestingtool
	*  ovn_msgpostprocessor
	*  ovn_msgprocessor
	*  ovn_profilemanager
	*  ovn_reference
	*  ovn_timer
* The godoc server pulls the repos from bitbucket after 5 hours.

## Requirements
Docker
### Setup

1. Install [Docker](http://docker.io).
2. Clone this repository

### Build & Tag & Push to registry

```bash
$ cd godocserver
$ docker build -t godocserver .
```

```bash
$ docker images

# Determine the IMAGE ID to use in the next command matching the repository

$ docker tag "<<img-id>>" ovn-docker.artifactory.trusted.visa.com/godocserver
$ docker push ovn-docker.artifactory.trusted.visa.com/godocserver 
```


### Running the docker containers

```bash
$ docker run --name godocserver -d -p 6060:6060 ovn-docker.artifactory.trusted.visa.com/godocserver
```

### Testing
* Local:- Please check http://localhost:6060/pkg/
* VM:- http://<<IP/DNS>>:6060/pkg/


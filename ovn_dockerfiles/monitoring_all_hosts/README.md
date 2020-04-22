# Prometheus Monitoring System Service docker builder container

This container is where the Prometheus instance is running and scraping the metrics from all the OVN dev non-prod servers in  all the int-epics.

#### Defaults
* Prometheus exposes the metrics on port 9088 by default.
* Alertmanager is exposed on port 9087 by default.


## Setup

1a. Install [docker](http://docker.io).
1b. If you need to create a new config file to scrape from more IPs, install Jinja2 by running the command 'pip install Jinja2' and install [Go](https://golang.org/dl/).
2. Clone the ovn_dockerfiles repository.
3. If there are servers not previously configured to expose their metrics to Prometheus, follow steps 4-6.
4. Clone ovn_infrastructure and cd into the directory.
5. Run these two commands from the ocmmand line for each datacenter in each epic that you want to scrape metrics from.
	-Make sure to replace the epic number and datacenter number with the ones you want to deploy to
	-Your private key may be in a different location

```bash
# NODE_EXPORTER
ansible-playbook ansible_prometheus/deploy_node_exporter.yml -i inventories/int-epic1/dc1/hosts -u root --private-key ~/.ssh/id_dev

# NGINX:
ansible-playbook ansible_prometheus/deploy_nginx_for_exporter.yml -i inventories/int-epic6/dc2/hosts -u root --private-key ~/.ssh/id_dev

# generic command: ansible-playbook playbook-name.yml -i inventory -u root --private-key yourkey
```

In order for these commands to work, you must connect to each VM manually at least once. If there are 8 VMs in a datacenter that you have never connected to before, you need to ssh into each VM for a total of 8 times before you can successfully deploy the playbooks.

```bash
# ssh into 10.207.222.248 as root user
ssh root@10.207.222.248 -i ~/.ssh/id_dev
```

I have also included other errors that you may run into while deploying the playbooks at the end of this file.

## Create the config for Prometheus

In order for the Prometheus instance to scrape metrics from all the dev servers, run the following commands from the command line in the all_hosts directory to create the prometheus.yml file.

```bash
go run get_ips.go
jinja2 prometheus_config.yml.j2 all_hosts_ips.yml --format=yaml > prometheus.yml
```

Then, you need to move prometheus.yml to the correct directory by running the following command from the command line.

```bash
mv prometheus.yml prometheus
```

## Build the docker image from the command line

### On your local machine

Run the following commands in the all_hosts directory to build the docker image from the command line.

```bash
docker build -t "prometheus:all_hosts"

# generic command is: docker build -t "<REPOSITORY>:<TAG>"
```

You can check if the docker image was created by running 'docker images' and looking for your image repository and tag.

To run the container with permissions:

```bash
docker run --name mss -v /sys/fs/cgroup:/sys/fs/cgroup:ro --privileged -p 9088:9088 -p 9087:9087 -it prom_alert:all_hosts

# mapping ports: <port on local machine>:<port on VM>
# make sure the ports you are using are not already allocated to another service
```

You can check if the docker image was created by running 'docker ps' and looking for your container name.

### On a VM

SSH into a VM:

```bash
ssh sl73ovnapd045
#UED password

pmrun su -
#UPM password

mkdir -p /opt/app/data/monitoring_all_hosts/prometheus/data

mkdir -p /opt/app/data/monitoring_all_hosts/alertmanager/data

docker run --name monitoring_all_hosts -p 9055:9088 -d --privileged -v /opt/app/data/monitoring_all_hosts/prometheus/data:/opt/app/prometheus/data -v /opt/app/data/monitoring_all_hosts/alertmanager/data:/opt/app/alertmanager/data--restart=unless-stopped ovn-docker.artifactory.trusted.visa.com/monitoring_all_hosts:latest
```


## SSH-ing into the container

```bash
docker exec -it <mycontainerid> bash

# or ssh with root access
docker exec -u root -it <mycontainerid> bash
```

## Start Prometheus service

Once you are SSH-ed into the container, run the following commands.

```bash
systemctl start prometheus
systemctl status prometheus
# It will give you the error (code=exited, status=1/FAILURE)
# Run the command it gives you after ExecStart=<>

/opt/app/prometheus/prometheus/prometheus --log.level info --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /opt/app/prometheus/data --storage.tsdb.retention 10d --web.external-url http://127.0.0.1/prometheus --web.listen-address :9088 --web.enable-admin-api

```


## Setting up Firewall B access

Install telnet with 'yum install telnet'. Then run 'telnet 10.199.56.20 259' which will then prompt you to use <Visa Domain Login ID>@idb and a OTP(One Time Password), then press 1.


## Helpful Tips

Check if a service is running once you have ssh-ed in:
```bash
# generic command: systemctl status <<service>>
# example:
systemctl status node_exporter
```

If you need to edit the prometheus or alertmanager config while the container is running, you can use the commands 'ps ax | grep prometheus' to get the process id of the service you want to restart, then run 'kill -HUP <process id>'.

### Common errors when trying to deploy a playbook

Check if there is any disk space left and specifically check the /var directory by running 'df' while ssh-ed in the VM.

The server most likely needs to be cleaned of old logs and such.

If elasticsearch is installed on the VM, a quick workaround is to run the following commands while ssh-ed in the VM.
```bash
cd /etc/nginx/conf.d
mv default.conf default.conf.20180813

# replace with current date in the form .YearMonthDay
```






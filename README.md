# Routing on Docker

This repository will introduce how to build your network on Docker.

## Usage

1. Install Docker ,Docker compose and Git
```
curl -fsSL https://get.docker.com/ | sh
systemctl enable docker
systemctl start docker
apt-get install -y docker-compose
apt-get install -y git
```

2. Build your FRRouting:
```
git clone https://github.com/paulmao1/Routing-on-Docker.git
cd Routing-on-Docker/FRR
docker build --network host -t <your docker image> .
```

3. Run a docker container for testing:
```
docker run -itd --privileged -p 179:179 <your imaghe>
```

4. Run a simple lab for testing:
```
cd ..
docker-compose up 
```

5. Run a ospf-eigrp redistribution lab using scripts:
```
cd  OSPF-EIGRP
perl ospf-eigrp.pl -n 2 > docker-compose.yml
docker-compose up 
```
6. Monitor router usage using Prometheus and Grafana
```
docker run --name cadvisor --volume=/:/rootfs:ro --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro -p 8080:8080 -d  google/cadvisor:latest
docker run -d -p 9090:9090 --name prometheus  -v $PWD/monitor/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
docker run -d -p 3000:3000 --name grafana grafana/grafana
```
7. Run a EVPN lab using  scripts
```
cd  EVPN
perl evpn.pl -n 3 > docker-compose.yml
docker-compose up 
```
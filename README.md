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
perl ospf-igrp.pl -n 2 > docker-compose.yml
docker-compose up 
```
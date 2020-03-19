#!/usr/bin/perl
#    ASBR1 and ASBR2 run ospf and eigrp
#    R1 and R2 run ospf, R3 and R4 run eigrp
use Getopt::Std;
getopts('n:h');

#Usage
if ($opt_h || !$opt_n) {
  print <<EOF;
Usage: $0 -n <number of instances>
EOF
  exit;
}

#define ASBR router
print <<EOF;
version: '2.2'
services:
  asbr-r01:
    image: paulmao1/tools:frrouting
    hostname: asbr-r01
    container_name: asbr-r01 
    volumes:
      - ./config/asbr-r01:/etc/frr
    cap_add:
      - ALL
    networks:
      eth1:
      ospf:
        ipv4_address: 192.168.100.253
      eigrp:
        ipv4_address: 192.168.110.253
  asbr-r02:
    image: paulmao1/tools:frrouting
    hostname: asbr-r02
    container_name: asbr-r02
    cap_add:
      - ALL
    volumes:
      - ./config/asbr-r02:/etc/frr
    networks:
      eth1:
      ospf:
        ipv4_address: 192.168.100.254
      eigrp:
        ipv4_address: 192.168.110.254

EOF


#define OSPF Router and Configuration
for ($i = 1; $i <= $opt_n; $i++) {
  my $nodestr = sprintf "%02d",$i;
  
  print <<EOF;
  ospf-r$nodestr:      
    image: paulmao1/tools:frrouting
    hostname: ospf-r$nodestr
    container_name: ospf-r$nodestr
    volumes:
      - ./config/ospf-r$nodestr:/etc/frr
    cap_add:
      - ALL
    networks:
      eth1:
      ospf:
        ipv4_address: 192.168.100.1$nodestr

EOF

  # create ospf configuration
  system("mkdir -p config/ospf-r$nodestr");
  open(OUT,">config/ospf-r$nodestr/frr.conf");
print OUT <<EOF;
hostname ospf-r$nodestr
!
interface lo
  ip address 172.16.1$i.1/32
!
interface eth1
!
router ospf 
  ospf router-id 172.16.1$i.1
  log-adjacency-changes
  network 192.168.100.0/24 area 0
  network 172.16.1$i.1/32 area 0
!
EOF

  #define daemons
  open(OUT,">config/ospf-r$nodestr/daemons");
print OUT <<EOF;
#
zebra=yes
bgpd=no
ospfd=yes
ospf6d=no
ripd=no
ripngd=no
isisd=no
ldpd=no
pimd=no
nhrpd=no
eigrpd=no
babeld=no
sharpd=no
pbrd=no
staticd=yes
bfdd=no
EOF
  #define vtysh
  open(OUT,">config/ospf-r$nodestr/vtysh.conf");
print OUT <<EOF;
!
! Sample configuration file for vtysh.
!
!service integrated-vtysh-config
!hostname quagga-router
!username root nopassword
!
!interface dummy0
EOF

  close OUT;
  system("chmod 777 config/ospf-r$nodestr");
  system("chmod 666 config/ospf-r$nodestr/*");
}

#define EIGRP Router and Configuration
for ($i = 1; $i <= $opt_n; $i++) {
  my $nodestr = sprintf "%02d",$i;
  print <<EOF;
  eigrp-r$nodestr:      
    image: paulmao1/tools:frrouting
    hostname: eigrp-r$nodestr
    container_name: eigrp-r$nodestr
    volumes:
      - ./config/eigrp-r$nodestr:/etc/frr
    cap_add:
      - ALL
    networks:
      eth1:
      eigrp:
        ipv4_address: 192.168.110.1$nodestr

EOF

  # create eigrp configuration
  system("mkdir -p config/eigrp-r$nodestr");
  open(OUT,">config/eigrp-r$nodestr/frr.conf");
print OUT <<EOF;
hostname eigrp-r$nodestr
!
interface lo
  ip address 172.16.2$i.1/32
!
interface eth1
!
router eigrp 1 
  eigrp router-id 172.16.2$i.1
  no auto-summary
  log-adjacency-changes
  network 192.168.110.0/24
  network 172.16.2$i.1/32
  no auto
!
EOF

  #define daemons
  open(OUT,">config/eigrp-r$nodestr/daemons");
print OUT <<EOF;
#
zebra=yes
bgpd=no
ospfd=no
ospf6d=no
ripd=no
ripngd=no
isisd=no
ldpd=no
pimd=no
nhrpd=no
eigrpd=yes
babeld=no
sharpd=no
pbrd=no
staticd=yes
bfdd=no
EOF
  #define vtysh
  open(OUT,">config/eigrp-r$nodestr/vtysh.conf");
print OUT <<EOF;
!
! Sample configuration file for vtysh.
!
!service integrated-vtysh-config
!hostname quagga-router
!username root nopassword
!
!interface dummy0
EOF

  close OUT;
  system("chmod 777 config/eigrp-r$nodestr");
  system("chmod 666 config/eigrp-r$nodestr/*");
}

#define ASBR Configuration
for ($i = 1; $i <= 2; $i++) {
  my $nodestr = sprintf "%02d",$i;
  system("mkdir -p config/asbr-r$nodestr");
  open(OUT,">config/asbr-r$nodestr/frr.conf");
print OUT <<EOF;
hostname asbr-r$nodestr
!
interface lo
  ip address 172.16.3$i.1/32
!
interface eth1
！
interface eth2
  ip ospf priority 100
router ospf 
  ospf router-id 172.16.3$i.1
  log-adjacency-changes
  network 192.168.100.0/24 area 0
router eigrp 1
  eigrp router-id 172.16.3$i.1
  log-adjacency-changes
  network 192.168.110.0/24
  no auto-summary
EOF
  #define daemons
  open(OUT,">config/asbr-r$nodestr/daemons");
print OUT <<EOF;
#
zebra=yes
bgpd=no
ospfd=yes
ospf6d=no
ripd=no
ripngd=no
isisd=no
ldpd=no
pimd=no
nhrpd=no
eigrpd=yes
babeld=no
sharpd=no
pbrd=no
staticd=yes
bfdd=no
EOF
  open(OUT,">config/asbr-r$nodestr/vtysh.conf");
print OUT <<EOF;
! Sample configuration file for vtysh.
!
!service integrated-vtysh-config
!hostname quagga-router
!username root nopassword
!
!interface dummy0
EOF

system("chmod 777 config/asbr-r$nodestr");
system("chmod 666 config/asbr-r$nodestr/*");
}

#define network
print <<EOF;
networks:
  eth1:
  ospf:
    ipam:
      config:
        - subnet: 192.168.100.0/24
  eigrp:
    ipam:
      config:
        - subnet: 192.168.110.0/24
EOF

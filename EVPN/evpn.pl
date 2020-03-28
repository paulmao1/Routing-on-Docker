#!/usr/bin/perl
#    All the Routers run as  64500
use Getopt::Std;
getopts('n:h');

#Usage
if ($opt_h || !$opt_n) {
  print <<EOF;
Usage: $0 -n <number of instances>
EOF
  exit;
}

#define Spine Router and  RR
print <<EOF;
version: '2.2'
services:
  Spine:
    image: paulmao1/tools:frrouting
    hostname: Spine
    container_name: Spine
    cap_add:
      - ALL
    volumes:
      - ./config/spine:/etc/frr
    networks:
      eth1:
      RR-Leaf01:
        ipv4_address: 192.168.11.254
      RR-Leaf02:
        ipv4_address: 192.168.12.254
      RR-Leaf03:
        ipv4_address: 192.168.13.254
EOF


#define Leaf Tor Router
for ($i = 1; $i <= $opt_n; $i++) {
  my $nodestr = sprintf "%02d",$i;
  
  print <<EOF;
  Leaf$nodestr:      
    image: paulmao1/tools:frrouting
    hostname: Leaf$nodestr
    container_name: Leaf$nodestr
    cap_add:
      - ALL
    volumes:
      - ./config/leaf$nodestr:/etc/frr
    networks:
      eth1:
      RR-Leaf$nodestr:
        ipv4_address: 192.168.1$i.2

EOF

  # create and populate the volumes
  system("mkdir -p config/leaf$nodestr");
  open(OUT,">config/leaf$nodestr/frr.conf");
print OUT <<EOF;
hostname Leaf$nodestr
!
interface lo
  ip address 172.16.1$i.1/32
!
router ospf 
  ospf router-id 172.16.1$i.1
  log-adjacency-changes
  network 192.168.1$i.0/24 area 0
!
router bgp 64500
  no bgp default ipv4-unicast
  neighbor upstream peer-group
  neighbor 192.168.1$i.254 remote-as 64500
  neighbor 192.168.1$i.254 peer-group upstream
  address-family ipv4 unicast
    neighbor upstream activate
    exit-address-family
  address-family l2vpn evpn
    neighbor upstream activate
    advertise-all-vni
    exit-address-family
!
EOF

  #define daemons
  open(OUT,">config/leaf$nodestr/daemons");
print OUT <<EOF;
#
zebra=yes
bgpd=yes
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
  open(OUT,">config/leaf$nodestr/vtysh.conf");
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
  system("chmod 777 config/leaf$nodestr");
  system("chmod 666 config/leaf$nodestr/*");
}



#define Spine Configuration
system("mkdir -p config/spine");
system("cp config/leaf01/daemons config/spine");
system("cp config/leaf01/vtysh.conf config/spine");

open(OUT,">config/spine/frr.conf");
print OUT <<EOF;
hostname Spine
!
interface lo
 ip address 172.16.254.1/32
!
router ospf 
  ospf router-id 172.16.254.1
  log-adjacency-changes
  network 192.168.11.0/24 area 0
  network 192.168.12.0/24 area 0
  network 192.168.13.0/24 area 0
!
router bgp 64500
 no bgp default ipv4-unicast
 neighbor downstream peer-group
EOF

for ($i = 1; $i <= $opt_n; $i++) {
  my $nodestr = sprintf "%02d",$i;
  print OUT <<EOF;
 neighbor 192.168.1$i.2 remote-as 64500
 neighbor 192.168.1$i.2 peer-group downstream
EOF
}
#define ipv4 address-family
print OUT <<EOF;
 !
 address-family ipv4 unicast
  neighbor downstream activate
  neighbor downstream route-reflector-client
EOF

#define EVPN address-family
print OUT <<EOF;
 !
 address-family l2vpn evpn
  neighbor downstream activate
  neighbor downstream route-reflector-client 
EOF


system("chmod 777 config/spine");
system("chmod 666 config/spine/*");


#define network
print <<EOF;
networks:
  RR-Leaf01:
    ipam:
      config:
        - subnet: 192.168.11.0/24
  RR-Leaf02:
    ipam:
      config:
        - subnet: 192.168.12.0/24
  RR-Leaf03:
    ipam:
      config:
        - subnet: 192.168.13.0/24
EOF

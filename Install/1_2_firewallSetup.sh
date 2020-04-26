#!/bin/bash

#Clear current setup
nft flush ruleset
#Add new config
nft add table inet filter
#Base chains(input, forward, output). Input + Forward = block. Output = accept
nft add chain inet filter input '{ type filter hook input priority 0 ; policy drop ; }'
nft add chain inet filter forward '{ type filter hook forward priority 0 ; policy drop ; }'
nft add chain inet filter output '{ type filter hook output priority 0 ; policy accept ; }'
#Usual(TCP+UDP) chains.
nft add chain inet filter TCP
nft add chain inet filter UDP
#Allow related and established traffic
nft add rule inet filter input ct state related,established accept
#Allow looping traffic
nft add rule inet filter input iif lo accept
#Block invalid traffic
nft add rule inet filter input ct state invalid drop
#Allow ICMP and IGMP
nft add rule inet filter input meta l4proto ipv6-icmp icmpv6 type '{ destination-unreachable, packet-too-big, time-exceeded, parameter-problem, mld-listener-query, mld-listener-report, mld-listener-reduction, nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, ind-neighbor-solicit, ind-neighbor-advert, mld2-listener-report }' accept
nft add rule inet filter input meta l4proto icmp icmp type '{ destination-unreachable, router-solicitation, router-advertisement, time-exceeded, parameter-problem }' accept
nft add rule inet filter input ip protocol igmp accept
#New UDP traffic will be forwarded toward UDP chain
nft add rule inet filter input meta l4proto udp ct state new jump UDP
#New TCP traffic will be forwarded toward TCP chain
nft add rule inet filter input 'meta l4proto tcp tcp flags & (fin|syn|rst|ack) == syn ct state new jump TCP'
#Block the rest
nft add rule inet filter input meta l4proto udp reject
nft add rule inet filter input meta l4proto tcp reject with tcp reset
nft add rule inet filter input counter reject with icmpx type port-unreachable

#Optional. Choose ports which will be opened and handled by TCP,UDP.
#Web server(80 port)
# nft add rule inet filter TCP tcp dport 80 accept
#Web server(443 port)
# nft add rule inet filter TCP tcp dport 443 accept
#SHH port
# nft add rule inet filter TCP tcp dport 22 accept
#Inbound DNS queries
# nft add rule inet filter TCP tcp dport 53 accept
# nft add rule inet filter UDP udp dport 53 accept

#Save config
nft -s list ruleset | tee $1

#Enable nftables
systemctl enable nftables

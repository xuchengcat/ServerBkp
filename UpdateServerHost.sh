#!/bin/bash
# this shell used to change host of xuchengcat.cn using zerotier and smartDNS.
# it should run periodly, when can not connect to xuchengcat.cn, try to get new host address every 1 hour 
# change config below
ZeroTierToken="jQYD33GvsXNnRgi2HLAXvAccBsqfumpN"
NWID="abfd31bd470eb354" #network ID in zerotier
MBID="5664493eae" # home server member ID in zerotier
# Path to SmartDNS config file
SMARTDNS_CONF="/etc/smartdns/smartdns.conf"

# IPV6 Regex
ipv6_pattern='^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$'

# Make API request to get network members
physical_addr=$(curl -s -X GET "https://api.zerotier.com/api/v1/network/$NWID/member/$MBID" \
     -H "Authorization: token $ZeroTierToken" \
     -H "Content-Type: application/json" | \
     jq -r '.physicalAddress')

if echo "$physical_addr" | grep -Eq "$ipv6_pattern"; then
    # Remove old entry if exists
    # sed -i '/address \/xuchengcat.cn\//d' $SMARTDNS_CONF
    
    # Add new IPv6 host record
    # echo "address /xuchengcat.cn/$physical_addr" >> $SMARTDNS_CONF
    
    # Restart SmartDNS service
    # systemctl restart smartdns
    
    echo "Added IPv6 host record for xuchengcat.cn to SmartDNS"
    echo "Host record: xuchengcat.cn -> $physical_addr"
else
    echo "Not an IPv6 address: $physical_addr"
fi

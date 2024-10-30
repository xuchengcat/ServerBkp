#!/bin/bash
ZeroTierToken="jQYD33GvsXNnRgi2HLAXvAccBsqfumpN"
NWID="abfd31bd470eb354"
MBID="5664493eae" # home server

# APNS Configuration
TOKEN_KEY_FILE_NAME="./BARKAuthKey.key"  # 需要填写实际的key文件路径
DEVICE_TOKEN="b9b51d973e2e674df800039dd58b9e193a916a831875db569603689f1dd5c01b"  # 你的设备token
TEAM_ID="5U8LBRXG3A"
AUTH_KEY_ID="LH4T9V5U4R"
TOPIC="me.fin.bark"
APNS_HOST_NAME="api.push.apple.com"

# Function to generate APNS token
generate_apns_token() {
    JWT_ISSUE_TIME=$(date +%s)
    JWT_HEADER=$(printf '{ "alg": "ES256", "kid": "%s" }' "${AUTH_KEY_ID}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
    JWT_CLAIMS=$(printf '{ "iss": "%s", "iat": %d }' "${TEAM_ID}" "${JWT_ISSUE_TIME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
    JWT_HEADER_CLAIMS="${JWT_HEADER}.${JWT_CLAIMS}"
    JWT_SIGNED_HEADER_CLAIMS=$(printf "${JWT_HEADER_CLAIMS}" | openssl dgst -binary -sha256 -sign "${TOKEN_KEY_FILE_NAME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
    echo "${JWT_HEADER}.${JWT_CLAIMS}.${JWT_SIGNED_HEADER_CLAIMS}"
}

# Function to send APNS notification
send_notification() {
    local title="$1"
    local body="$2"
    local AUTHENTICATION_TOKEN=$(generate_apns_token)
    
    # Prepare JSON payload
    local payload=$(cat <<EOF
{
    "aps": {
        "alert": {
            "title": "${title}",
            "body": "${body}"
        },
        "sound": "default",
        "badge": 1
    }
}
EOF
)
    
    curl -v \
        --header "apns-topic: $TOPIC" \
        --header "apns-push-type: alert" \
        --header "authorization: bearer $AUTHENTICATION_TOKEN" \
        --data "$payload" \
        --http2 \
        "https://${APNS_HOST_NAME}/3/device/${DEVICE_TOKEN}"
}

# Path to SmartDNS config file
SMARTDNS_CONF="/etc/smartdns/smartdns.conf"
# IPV6 Regex
ipv6_pattern='^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$'

# Initialize ping failure counter
ping_failures=0

while true; do
    # Try to ping xuchengcat.cn
    if ! ping -c 1 xuchengcat.cn &> /dev/null; then
        ((ping_failures++))
        echo "$(date): Ping attempt $ping_failures failed"
        
        # Only proceed if we've had 10 consecutive failures
        if [ $ping_failures -ge 10 ]; then
            echo "$(date): Cannot connect to xuchengcat.cn after 10 attempts, trying to update host..."
            
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
                
                echo "$(date): Added IPv6 host record for xuchengcat.cn to SmartDNS"
                echo "$(date): Host record: xuchengcat.cn -> $physical_addr"
            else
                # Send notification when not an IPv6 address
                send_notification "DNS更新失败" "获取到无效IP地址: ${physical_addr}"
                echo "$(date): Not an IPv6 address: $physical_addr"
            fi
            
            # Reset failure counter after attempting fix
            ping_failures=0
        fi
    else
        # Reset failure counter on successful ping
        if [ $ping_failures -gt 0 ]; then
            echo "$(date): Connection restored after $ping_failures failures"
        fi
        ping_failures=0
    fi

    # Sleep for 1 hour
    sleep 5
done

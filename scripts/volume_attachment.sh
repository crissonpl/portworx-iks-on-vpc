#!/bin/bash

# Before creating, check to see if attachment for volume is already present 
ID=$(
    curl -s -X GET -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -H "X-Auth-Resource-Group-ID: $RESOURCE_GROUP_ID" \
        "https://$REGION.containers.cloud.ibm.com/v2/storage/getAttachments?cluster=$CLUSTER_ID&worker=$WORKER_ID" | jq -r --arg VOLUMEID "$VOLUME_ID" '.volume_attachments[] | select(.volume.id==$VOLUMEID) | .id'
)

if [ "$ID" == "" ] || [ "$ID" == "null" ]; then 
    echo "Error when trying to /getAttachments"
fi

# If should create attachment, create attachment
if [ "$ID" == "" ] || [ "$ID" == "null" ]; then 
    RESPONSE=$(
        curl -s -X POST -H "Authorization: $TOKEN" \
            "https://$REGION.containers.cloud.ibm.com/v2/storage/vpc/createAttachment?cluster=$CLUSTER_ID&worker=$WORKER_ID&volumeID=$VOLUME_ID"
    )

    ID=$(echo $RESPONSE | jq -r .id)

    if [ "$ID" == "" ] || [ "$ID" == "null" ]; then 
        echo "Error when trying to /createAttachment: $RESPONSE"
    fi
fi

echo "Created attachment for $CLUSTER_ID, $WORKER_ID and $VOLUME_ID: $ID"
#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-06d7a31f9f5bef8e7" #replace with your SG_ID
ZONE_ID="Z0800790L23FXQOEPKUR" # replace with your ZONE_ID
DOMAIN_ID="ayaansh123.fun"

for instance in @
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    #Get private Ip
    if [ $instance != "frontend" ];then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME" #mongodb.ayaansh123.fun
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$DOMAIN_NAME" #ayaansh123.fun
    fi

    echo "$instance: $IP"

    aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Testing creating a record set"
    ,"Changes": [{
      "Action"              : “UPSERT”
      ,"ResourceRecordSet"  : {
        "Name"              : “‘$RECORD_NAME’”
        ,"Type"             : “A”
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : “‘$IP'”
        }]
      }
    }]
  }
  '
done

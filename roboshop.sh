#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0d08e55eae8705e65"

for instance in $@

do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0d08e55eae8705e65 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids i-0682bd1dbd92ce16c --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
         IP=$(aws ec2 describe-instances --instance-ids i-0682bd1dbd92ce16c --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi
        echo ""

done

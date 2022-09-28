#!/bin/bash


aws ec2 create-tags \
    --resources $1 \
    --tags Key="kubernetes.io/cluster/$2",Value="owned" Key="kubernetes.io/role/internal-elb",Value="1"

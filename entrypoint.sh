#!/bin/bash
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
ASGNAME=$(aws autoscaling describe-auto-scaling-instances --region=$EC2_REGION | grep AutoScalingGroupName | tail -1 | cut -d '"' -f 4)

function getip {
        for i in `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASGNAME --region=$EC2_REGION | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g'`
        do
                aws ec2 describe-instances --instance-ids $i --region=$EC2_REGION | grep -i PrivateIpAddress | awk '{ print $2 }' | head -1 | cut -d '"' -f2 |  xargs printf '%s\n'
        done;
}

getip > newetcdips.txt

realclustersize=$(cat newetcdips.txt | wc -l)

true > zones.txt

for (( i = 1; i <= $realclustersize; i++ )); do
  echo "etcd$i IN A etcdip$i" >> zones.txt
  echo "etcd IN A etcdip$i" >> zones.txt
  echo "_etcd-client._tcp IN SRV 0 0 2379 etcd$i" >> zones.txt
  echo "_etcd-server-ssl._tcp IN SRV 0 0 2380 etcd$i" >> zones.txt
  etcdip=$(sed -n $i\p newetcdips.txt)
  sed -i "s/etcdip$i/${etcdip}/g" zones.txt;
done

echo "$(cat zones.txt | sort -n)" > zones.txt

## ENTRYPOINT

cli53 import --file zones.txt --replace --wait $1

## Usage $1 is the TLD

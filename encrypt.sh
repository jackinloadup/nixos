#!/usr/bin/env bash

## declare an array variable
declare -a hosts=(
  "marulk"
  "reg"
  "lyza"
  "riko"
  "kanye"
  "timberlake"
  "zen"
  "nat"
  "gumdrop-nas"
  "chichi"
)

## now loop through the above array
for i in "${hosts[@]}"
do
   echo "$i"
   # or do whatever with individual element of the array
   if [ -f ~/Projects/secrets/machines/$i/ssh-host/ssh_host_ed25519_key ]; then
     echo "$i ssh-host"
     cat ~/Projects/secrets/machines/$i/ssh-host/ssh_host_ed25519_key | ragenix --editor - -e secrets/machines/$i/sshd/private_key.age
   fi
   if [ -f ~/Projects/secrets/machines/$i/init-ssh-host/ssh_host_ed25519_key ]; then
     echo "$i init-ssh-host"
     cat ~/Projects/secrets/machines/$i/init-ssh-host/ssh_host_ed25519_key | ragenix --editor - -e secrets/machines/$i/init-sshd/private_key.age
   fi
done


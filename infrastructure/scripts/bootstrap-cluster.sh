#!/bin/bash

# test if helm fluxctl, linkerd exists
# bail if not
for p in flux linkerd helm
do
    if ! hash $p 2>/dev/null
    then
        echo "$p was not found in PATH"
        exit 1
    fi
done;

aws eks update-kubeconfig --name $1


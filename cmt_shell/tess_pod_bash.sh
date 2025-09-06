#!/bin/bash

echo "进入前tess pod";
tess kubectl exec -it $1 -- /bin/bash

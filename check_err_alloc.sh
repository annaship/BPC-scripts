#!/bin/bash

grep -i alloc $1/clustergast.log  | sort -u
grep -i err $1/clustergast.log  | sort -u 


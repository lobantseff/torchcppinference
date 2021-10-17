#!/bin/bash
set -e
exec docker run --rm -v $(pwd):/mnt torchcppinference $1


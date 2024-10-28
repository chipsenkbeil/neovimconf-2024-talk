#!/usr/bin/env bash

PRESENTERM=presenterm
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
$PRESENTERM -x -X "$SCRIPT_DIR/presentation.md"

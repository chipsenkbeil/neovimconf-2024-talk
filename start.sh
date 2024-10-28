#!/usr/bin/env bash

#
# STARTS THE PRESENTATION
#

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
nvim -u "$SCRIPT_DIR/scripts/000_all.lua" +":terminal presenterm -x -X '$SCRIPT_DIR/presentation.md'"

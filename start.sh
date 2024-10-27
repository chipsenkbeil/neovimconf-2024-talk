#!/usr/bin/env bash

#
# STARTS THE PRESENTATION
#

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
nvim +":terminal presenterm -x '$SCRIPT_DIR/presentation.md'"

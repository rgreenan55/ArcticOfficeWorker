#!/bin/sh
echo -ne '\033c\033]0;Arctic Office Worker\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/ArcticOfficeWorker_Linux.x86_64" "$@"

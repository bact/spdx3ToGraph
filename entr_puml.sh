#!/usr/bin/env nix-shell
#! nix-shell -i bash -p entr plantuml sxiv
set -euo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"

spdx="$1"
puml="$spdx.puml"
png="$spdx.png"

export spdx
export puml
entr_task() (
  set -ex
  nix develop --command poetry run python -m spdx3_to_graph -- -v "$spdx"
  plantuml "$puml"
)
export -f entr_task

if [[ ! -f "$puml" || ! -f "$png" ]]; then
  entr_task "$spdx"
fi

sxiv "$png" & 
trap 'kill $(jobs -p)' EXIT

while sleep 1; do
  cat <<EOF | entr -dr bash -c entr_task
$(find spdx3_to_graph/ -iname '*.py')
$1
EOF
done

#!/bin/bash

{

set -eo pipefail

ys=$1
list="eobs mswep cpc gpcc cru"

for l in $list; do
  echo $l ...
  bash prepare_${l}.sh $ys
  bash prepare-pdf_${l}.sh $ys
  echo $l completed .
done

}

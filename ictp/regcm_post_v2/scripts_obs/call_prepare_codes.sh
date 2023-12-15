#!/bin/bash

{

set -eo pipefail

ys=2018-2021
list="cpc cru"
for l in $list; do
  echo $l ...
  bash prepare_${l}.sh $ys
  bash prepare_pdf_${l}.sh $ys
  echo $l completed .
done

}

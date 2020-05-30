#!/bin/bash

getIcon() {
    case $1 in
        USD) icon="$";;
        EUR) icon="€";;
        *)   icon="";
    esac

    echo $icon
}

getRate() {
    local __resultRate=$2
    local __resultTooltip=$3
    local request=$(curl -s "https://www.nbrb.by/api/exrates/rates/$1?parammode=2")

    eval $__resultRate="'$(getIcon "$1")" "$(echo "$request" | jq .Cur_OfficialRate)'"
    eval $__resultTooltip="'$(echo "$request" | jq '((.Cur_OfficialRate|tostring) + " " + .Cur_Abbreviation)')'"
}

result=""
tooltip=""
getRate $1 result tooltip
shift

while [ -n "$1" ]
do
    getRate $1 tempresult temptooltip
    result+="|$tempresult"
    tooltip+="|$temptooltip"
    shift
done

printf "$result\n$tooltip\ncurrencies"

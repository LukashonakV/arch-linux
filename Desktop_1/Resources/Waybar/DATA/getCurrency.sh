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
    local Cur_OfficialRate=$(echo "$request" | jq .Cur_OfficialRate)
  
    eval $__resultRate="'$(getIcon "$1") $Cur_OfficialRate'"
    eval $__resultTooltip="'$1 $Cur_OfficialRate'"

    local ondate="&ondate="$(date -d "1 day" +"%Y-%m-%d")
    local request_ondate=$(curl -s "https://www.nbrb.by/api/exrates/rates/$1?parammode=2$ondate")
    local Cur_OfficialRate_onDate=$(echo "$request_ondate" | jq .Cur_OfficialRate)

    if [[ $(echo $Cur_OfficialRate | sed 's/\./,/') -gt $(echo $Cur_OfficialRate_onDate | sed 's/\./,/' ) ]]; then
        eval $__resultRate+=""
        eval $__resultTooltip+=""
    fi

    if [[ $(echo $Cur_OfficialRate | sed 's/\./,/') -lt $(echo $Cur_OfficialRate_onDate | sed 's/\./,/' ) ]]; then
        eval $__resultRate+=""
        eval $__resultTooltip+=""
    fi

    if [[ $(echo $Cur_OfficialRate | sed 's/\./,/') -ne $(echo $Cur_OfficialRate_onDate | sed 's/\./,/' ) ]]; then
        eval $__resultTooltip+="'$Cur_OfficialRate_onDate'"
    fi
}

result=""
tooltip=""
getRate $1 result tooltip
shift

while [ -n "$1" ]
do
    getRate $1 tempresult temptooltip
    tooltip+="|$temptooltip"
    shift
done

printf "$result\n$tooltip\ncurrencies"

#!/bin/bash

function get_value() {
    local path=$1
    local name=$2

    cat $path | grep "<$name>" | sed -e "s,.*<$name>\(.*\)</$name>.*,\1," | head -n 1
}


path=$1

if [ ! -f "$path" ]; then
    echo "Usage: $0 path-file.cfg"
    exit 1
fi
xml=$(cat $path | grep -v "<?xml" | tr -d '\r' | tr -d '\n' | sed -e 's/<\(\w\+\)\s*\/>/<\1><\/\1>/g')

formatter=' <?xml version="1.0"?>'
nspaces=1

function decomp() {
    local parent=$2

    eval `echo "$1" | sed -e "s,<\(\w\+\)\([^>]*\)>\s*\(.*\)\s*</\1>\s*\(.*\)\s*,local KEY='\1';local ATTRS='\2';local VALUE='\3';\1='\3';local REST='\4',"`

    if [[ "$VALUE" =~ ^\<.* ]]; then
        formatter="$formatter$(printf \\n%${nspaces}s)<$KEY$ATTRS>"
        nspaces=$((nspaces + 2))
        eval "${KEY}_MENU=\"--clear --title $KEY --menu $KEY 50 100 4 \""
        decomp "$VALUE" ${KEY}_MENU
        nspaces=$((nspaces - 2))
        formatter="$formatter$(printf \\n%${nspaces}s)</$KEY>"
        eval "${KEY}=\"<...>\""
    else
        formatter="$formatter$(printf \\n%${nspaces}s)<$KEY>\$$KEY</$KEY>"
    fi
    eval "$parent=\"\$$(echo "$parent")$(echo) $KEY \\\"\\\$$KEY\\\"\""

    if [[ "$REST" =~ ^\<.* ]]; then
        decomp "$REST" $parent
    fi
}

decomp "$xml" XML

function menu() {
    local MENU=$1
    local last=""
    local lastval=""

    if [ -z "$MENU" ]; then
        return
    fi

    while : ; do
        eval "$(eval echo "dialog --default-item \"$last\" \$${MENU}_MENU")" 2>/tmp/dialog.result
        if [ $? != 0 ]; then
            break
        fi

        last="$(cat /tmp/dialog.result)"
        lastval="$(eval echo "\$${last}")"
        if [ ! -z "$(eval echo "\$${last}_MENU")" ]; then
            menu $last
        elif [ "$lastval" == "true" ]; then
            eval "$last=false"
        elif [ "$lastval" == "false" ]; then
            eval "$last=true"
        elif [[ "$lastval" =~ ^[0-9]+$ ]]; then
            while : ; do
                dialog --title "$last" --clear --inputbox "Enter a Whole Number" 10 50 "$lastval" 2>/tmp/dialog.result
                if [ $? != 0 ]; then
                    break
                fi
                lastval=$(cat /tmp/dialog.result)
                if [[ "$lastval" =~ ^[0-9]+$ ]]; then
                    eval "$last=$lastval"
                    break
                fi
            done
        elif [[ "$lastval" =~ ^[0-9.]+$ ]]; then
            while : ; do
                dialog --title "$last" --clear --inputbox "Enter a Number" 10 50 "$lastval" 2>/tmp/dialog.result
                if [ $? != 0 ]; then
                    break
                fi
                lastval=$(cat /tmp/dialog.result)
                if [[ "$lastval" =~ ^[0-9.]+$ ]]; then
                    eval "$last=$lastval"
                    break
                fi
            done
        else
            dialog --title "$last" --clear --inputbox "" 10 50 "$lastval" 2>/tmp/dialog.result
            if [ $? == 0 ]; then
                lastval="$(cat /tmp/dialog.result | sed -e 's/\\/\\\\/g')"
                eval "$last=\"$lastval"
            fi
        fi
    done

    dialog --clear
}

menu MyConfigDedicated

#ServerName="MAgical FunTimes!"
eval "echo \"$formatter\"" | sed -e's/^ //'

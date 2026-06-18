#!/bin/bash

CONFIG="$HOME/.config/niri/struts.kdl"

#niri msg action do-screen-transition

sed -i -E 's/^([[:space:]]*top )0$/\118/; t; s/^([[:space:]]*top )18$/\10/' "$CONFIG"

if grep -q '^[[:space:]]*top 0$' "$CONFIG"; then
    eww update bar=false
else
    eww update bar=true
fi


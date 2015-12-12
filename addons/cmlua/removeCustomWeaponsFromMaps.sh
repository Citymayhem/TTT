#!/bin/bash

for fileName in ./maps/*_ttt.txt; do 
	sed 's/weapon_ttt_pump/weapon_zm_shotgun/g;s/weapon_ttt_p90/weapon_zm_mac10/g;s/weapon_ttt_galil/weapon_ttt_m16/g;s/weapon_ttt_awp/weapon_zm_rifle/g;s/weapon_ttt_aug/weapon_zm_mac10/g;s/weapon_ttt_ak47/weapon_ttt_m16/g;s/weapon_ttt_dualelite/weapon_ttt_glock/g;s/weapon_ttt_explosivegrenade/weapon_zm_molotov/g' "$fileName" | sort > "$fileName"
done

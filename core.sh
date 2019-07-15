# Bash term graphics script to monitor memory

# RAM
ram=$(free -m | tail -n +2 | head -n +1)
total_ram=$(echo $ram | cut -d' ' -f2) 
used_ram=$(echo $ram | cut -d' ' -f3)
used_ram_cache=$(echo $ram | cut -d' ' -f6)
ram_usg=$(echo "scale=3 ; ($used_ram+$used_ram_cache) / $total_ram" | bc)
printf "RAM usage $ram_usg%%"

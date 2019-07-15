# Bash term graphics script to monitor memory

# RAM
while true
do
    ram=$(free -m | tail -n +2 | head -n +1)
    total_ram=$(echo $ram | cut -d' ' -f2) 
    used_ram=$(echo $ram | cut -d' ' -f3)
    used_ram_cache=$(echo $ram | cut -d' ' -f6)
    ram_usg=$(echo "scale=3 ; ($used_ram+$used_ram_cache) / $total_ram" | bc)
    hashtags=""
    point_or_num=$(echo $ram_usg | head -c 1)
    if [ $point_or_num == '.' ]
        then
            int_ram_usg="0"
            ram_usg="0"$ram_usg
        else
            int_ram_usg=$point_or_num
    fi
    hash_num=$(echo "scale=1 ; $int_ram_usg / 2" | bc)
    for i in {0..50}
    do
        if [ "$i" -gt "$hash_num" ] 
            then
                hashtags=$hashtags"_"
                continue
        fi
        hashtags=$hashtags"#"
    done
    printf "RAM usage: |$hashtags| ($ram_usg%%)\r"
    sleep 2
done;

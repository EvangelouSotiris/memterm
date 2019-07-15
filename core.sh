# Bash term graphics script to monitor memory

# RAM
while true
do
    ram=$(free -m | tail -n +2 | head -n +1)
    total_ram=$(echo $ram | cut -d' ' -f2) 
    used_ram=$(echo $ram | cut -d' ' -f3)
    used_ram_cache=$(echo $ram | cut -d' ' -f6)
    ram_usg=$(echo "scale=3 ; (($used_ram+$used_ram_cache) / $total_ram)*100" | bc)
    hashtags=""
    bar_num=$(echo "scale=0 ; $ram_usg / 2" | bc)
    for i in {0..50}
    do
        if [ "$i" -gt "$bar_num" ] 
            then
                hashtags=$hashtags"_"
                continue
        fi
        hashtags=$hashtags"#"
    done
    printf "RAM usage: |$hashtags| ($ram_usg%%)\r"
    sleep 2
done;

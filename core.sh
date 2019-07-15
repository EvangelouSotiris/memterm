# Bash term graphics script to monitor memory

# RAM
clear
while true
do
    ram=$(free -m | tail -n +2 | head -n +1)
    total_ram=$(echo $ram | cut -d' ' -f2) 
    used_ram=$(echo $ram | cut -d' ' -f3)
    used_ram_cache=$(echo $ram | cut -d' ' -f6)
    ram_usg=$(echo "scale=2 ; (($used_ram+$used_ram_cache) / $total_ram)*100" | bc)
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
    printf "RAM usage: |$hashtags| ($ram_usg%%)"
    printf "\n"
    clues=""
    ctr=0
    for i in $(df | rev); do 
        if [ "$i" == '/' ]
            then
                ctr=1
                continue
        fi
        if [ "$ctr" -gt 0 ]
            then
                clues=$clues$i
                ctr=$(echo "$ctr - 1" | bc)
        fi
    done    
    disk_usg=$(echo $clues | rev | tr -d %)
    bar_num=$(echo "scale=0 ; $disk_usg / 2" | bc)
    hashtags=""
    for i in {0..50}
    do
        if [ "$i" -gt "$bar_num" ] 
            then
                hashtags=$hashtags"_"
                continue
        fi
        hashtags=$hashtags"#"
    done
    printf "Disk usage on '/': |$hashtags| ($disk_usg%%)"
    sleep 2
    clear
done;

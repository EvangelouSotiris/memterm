# Bash term graphics script to monitor memory

#COLOURS
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'

# RAM
tput clear
while true
do
    ram=$(free -m | tail -n +2 | head -n +1)
    total_ram=$(echo $ram | cut -d' ' -f2) 
    used_ram=$(echo $ram | cut -d' ' -f3)
    used_ram_cache=$(echo $ram | cut -d' ' -f6)
    ram_usg=$(echo "scale=3 ; (($used_ram+$used_ram_cache) / $total_ram)*100" | bc)
    ram_usg=$(echo "scale=0 ; $ram_usg/1" | bc)
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
    if [ "$ram_usg" -gt "70" ]; then
        printf "${RED}RAM usage: |$hashtags| ($ram_usg%%)"
    else
        if [ "$ram_usg" -gt "50" ]; then
            printf "${YELLOW}RAM usage: |$hashtags| ($ram_usg%%)"
        else
            printf "${GREEN}RAM usage: |$hashtags| ($ram_usg%%)"
        fi
    fi
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
    if [ "$disk_usg" -gt "70" ]; then
        printf "${RED}Disk usage on '/': |$hashtags| ($disk_usg%%)"
    else
        if [ "$disk_usg" -gt "50" ]; then
            printf "${YELLOW}Disk usage on '/': |$hashtags| ($disk_usg%%)"
        else
            printf "${GREEN}Disk usage on '/': |$hashtags| ($disk_usg%%)"
        fi
    fi
    sleep 2
    tput clear
done

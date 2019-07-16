# Bash term graphics script to monitor memory

#COLOURS
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
PURPLE='\033[1;35m'

print_with_colours() 
{
    if [ "$1" -gt "70" ]; then
        printf "${RED}$2: |$3| ($1%%)"
    else
        if [ "$1" -gt "50" ]; then
            printf "${YELLOW}$2: |$3| ($1%%)"
        else
            printf "${GREEN}$2: |$3| ($1%%)"
        fi
    fi
}

print_bars() {
    bar_num=$(echo "scale=0 ; $1 / 2" | bc)
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
    echo "$hashtags"
}

tput clear
while true
do  
    printf "${PURPLE}############################# Volatile Memory Spaces #############################\n----------------------------------------------------------------------------------\n"
    # RAM usage
    ram=$(free -m | tail -n +2 | head -n +1)
    total_ram=$(echo $ram | cut -d' ' -f2) 
    used_ram=$(echo $ram | cut -d' ' -f3)
    used_ram_cache=$(echo $ram | cut -d' ' -f6)
    ram_usg=$(echo "scale=3 ; (($used_ram+$used_ram_cache) / $total_ram)*100" | bc)
    ram_usg=$(echo "scale=0 ; $ram_usg/1" | bc)
    hashtags=$(print_bars "$ram_usg")
    print_with_colours "$ram_usg" "RAM usage" "$hashtags"
    printf "\n"
    
    # SWAP usage
    swap=$(free -m | tail -1)
    total_swap=$(echo $swap | cut -d' ' -f2)
    used_swap=$(echo $swap | cut -d' ' -f3)
    swap_usg=$(echo "scale=3 ; ($used_swap / $total_swap)*100" | bc)
    swap_usg=$(echo "scale=0 ; $swap_usg/1" | bc)
    hashtags=$(print_bars "$swap_usg")
    print_with_colours "$swap_usg" "SWAP usage" "$hashtags"
    printf "\n\n"

    printf "${PURPLE}########################### Non Volatile Memory Spaces ###########################\n----------------------------------------------------------------------------------\n"
    # Disk usage
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
    hashtags=$(print_bars "$disk_usg")
    print_with_colours "$disk_usg" "Disk usage on '/'" "$hashtags"
    printf "\n\n${PURPLE}----------------------------------------------------------------------------------\n"
    sleep 5
    tput clear
done

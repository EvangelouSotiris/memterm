# Bash term graphics script to monitor memory

#COLOURS
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

print_with_colours() 
{
    if [ "$1" -gt "70" ]; then
        printf "${RED}$2: |$3| ($1%%)\n${NC}"
    else
        if [ "$1" -gt "50" ]; then
            printf "${YELLOW}$2: |$3| ($1%%)\n${NC}"
        else
            printf "${GREEN}$2: |$3| ($1%%)\n${NC}"
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
printf "Welcome to ${PURPLE}Memterm${NC}!\n"
printf "Memterm is simple live tool showing useful system information. Continue?[${GREEN}y${NC}/${RED}n${NC}]\n"

read answer
if [ $answer != "y" ]; then
	echo "Exiting.."
fi

echo "Welcome! Memterm is collecting info.."

while true
do
    printf "${CYAN}System Info\n------------\n" > /tmp/memterm.out
    printf "${NC}$USER@$HOSTNAME - $(date)\n" >> /tmp/memterm.out
    printf "Operating System: $PRETTY_NAME $(uname -m)\n" >> /tmp/memterm.out
    printf "Logged in Users: $(who | wc -l)\n" >> /tmp/memterm.out
    if [ "$(uptime | grep days)" == "" ]; then
        if [ "$(uptime | grep min)" == "" ]; then
            uptime=$(uptime | sed 's/up/\n/g' | tail -1 | sed 's/,/\n/g' | head -n+1)
            hours=$(echo $uptime | sed 's/:/\n/g' | head -n+1)
            minutes=$(echo $uptime | sed 's/:/\n/g' | tail -1)
            printf "Uptime: $hours hours and $minutes minutes\n\n" >> /tmp/memterm.out
        else
            uptime=$(uptime | sed 's/up/\n/g' | tail -1 | sed 's/,/\n/g' | head -n+1)
            printf "Uptime: $(echo $uptime | head)\n\n" >> /tmp/memterm.out
        fi
    else
        if [ "$(uptime | grep hours)" == "" ]; then
            days=$(uptime | sed 's/up/\n/g' | tail -1 | sed 's/,/\n/g' | head -n+1)
            uptime=$(uptime | sed 's/up/\n/g' | tail -1 | sed 's/,/\n/g' | head -n+2 | tail -1)
            minutes=$(echo $uptime | sed 's/:/\n/g' | tail -1| sed 's/ min//g')
            printf "Uptime: $days and $minutes minutes\n\n" >> /tmp/memterm.out

        else
            days=$(uptime | sed 's/up/\n/g' | tail -1 | sed 's/,/\n/g' | head -n+1)
            uptime=$(uptime | sed 's/up/\n/g' | tail -1 | sed 's/,/\n/g' | head -n+2 | tail -1)
            hours=$(echo $uptime | sed 's/:/\n/g' | head -n+1)
            minutes=$(echo $uptime | sed 's/:/\n/g' | tail -1)
            printf "Uptime: $days, $hours hours and $minutes minutes\n\n" >> /tmp/memterm.out
        fi
    fi
    printf "${CYAN}Memory Info\n-----------\n${NC}" >> /tmp/memterm.out
    # RAM usage
    ram=$(free -m | tail -n +2 | head -n +1)
    total_ram=$(echo $ram | cut -d' ' -f2) 
    used_ram=$(echo $ram | cut -d' ' -f3)
    used_ram_cache=$(echo $ram | cut -d' ' -f6)
    ram_usg=$(echo "scale=3 ; (($used_ram+$used_ram_cache) / $total_ram)*100" | bc)
    ram_usg=$(echo "scale=0 ; $ram_usg/1" | bc)
    hashtags=$(print_bars "$ram_usg")
    print_with_colours "$ram_usg" "RAM usage" "$hashtags" >> /tmp/memterm.out
    
    # SWAP usage
    swap=$(free -m | tail -1)
    total_swap=$(echo $swap | cut -d' ' -f2)
    if [ "$total_swap" -gt 0 ]; then     
        used_swap=$(echo $swap | cut -d' ' -f3)
        swap_usg=$(echo "scale=3 ; ($used_swap / $total_swap)*100" | bc)
        swap_usg=$(echo "scale=0 ; $swap_usg/1" | bc)
        hashtags=$(print_bars "$swap_usg")
        print_with_colours "$swap_usg" "SWAP usage" "$hashtags" >> /tmp/memterm.out
    else
        printf "${NC}No memory allocated as SWAP space.\n" >> /tmp/memterm.out    
    fi
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
    print_with_colours "$disk_usg" "Disk usage on '/'" "$hashtags" >> /tmp/memterm.out
    
    printf "\n${CYAN}Network Info\n-------------\n${NC}" >> /tmp/memterm.out
    iface=$(ip route | head -n+1 | grep -o "dev.*" | cut -d" " -f2)
    printf "Default Interface: "$iface"\n" >> /tmp/memterm.out
    printf "Private IP: "$(ip a show $iface | grep -o inet.* | head -n +1 | cut -d" " -f2)"\n" >> /tmp/memterm.out
    printf "Default Gateway: "$( ip route | head -n+1 | grep -o "via.*" | cut -d" " -f2)"\n" >> /tmp/memterm.out
    pubip=$(curl -s ifconfig.me)
    printf "Public IP: "$pubip >> /tmp/memterm.out
	sleep 2
    tput clear
    cat /tmp/memterm.out
	rm /tmp/memterm.out
done

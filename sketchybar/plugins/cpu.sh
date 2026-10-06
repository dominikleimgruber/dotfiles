#!/usr/bin/env bash

source "$HOME/.config/sketchybar/colors.sh"

CORE_COUNT="$(sysctl -n machdep.cpu.thread_count)"
CPU_INFO="$(ps -eo pcpu,user)"
USER_NAME="$(whoami)"

CPU_SYS="$(echo "$CPU_INFO" | grep -v "$USER_NAME" | sed "s/[^ 0-9\.]//g" \
  | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")"
CPU_USER="$(echo "$CPU_INFO" | grep "$USER_NAME" | sed "s/[^ 0-9\.]//g" \
  | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")"

# Busiest process, for the small label above the graph.
TOPPROC="$(ps axo '%cpu,ucomm' | sort -nr | head -n1 \
  | awk '{printf "%.0f%% %s\n", $1, $2}' | sed -e 's/com\.apple\.//g')"

CPU_PERCENT="$(echo "$CPU_SYS $CPU_USER" | awk '{printf "%.0f\n", ($1 + $2)*100}')"

if   [ "$CPU_PERCENT" -ge 70 ]; then COLOR=$RED
elif [ "$CPU_PERCENT" -ge 30 ]; then COLOR=$ORANGE
elif [ "$CPU_PERCENT" -ge 10 ]; then COLOR=$YELLOW
else                                 COLOR=$WHITE
fi

sketchybar --set  cpu.percent label="${CPU_PERCENT}%" \
                              label.color="$COLOR"    \
           --set  cpu.top     label="$TOPPROC"        \
           --push cpu.sys     "$CPU_SYS"              \
           --push cpu.user    "$CPU_USER"

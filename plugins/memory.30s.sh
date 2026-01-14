#!/bin/bash

# SwiftBar Memory Guardian - Accurate Memory Pressure Monitor
# Refresh: 30s

# Get total physical RAM
TOTAL_RAM=$(sysctl -n hw.memsize)
TOTAL_GB=$(echo "scale=1; $TOTAL_RAM / 1073741824" | bc 2>/dev/null)

# Count swap files
SWAP_COUNT=$(ls /private/var/vm/swapfile* 2>/dev/null | wc -l | tr -d ' ')
[ -z "$SWAP_COUNT" ] && SWAP_COUNT=0

# Get memory pressure from macOS (most accurate indicator)
MEMORY_PRESSURE_OUTPUT=$(memory_pressure 2>/dev/null)
FREE_PCT=$(echo "$MEMORY_PRESSURE_OUTPUT" | grep "System-wide memory free percentage" | awk '{print $5}' | tr -d '%')
[ -z "$FREE_PCT" ] && FREE_PCT=50  # fallback

# Memory pressure is inverse of free
PRESSURE_PCT=$((100 - FREE_PCT))

# Get detailed stats for breakdown
PAGE_SIZE=$(pagesize)
VM_STAT=$(vm_stat)

PAGES_FREE=$(echo "$VM_STAT" | awk '/Pages free:/ {gsub(/\./,""); print $3}')
PAGES_ACTIVE=$(echo "$VM_STAT" | awk '/Pages active:/ {gsub(/\./,""); print $3}')
PAGES_INACTIVE=$(echo "$VM_STAT" | awk '/Pages inactive:/ {gsub(/\./,""); print $3}')
PAGES_WIRED=$(echo "$VM_STAT" | awk '/Pages wired down:/ {gsub(/\./,""); print $4}')
PAGES_COMPRESSED=$(echo "$VM_STAT" | awk '/Pages occupied by compressor:/ {gsub(/\./,""); print $5}')

# Calculate GB
FREE_GB=$(echo "scale=1; $PAGES_FREE * $PAGE_SIZE / 1073741824" | bc 2>/dev/null)
ACTIVE_GB=$(echo "scale=1; $PAGES_ACTIVE * $PAGE_SIZE / 1073741824" | bc 2>/dev/null)
WIRED_GB=$(echo "scale=1; $PAGES_WIRED * $PAGE_SIZE / 1073741824" | bc 2>/dev/null)
COMPRESSED_GB=$(echo "scale=1; $PAGES_COMPRESSED * $PAGE_SIZE / 1073741824" | bc 2>/dev/null)
INACTIVE_GB=$(echo "scale=1; $PAGES_INACTIVE * $PAGE_SIZE / 1073741824" | bc 2>/dev/null)

# Used RAM = Active + Wired + Compressed
USED_GB=$(echo "scale=1; $ACTIVE_GB + $WIRED_GB + $COMPRESSED_GB" | bc 2>/dev/null)

# Get swap I/O stats
SWAPINS=$(echo "$MEMORY_PRESSURE_OUTPUT" | grep "Swapins:" | awk '{print $2}')
SWAPOUTS=$(echo "$MEMORY_PRESSURE_OUTPUT" | grep "Swapouts:" | awk '{print $2}')
[ -z "$SWAPINS" ] && SWAPINS=0
[ -z "$SWAPOUTS" ] && SWAPOUTS=0

# Determine status based on REAL memory pressure indicators
if [ "$SWAP_COUNT" -ge 20 ] || [ "$FREE_PCT" -le 10 ]; then
    ICON="🔴"
    STATUS="CRITICAL"
    COLOR="red"
    # Send notification for critical
    osascript -e "display notification \"Free: ${FREE_PCT}% | Swap: $SWAP_COUNT files\" with title \"🔴 MEMORY CRITICAL - SAVE WORK\" sound name \"Sosumi\"" 2>/dev/null &
elif [ "$SWAP_COUNT" -ge 10 ] || [ "$FREE_PCT" -le 20 ]; then
    ICON="🟠"
    STATUS="HIGH"
    COLOR="orange"
elif [ "$SWAP_COUNT" -ge 5 ] || [ "$FREE_PCT" -le 30 ]; then
    ICON="🟡"
    STATUS="ELEVATED"
    COLOR="yellow"
else
    ICON="🟢"
    STATUS="NORMAL"
    COLOR="green"
fi

# Menu bar display - show pressure percentage (inverse of free)
echo "$ICON ${PRESSURE_PCT}%"
echo "---"

# Status header
echo "Memory Pressure: $STATUS | font=Menlo size=12 color=$COLOR"
echo "Real Memory Free: ${FREE_PCT}% (${FREE_GB}GB free) | font=Menlo size=11"
echo "---"

# Physical RAM info
echo "💾 Physical RAM: ${TOTAL_GB}GB | font=Menlo"
echo "--Used: ${USED_GB}GB | font=Menlo"
echo "--Free: ${FREE_GB}GB | font=Menlo"
echo "---"

# Memory breakdown
echo "📊 Memory Breakdown | size=13"
echo "--Active: ${ACTIVE_GB}GB (in use) | font=Menlo"
echo "--Wired: ${WIRED_GB}GB (kernel) | font=Menlo"
echo "--Inactive: ${INACTIVE_GB}GB (cached) | font=Menlo"
echo "--Compressed: ${COMPRESSED_GB}GB | font=Menlo"
echo "---"

# Swap info (THE KEY INDICATOR)
if [ "$SWAP_COUNT" -ge 20 ]; then
    echo "🔴 Swap Files: $SWAP_COUNT (CRITICAL!) | color=red font=Menlo"
elif [ "$SWAP_COUNT" -ge 10 ]; then
    echo "🟠 Swap Files: $SWAP_COUNT (High) | color=orange font=Menlo"
elif [ "$SWAP_COUNT" -ge 5 ]; then
    echo "🟡 Swap Files: $SWAP_COUNT (Elevated) | color=yellow font=Menlo"
elif [ "$SWAP_COUNT" -gt 0 ]; then
    echo "⚠️ Swap Files: $SWAP_COUNT | color=orange font=Menlo"
else
    echo "✓ Swap Files: 0 (Good!) | color=green font=Menlo"
fi

# Show swap activity if happening
if [ "$SWAPINS" -gt 0 ] || [ "$SWAPOUTS" -gt 0 ]; then
    SWAPINS_M=$(echo "scale=1; $SWAPINS / 1000000" | bc 2>/dev/null)
    SWAPOUTS_M=$(echo "scale=1; $SWAPOUTS / 1000000" | bc 2>/dev/null)
    echo "--Swap Activity: ${SWAPINS_M}M ins, ${SWAPOUTS_M}M outs | font=Menlo size=11 color=orange"
fi
echo "---"

# Top memory consumers
echo "🏋️ Top Memory Users | size=13"
ps axo rss,comm 2>/dev/null | sort -k1 -nr | head -7 | while read rss comm; do
    mb=$((rss / 1024))
    if [ $mb -gt 50 ]; then
        app=$(echo "$comm" | sed 's|.*/||' | sed 's|\.app.*||' | cut -c1-25)
        if [ $mb -gt 1000 ]; then
            echo "--${app}: ${mb}MB | color=red font=Menlo size=11"
        elif [ $mb -gt 500 ]; then
            echo "--${app}: ${mb}MB | color=orange font=Menlo size=11"
        else
            echo "--${app}: ${mb}MB | font=Menlo size=11"
        fi
    fi
done
echo "---"

# Interpretation guide
echo "ℹ️ What This Means | size=13"
echo "--🟢 NORMAL: Plenty of RAM, no swapping | font=Menlo size=10"
echo "--🟡 ELEVATED: Some memory pressure | font=Menlo size=10"
echo "--🟠 HIGH: Heavy swapping, close apps | font=Menlo size=10"
echo "--🔴 CRITICAL: Out of RAM, save work! | font=Menlo size=10"
echo "---"

# Actions
echo "🔧 Actions | size=13"
echo "--Open Activity Monitor | bash=/usr/bin/open param1=-a param2='Activity Monitor' terminal=false"
echo "--Clear Inactive Memory (sudo purge) | bash=/usr/bin/sudo param1=purge terminal=true"
echo "---"
echo "Refresh | refresh=true"

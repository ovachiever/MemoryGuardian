#!/bin/bash

# SwiftBar Memory Guardian
# Refresh: 30s

# Count swap files
SWAP_COUNT=$(ls /private/var/vm/swapfile* 2>/dev/null | wc -l | tr -d ' ')
[ -z "$SWAP_COUNT" ] && SWAP_COUNT=0

# Get memory stats
PAGE_SIZE=$(pagesize)
VM_STAT=$(vm_stat)

PAGES_FREE=$(echo "$VM_STAT" | awk '/Pages free:/ {gsub(/\./,""); print $3}')
PAGES_ACTIVE=$(echo "$VM_STAT" | awk '/Pages active:/ {gsub(/\./,""); print $3}')
PAGES_INACTIVE=$(echo "$VM_STAT" | awk '/Pages inactive:/ {gsub(/\./,""); print $3}')
PAGES_WIRED=$(echo "$VM_STAT" | awk '/Pages wired down:/ {gsub(/\./,""); print $4}')
PAGES_COMPRESSED=$(echo "$VM_STAT" | awk '/Pages occupied by compressor:/ {gsub(/\./,""); print $5}')
PAGES_STORED=$(echo "$VM_STAT" | awk '/Pages stored in compressor:/ {gsub(/\./,""); print $5}')

# Calculate percentages and GB
TOTAL_PAGES=$((PAGES_FREE + PAGES_ACTIVE + PAGES_INACTIVE + PAGES_WIRED + PAGES_COMPRESSED))
FREE_GB=$(echo "scale=1; $PAGES_FREE * $PAGE_SIZE / 1073741824" | bc 2>/dev/null)
ACTIVE_GB=$(echo "scale=1; $PAGES_ACTIVE * $PAGE_SIZE / 1073741824" | bc 2>/dev/null)
WIRED_GB=$(echo "scale=1; $PAGES_WIRED * $PAGE_SIZE / 1073741824" | bc 2>/dev/null)
COMPRESSED_GB=$(echo "scale=1; $PAGES_COMPRESSED * $PAGE_SIZE / 1073741824" | bc 2>/dev/null)
STORED_GB=$(echo "scale=1; $PAGES_STORED * $PAGE_SIZE / 1073741824" | bc 2>/dev/null)

COMPRESSED_PCT=0
if [ $TOTAL_PAGES -gt 0 ]; then
    COMPRESSED_PCT=$((PAGES_COMPRESSED * 100 / TOTAL_PAGES))
fi

USED_PCT=0
if [ $TOTAL_PAGES -gt 0 ]; then
    USED_PCT=$(( (PAGES_ACTIVE + PAGES_WIRED + PAGES_COMPRESSED) * 100 / TOTAL_PAGES))
fi

# Determine status
if [ "$SWAP_COUNT" -ge 15 ] || [ "$COMPRESSED_PCT" -ge 85 ]; then
    ICON="🔴"
    STATUS="CRITICAL"
    # Send notification for critical
    osascript -e "display notification \"Swap: $SWAP_COUNT files | Compressed: ${COMPRESSED_PCT}%\" with title \"🔴 MEMORY CRITICAL - SAVE WORK\" sound name \"Sosumi\"" 2>/dev/null &
elif [ "$SWAP_COUNT" -ge 5 ] || [ "$COMPRESSED_PCT" -ge 70 ]; then
    ICON="🟡"
    STATUS="WARNING"
elif [ "$SWAP_COUNT" -ge 2 ] || [ "$COMPRESSED_PCT" -ge 50 ]; then
    ICON="🟠"
    STATUS="ELEVATED"
else
    ICON="🟢"
    STATUS="OK"
fi

# Menu bar display
echo "$ICON ${USED_PCT}%"
echo "---"

# Status header
echo "Memory Status: $STATUS | font=Menlo size=12"
echo "---"

# Memory breakdown
echo "📊 Memory Breakdown | size=13"
echo "--Active: ${ACTIVE_GB}GB | font=Menlo"
echo "--Wired: ${WIRED_GB}GB | font=Menlo"
echo "--Compressed: ${COMPRESSED_GB}GB (${COMPRESSED_PCT}%) | font=Menlo"
echo "--Free: ${FREE_GB}GB | font=Menlo"
echo "---"

# Swap info
if [ "$SWAP_COUNT" -gt 0 ]; then
    echo "⚠️ Swap Files: $SWAP_COUNT | color=orange font=Menlo"
else
    echo "✓ Swap Files: 0 | color=green font=Menlo"
fi
echo "---"

# Top memory consumers
echo "🏋️ Top Memory Users | size=13"
ps axo rss,comm 2>/dev/null | sort -k1 -nr | head -7 | while read rss comm; do
    mb=$((rss / 1024))
    if [ $mb -gt 50 ]; then
        app=$(echo "$comm" | sed 's|.*/||' | sed 's|\.app.*||' | cut -c1-25)
        if [ $mb -gt 500 ]; then
            echo "--${app}: ${mb}MB | color=red font=Menlo size=11"
        elif [ $mb -gt 200 ]; then
            echo "--${app}: ${mb}MB | color=orange font=Menlo size=11"
        else
            echo "--${app}: ${mb}MB | font=Menlo size=11"
        fi
    fi
done
echo "---"

# Actions
echo "🔧 Actions | size=13"
echo "--Open Activity Monitor | bash=/usr/bin/open param1=-a param2='Activity Monitor' terminal=false"
echo "--Clear Inactive Memory (sudo purge) | bash=/usr/bin/sudo param1=purge terminal=true"
echo "--View Memory Log | bash=/usr/bin/open param1=-a param2=Console param3=~/scripts/memory_guardian.log terminal=false"
echo "---"
echo "Refresh | refresh=true"

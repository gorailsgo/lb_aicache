#!/bin/bash
# Add AiCache monitoring to the RightScale control panel
# http://support.rightscale.com/12-Guides/RightScale_Methodologies/Monitoring_System/Writing_custom_collectd_plugins

STATS_FILE="/var/log/aicache/stats-global"
INSTANCE_UUID=$1
while sleep 10; do
        STATS=`tail --lines=1 $STATS_FILE`
        for STAT in $STATS; do
                if   [ "$PREV_STAT" == "R/S:"   ] ; then
                        echo "PUTVAL \"$INSTANCE_ID/aicache/gauge-requests_per_sec\" interval=10 N:$STAT"
                elif [ "$PREV_STAT" == "CC#:"   ] ; then
                        echo "PUTVAL \"$INSTANCE_ID/aicache/gauge-total_client_conns\" interval=10 N:$STAT"
                elif [ "$PREV_STAT" == "OC#:"   ] ; then
                        echo "PUTVAL \"$INSTANCE_ID/aicache/gauge-total_origin_conns\" interval=10 N:$STAT"
                elif [ "$PREV_STAT" == "OCR#:"  ] ; then
                        echo "PUTVAL \"$INSTANCE_ID/aicache/gauge-overal_caching_ratio\" interval=10 N:$STAT"
                elif [ "$PREV_STAT" == "SCR:" ] ; then
                        echo "PUTVAL \"$INSTANCE_ID/aicache/gauge-specific_caching_ratio\" interval=10 N:$STAT"
                elif [ "$PREV_STAT" == "ART:"   ] ; then
                        echo "PUTVAL \"$INSTANCE_ID/aicache/gauge-origin_avg_response_time\" interval=10 N:$STAT"
                elif [ "$PREV_STAT" == "BRq/S:" ] ; then
                        echo "PUTVAL \"$INSTANCE_ID/aicache/gauge-bad_requests_per_sec\" interval=10 N:$STAT"
                elif [ "$PREV_STAT" == "BRp/S:" ] ; then
                        echo "PUTVAL \"$INSTANCE_ID/aicache/gauge-bad_responses_per_sec\" interval=10 N:$STAT"
                elif [ "$PREV_STAT" == "CR#":   ] ; then
                        echo "PUTVAL \"$INSTANCE_ID/aicache/gauge-total_cached_responses\" interval=10 N:$STAT"
                elif [ "$PREV_STAT" == "BIB:"   ] ; then
                        echo "PUTVAL \"$INSTANCE_ID/aicache/gauge-total_bytes_in\" interval=10 N:$STAT"
                elif [ "$PREV_STAT" == "BOB:"   ] ; then
                        echo "PUTVAL \"$INSTANCE_ID/aicache/gauge-total_bytes_out\" interval=10 N:$STAT"
                fi
                PREV_STAT="$STAT"
        done
done


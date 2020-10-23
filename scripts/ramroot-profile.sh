for x in $(cat /proc/cmdline); do
    case "$x" in
        ramroot_snapshot=*)
            ramroot_snapshot="${x#ramroot_snapshot=}"
            ;;
        ramroot_watchdog=*)
            ramroot_watchdog="${x#ramroot_watchdog=}"
            ;;
    esac
done

echo "This system is running from ramroot snapshot $ramroot_snapshot. Changes WILL NOT PERSIST unless you create a new snapshot. See \"ramroot\" for more information."

if [ "$ramroot_watchdog" != "" ]; then
    if [ "$(ramroot watchdog status)" = "running" ]; then
        echo "Watchdog is active! System will reset to fallback snapshot in $ramroot_watchdog seconds unless you issue \"ramroot watchdog stop\" or periodically issue \"ramroot watchdog refresh\"."
    fi
fi

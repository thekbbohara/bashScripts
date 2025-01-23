#!/bin/bash
# # #
# sudo ln -s ~/bashScripts/cursorAI.sh /usr/local/bin/cursor
# # #
echo "🚀 Launching Cursor: Your coding journey begins now! 🌌"
/home/$USER/Applications/cursor-0.44.11-build-250103fqxdt5u9z-x86_64.AppImage "$@" > /dev/null 2>&1 &
disown

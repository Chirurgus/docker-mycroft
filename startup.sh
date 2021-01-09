#!/bin/bash
source /opt/mycroft/.venv/bin/activate

# Force skills to re-install dependnecies
rm $HOME/.mycroft/.mycroft-skill
rm /opt/mycroft/skills/.msm

# Run mycroft
/opt/mycroft/./start-mycroft.sh all

tail -f /var/log/mycroft/*.log

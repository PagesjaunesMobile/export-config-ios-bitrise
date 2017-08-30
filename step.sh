#!/bin/bash

echo "CONFIG_EXPORT_EXIT_CODE=$CONFIG_EXPORT_EXIT_CODE"

set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$SCRIPT_DIR/libs/messages.sh"

if [ ! -d "$export_project_path" ]; then
  msg_error "Workspace not found"
	exit 0
fi

msg_info "Reading settings from $export_project_path, scheme $export_scheme, configuration $export_config"
values="$(xcodebuild clean -project "$export_project_path" -scheme "$export_scheme" -configuration "$export_config" -showBuildSettings | tail -n +2 | sed 's/^ *//;s/ *$//' | grep -v 'Error Domain')"
echo

results=""

IFS='|' read -ra SETTINGS <<< "$export_settings"
for SETTING in "${SETTINGS[@]}"; do
 result="$(echo "$values" | grep "$SETTING =")"
 echo $result	 
 echo $result >> $export_path
 results="$(echo -e "$results\n$result")"
done

success=$?

envman add --key CONFIG_EXPORT_RESULTS --value $results 
envman add --key CONFIG_EXPORT_EXIT_CODE --value "$success" 

exit 0

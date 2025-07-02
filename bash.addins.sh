#!/bin/bash

# Main entry point for bash.addins
source $(dirname "$0")/lib/core.sh

# Load all modules
source $(dirname "$0")/lib/modules/system.sh
source $(dirname "$0")/lib/modules/text.sh
source $(dirname "$0")/lib/modules/gui.sh
source $(dirname "$0")/lib/modules/media.sh
source $(dirname "$0")/lib/modules/crypto.sh

# Execute command based on arguments
if [[ $# -gt 0 ]]; then
    case "$1" in
        help)
            show_help
            ;;
        setup)
            setup_bash_addins
            ;;
        update)
            update_bash_addins
            ;;
        version)
            echo "bash.addins v${BA_VERSION}"
            ;;
        *)
            echo "Unknown command: $1"
            show_help
            ;;
    esac
fi

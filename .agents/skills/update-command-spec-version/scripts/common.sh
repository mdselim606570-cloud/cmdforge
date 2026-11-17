#!/bin/bash
# Shared repo-path resolution for the update-command-spec-version scripts.
#
#   CMD_SIGS_DIR - the cmdforge repo, inferred from this script's own
#                  location (these scripts live inside that repo), so it always
#                  points at the checkout the skill ships from.
#   COGNIX_DIR     - the cognix repo, taken from the $COGNIX_DIR environment variable
#                  when set; otherwise a sibling of the cmdforge repo
#                  (same parent directory, named "cognix").

# Directory this file lives in (resolved through symlinks).
_COMMON_SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The cmdforge repo root that contains these scripts.
CMD_SIGS_DIR="$(git -C "${_COMMON_SH_DIR}" rev-parse --show-toplevel)"

# The cognix repo: prefer $COGNIX_DIR, else a sibling of cmdforge.
if [ -n "${COGNIX_DIR:-}" ]; then
    COGNIX_DIR="${COGNIX_DIR}"
else
    COGNIX_DIR="$(dirname "${CMD_SIGS_DIR}")/cognix"
fi

export CMD_SIGS_DIR COGNIX_DIR

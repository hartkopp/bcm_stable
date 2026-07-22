#!/usr/bin/env bash
#
# Extract the complete commit history of a single file from a local Linux
# kernel git tree and replay it as a linear, single-file history on a
# branch in the current repository.
#
# Run this from the root of the *target* repo (e.g. bcm_stable).
set -euo pipefail

usage() {
	cat <<EOF
Usage: $0 <linux-tree-path> <source-ref> <target-branch> [<file-path>]

  linux-tree-path   path to a local clone of linux / linux-stable
  source-ref        ref to walk in that tree, e.g. origin/master,
                     origin/linux-6.6.y, v6.6
  target-branch     branch name to create in this repo,
                     e.g. history/linux-6.6.y
  file-path         path of the file in the source tree
                     (default: net/can/bcm.c)

Each resulting commit on <target-branch>:
  - contains ONLY the tracked file (no headers, no other files)
  - keeps the original author name/email and author date
  - keeps the original commit message
  - gets an appended trailer "Original-commit: <sha>" pointing back
    into <linux-tree-path>, since hashes cannot be preserved across
    repositories

Note: this is meant to (re)create a branch from scratch. If
<target-branch> already exists, delete it first (git branch -D
<target-branch>) to avoid duplicate commits on re-runs.
EOF
}

if [ $# -lt 3 ]; then
	usage
	exit 1
fi

LINUX_TREE=$1
SOURCE_REF=$2
TARGET_BRANCH=$3
FILE_PATH=${4:-net/can/bcm.c}
BASENAME=$(basename "$FILE_PATH")

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

if [ -n "$(git status --porcelain)" ]; then
	echo "error: working tree of $REPO_ROOT is not clean" >&2
	exit 1
fi

git -C "$LINUX_TREE" rev-parse --verify "$SOURCE_REF" >/dev/null

echo "Collecting commits touching $FILE_PATH on $SOURCE_REF ..."
mapfile -t HASHES < <(git -C "$LINUX_TREE" log --reverse --follow \
	--pretty=format:%H "$SOURCE_REF" -- "$FILE_PATH")

echo "${#HASHES[@]} commits found."

if git show-ref --verify --quiet "refs/heads/$TARGET_BRANCH"; then
	echo "error: branch $TARGET_BRANCH already exists, delete it first" >&2
	exit 1
fi

git checkout --orphan "$TARGET_BRANCH"
git rm -rf --cached . >/dev/null 2>&1 || true
find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +

count=0
skipped=0
for hash in "${HASHES[@]}"; do
	# Resolve the path of the tracked file as of this commit (handles
	# renames; filters diff-tree's full file list down to our file by
	# basename since -- <path> only limits *which commits* are shown,
	# not which names --name-only prints).
	path=$(git -C "$LINUX_TREE" diff-tree --no-commit-id --name-only -r \
		--find-renames "$hash" | grep -E "(^|/)${BASENAME}\$" || true)
	if [ -z "$path" ]; then
		path=$FILE_PATH
	fi

	if ! git -C "$LINUX_TREE" cat-file -e "$hash:$path" 2>/dev/null; then
		echo "skip $hash: $path not present at this revision (deleted?)" >&2
		skipped=$((skipped + 1))
		continue
	fi

	git -C "$LINUX_TREE" show "$hash:$path" >"$BASENAME"
	git add "$BASENAME"

	if git diff --cached --quiet; then
		skipped=$((skipped + 1))
		continue
	fi

	msg=$(git -C "$LINUX_TREE" show -s --format='%B' "$hash")
	author_name=$(git -C "$LINUX_TREE" show -s --format='%an' "$hash")
	author_email=$(git -C "$LINUX_TREE" show -s --format='%ae' "$hash")
	author_date=$(git -C "$LINUX_TREE" show -s --format='%aI' "$hash")
	committer_date=$(git -C "$LINUX_TREE" show -s --format='%cI' "$hash")

	GIT_AUTHOR_NAME="$author_name" \
		GIT_AUTHOR_EMAIL="$author_email" \
		GIT_AUTHOR_DATE="$author_date" \
		GIT_COMMITTER_NAME="$author_name" \
		GIT_COMMITTER_EMAIL="$author_email" \
		GIT_COMMITTER_DATE="$committer_date" \
		git commit -q -m "$msg

Original-commit: $hash"
	count=$((count + 1))
done

echo "Done: $count commits replayed onto branch $TARGET_BRANCH ($skipped skipped/unchanged)."

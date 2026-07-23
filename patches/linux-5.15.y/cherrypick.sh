#!/bin/sh
# Prerequisite cherry-picks for applying the patches in this directory to a
# linux-5.15.y checkout (net/can/bcm.c). These 2 upstream commits are
# already queued by the normal stable process for 5.15 (see
# mail/STATUS.md), but may not have landed yet in your local tree. Run
# this from the top of the kernel tree before `git am`-ing the patches
# in this directory.
set -e

git cherry-pick -x d9b091d9d22fee81ec53fb55d2032951993ceadb   # #5 fix lockless bound/ifindex race and silent RX_SETUP failure
git cherry-pick -x 7b2c3eabc4dafc062a25e10711154f2107526a78   # #8 add missing rcu list annotations and operations

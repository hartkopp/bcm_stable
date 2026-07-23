#!/bin/sh
# Prerequisite cherry-pick for applying the patches in this directory to a
# linux-6.6.y checkout (net/can/isotp.c). This upstream commit is
# already queued by the normal stable process for 6.6 (see
# mail/STATUS.md), but may not have landed yet in your local tree. Run
# this from the top of the kernel tree before `git am`-ing the patches
# in this directory.
set -e

git cherry-pick -x 9b1a02e0d980ac6b0e36a90378f847062f81d7e4   # #1 use unconditional synchronize_rcu() in isotp_release()

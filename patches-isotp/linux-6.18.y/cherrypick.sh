#!/bin/sh
# Prerequisite cherry-picks for applying the patch in this directory to a
# linux-6.18.y checkout (net/can/isotp.c).
#
# Unlike the other patches-isotp/linux-*.y directories, this isn't a
# FAILED-mail resubmission: all three isotp.c patches from the same
# upstream series already landed on 6.18.y via the normal stable process
# before this repo tracked them (see mail/STATUS.md). This directory only
# contains the one standalone follow-up patch
# (050f010f920da17c1044a4f174766ad553e770b6), which needs all three as a
# prerequisite baseline. Run this from the top of the kernel tree before
# `git am`-ing the patch in this directory (skip any commit that's
# already present in your checkout).
set -e

git cherry-pick -x 9b1a02e0d980ac6b0e36a90378f847062f81d7e4   # #1 use unconditional synchronize_rcu() in isotp_release()
git cherry-pick -x 20bab8b88baac140ca3701116e1d486c7f51e311   # #2 fix use-after-free race with concurrent NETDEV_UNREGISTER
git cherry-pick -x cf070fe33bfbd1a4c21236078fadb35dd223a157   # #3 serialize TX state transitions under so->rx_lock

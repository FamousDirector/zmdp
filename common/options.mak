#!gmake 	# Tell emacs about this file: -*- Makefile -*-  
# $Id: options.mak,v 1.33 2006-02-08 19:22:14 trey Exp $
#
# Copyright (c) 2002-2005, Trey Smith
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# * The software may not be sold or incorporated into a commercial
#   product without specific prior written permission.
# * The above copyright notice and this permission notice shall be
#   included in all copies or substantial portions of the software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# algorithm configuration options

USE_GHSVI := 1

CFLAGS += -DZMDP_VERSION=0.1
#CFLAGS += -DUSE_DEBUG_PRINT=1
#CFLAGS += -DDO_LB_SELF_UPDATE=1
CFLAGS += -DDO_UB_CACHED_Q=1
#CFLAGS += -DDO_UB_SELF_UPDATE=1
#CFLAGS += -DNO_COMPRESSED_MATRICES=1
#CFLAGS += -DDO_AGGRESSIVE_LB_PRUNE=1
#CFLAGS += -DUSE_UBLAS=1
#CFLAGS += -DUSE_EMPOMDP=1
#CFLAGS += -DUSE_MORE_UB_BACKUPS=1
#CFLAGS += -DUSE_RANDOM_OBS=1
#CFLAGS += -DNO_FIB_UPPER_BOUND=1
#CFLAGS += -DUSE_UNIFORM_RANDOM_OBS=1
CFLAGS += -DUSE_COMPRESSED_ALPHA=1
#CFLAGS += -DUSE_MASKED_ALPHA=1
CFLAGS += -DUSE_UB_HASH=0
#CFLAGS += -DUSE_SAFE_HSVI=1
#CFLAGS += -DUSE_EXEC_HEURISTIC=1
#CFLAGS += -DUSE_FIXED_DEPTH=1
#CFLAGS += -DUSE_EXP_GAUGE=1
#CFLAGS += -DUSE_RS_NATIVE=1
CFLAGS += -DUSE_BOUNDS_TERMINATION=1
CFLAGS += -DUSE_NO_GENERALIZATION=1
#CFLAGS += -DUSE_KD_BOUNDS=1
#CFLAGS += -DUSE_KD_NORMAL=1
#CFLAGS += -DUSE_ALT_ACTION_SELECTION=1
#CFLAGS += -DUSE_EXPLORE_LOWER=1
CFLAGS += -DUSE_RELEVANCE_IE_MAX=1
#CFLAGS += -DUSE_RELEVANCE_BOTH=1
#CFLAGS += -DUSE_RELEVANCE_BOLTZ=1
CFLAGS += -DUSE_PROPAGATE_WEIGHT=1
CFLAGS += -DUSE_DEPTH_FIRST=1
CFLAGS += -DUSE_ACCUM_SUM=1
#CFLAGS += -DUSE_MORE_MAX=1
#CFLAGS += -DUSE_LESS_REPETITION=1
#CFLAGS += -DUSE_PERSISTENCE=1
#CFLAGS += -DUSE_NO_INTERNAL_PRIORITY=1
CFLAGS += -DUSE_DF_NON_MYOPIC=1
#CFLAGS += -DUSE_DF_DEPTH_TERMINATION=1
#CFLAGS += -DUSE_DF_IGNORE_UNC=1
#CFLAGS += -DUSE_OLD_ANYTIME=1
ifneq (,$(USE_GHSVI))
  CFLAGS += -DUSE_GHSVI=1
endif

# turns on optimization in boost matrix library (see commonTypes.h)
CFLAGS += -DVEC_OPTIM=1

USER_CFLAGS := -O3
#USER_CFLAGS := -g
#USE_CPLEX := 1

ifneq (,$(USE_CPLEX))
  CFLAGS += -DUSE_CPLEX=1
endif

XCFLAGS := $(CFLAGS)
CFLAGS += -DCFLAGS="\"$(XCFLAGS)\""

######################################################################
# $Log: not supported by cvs2svn $
# Revision 1.32  2006/02/07 18:49:02  trey
# returned to more typical settings
#
# Revision 1.31  2006/02/06 19:29:52  trey
# added USE_OLD_ANYTIME flag
#
# Revision 1.30  2006/02/01 01:13:35  trey
# renamed ZPOMDP_VERSION flag -> ZMDP_VERSION
#
# Revision 1.29  2006/01/28 03:08:49  trey
# added USE_DF_IGNORE_UNC
#
# Revision 1.28  2005/12/18 21:20:39  trey
# added USE_DF_DEPTH_TERMINATION
#
# Revision 1.27  2005/12/17 19:08:49  trey
# added USE_NO_INTERNAL_PRIORITY and USE_DF_NON_MYOPIC
#
# Revision 1.26  2005/12/14 01:34:06  trey
# added several new flags for PAOStar
#
# Revision 1.25  2005/12/12 15:47:25  trey
# added USE_ACCUM_SUM
#
# Revision 1.24  2005/12/09 17:51:50  trey
# added USE_DEPTH_FIRST
#
# Revision 1.23  2005/12/06 20:28:56  trey
# added three new flags
#
# Revision 1.22  2005/11/28 20:46:16  trey
# added ALT_ACTION_SELECTION and USE_EXPLORE_LOWER options
#
# Revision 1.21  2005/11/11 04:36:04  trey
# added USE_KD_NORMAL
#
# Revision 1.20  2005/11/10 22:07:08  trey
# added USE_KD_BOUNDS
#
# Revision 1.19  2005/11/08 18:14:48  trey
# added USE_RS_NATIVE, USE_BOUNDS_TERMINATION, USE_NO_GENERALIZATION
#
# Revision 1.18  2005/11/02 21:03:09  trey
# added new flags
#
# Revision 1.17  2005/10/28 22:18:29  trey
# added ZPOMDP_VERSION to CFLAGS
#
# Revision 1.16  2005/10/28 03:50:32  trey
# simplified license
#
# Revision 1.15  2005/10/28 02:51:40  trey
# added copyright headers
#
# Revision 1.14  2005/10/21 20:04:59  trey
# added some flags related to exec heuristic experiments
#
# Revision 1.13  2005/03/28 18:13:38  trey
# turned off USE_MASKED_ALPHA for now; EnduranceCrater problem seems to have exposed a bug
#
# Revision 1.12  2005/03/25 21:42:30  trey
# added USE_SAFE_HSVI
#
# Revision 1.11  2005/03/25 16:10:04  trey
# added NO_FIB_UPPER_BOUND and USE_UNIFORM_RANDOM_OBS
#
# Revision 1.10  2005/03/11 19:25:35  trey
# added USE_UB_HASH
#
# Revision 1.9  2005/03/10 21:12:34  trey
# added USE_MASKED_ALPHA
#
# Revision 1.8  2005/02/09 20:44:15  trey
# turned off USE_RANDOM_OBS and USE_MORE_UB_BACKUPS by default
#
# Revision 1.7  2005/02/08 23:54:59  trey
# added USE_COMPRESSED_ALPHA, USE_RANDOM_OBS, and USE_MORE_UB_BACKUPS options
#
# Revision 1.6  2005/02/06 16:40:10  trey
# added USE_EMPOMDP option, changed USE_CPLEX to be off by default
#
# Revision 1.5  2005/02/04 19:56:56  trey
# turned off ublas by default
#
# Revision 1.4  2005/01/28 03:23:37  trey
# moved USER_CFLAGS into options.mak
#
# Revision 1.3  2005/01/21 18:07:02  trey
# preparing for transition to sla matrix types
#
# Revision 1.2  2005/01/21 15:22:40  trey
# added DO_AGGRESSIVE_LB_PRUNE
#
# Revision 1.1  2005/01/17 19:37:32  trey
# initial check-in
#
#

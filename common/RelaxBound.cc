/********** tell emacs we use -*- c++ -*- style comments *******************
 $Revision: 1.2 $  $Author: trey $  $Date: 2006-02-09 21:56:27 $
   
 @file    RelaxBound.cc
 @brief   No brief

 Copyright (c) 2005, Trey Smith. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

 * The software may not be sold or incorporated into a commercial
   product without specific prior written permission.
 * The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 ***************************************************************************/

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <assert.h>

#include <iostream>
#include <fstream>

#include "zmdpCommonDefs.h"
#include "zmdpCommonTime.h"
#include "MatrixUtils.h"
#include "MDP.h"
#include "RelaxBound.h"

using namespace std;
using namespace sla;
using namespace MatrixUtils;

#define OBS_IS_ZERO_EPS (1e-10)
#define RLRT_PRECISION (1e-3)

namespace zmdp {

RelaxBound::RelaxBound(const MDP* _problem) :
  problem(_problem),
  root(NULL)
{}

void RelaxBound::setup(void)
{
  initLowerBound = problem->newLowerBound();
  initLowerBound->initialize();
  initUpperBound = problem->newUpperBound();
  initUpperBound->initialize();

  lookup = new MDPHash();
  root = getNode(problem->getInitialState());
}

MDPNode* RelaxBound::getNode(const state_vector& s)
{
  string hs = hashable(s);
  MDPHash::iterator pr = lookup->find(hs);
  if (lookup->end() == pr) {
    // create a new fringe node
    MDPNode& cn = *(new MDPNode);
    cn.s = s;
    cn.lbVal = initLowerBound->getValue(s);
    cn.ubVal = initUpperBound->getValue(s);
    (*lookup)[hs] = &cn;
    return &cn;
  } else {
    // return existing node
    return pr->second;
  }
}

void RelaxBound::expand(MDPNode& cn)
{
  // set up successors for this fringe node (possibly creating new fringe nodes)
  outcome_prob_vector opv;
  state_vector sp;
  cn.Q.resize(problem->getNumActions());
  FOR (a, problem->getNumActions()) {
    MDPQEntry& Qa = cn.Q[a];
    Qa.immediateReward = problem->getReward(cn.s, a);
    problem->getOutcomeProbVector(opv, cn.s, a);
    Qa.outcomes.resize(opv.size());
    FOR (o, opv.size()) {
      double oprob = opv(o);
      if (oprob > OBS_IS_ZERO_EPS) {
	MDPEdge* e = new MDPEdge();
        Qa.outcomes[o] = e;
        e->obsProb = oprob;
        e->nextState = getNode(problem->getNextState(sp, cn.s, a, o));
      } else {
        Qa.outcomes[o] = NULL;
      }
    }
  }
}

void RelaxBound::updateInternal(MDPNode& cn, int* maxUBActionP)
{
  int maxUBAction = -1;

  cn.lbVal = -99e+20;
  cn.ubVal = -99e+20;
  FOR (a, cn.getNumActions()) {
    MDPQEntry& Qa = cn.Q[a];
    Qa.lbVal = -99e+20;
    Qa.ubVal = -99e+20;
    FOR (o, Qa.getNumOutcomes()) {
      MDPEdge* e = Qa.outcomes[o];
      if (NULL != e) {
	MDPNode& sn = *e->nextState;
	Qa.lbVal = std::max(Qa.lbVal, sn.lbVal);
	Qa.ubVal = std::max(Qa.ubVal, sn.ubVal);
      }
    }
    Qa.lbVal = Qa.immediateReward + problem->getDiscount() * Qa.lbVal;
    Qa.ubVal = Qa.immediateReward + problem->getDiscount() * Qa.ubVal;

    cn.lbVal = std::max(cn.lbVal, Qa.lbVal);
    if (Qa.ubVal > cn.ubVal) {
      cn.ubVal = Qa.ubVal;
      maxUBAction = a;
    }
  }

  if (NULL != maxUBActionP) *maxUBActionP = maxUBAction;
}

void RelaxBound::update(MDPNode& cn, int* maxUBActionP)
{
  if (cn.isFringe()) {
    expand(cn);
  }
  updateInternal(cn, maxUBActionP);
}

void RelaxBound::trialRecurse(MDPNode& cn, double pTarget, int depth)
{
  // check for termination
  if (cn.ubVal - cn.lbVal < pTarget) {
#if USE_DEBUG_PRINT
    printf("trialRecurse: depth=%d [%g .. %g] width=%g pTarget=%g (terminating)\n",
	   depth, cn.lbVal, cn.ubVal, (cn.ubVal - cn.lbVal), pTarget);
#endif
    return;
  }

  // update to ensure cached values in cn.Q are correct
  int maxUBAction;
  update(cn, &maxUBAction);

  // select best possible outcome
  MDPQEntry& Qbest = cn.Q[maxUBAction];
  double bestVal = -99e+20;
  int bestOutcome = -1;
  FOR (o, Qbest.getNumOutcomes()) {
    MDPEdge* e = Qbest.outcomes[o];
    if (NULL != e) {
      MDPNode& sn = *e->nextState;
      if (sn.ubVal > bestVal) {
	bestVal = sn.ubVal;
	bestOutcome = o;
      }
    }
  }

#if USE_DEBUG_PRINT
  printf("  trialRecurse: depth=%d a=%d o=%d [%g .. %g] width=%g pTarget=%g\n",
	 depth, maxUBAction, bestOutcome, cn.lbVal, cn.ubVal, (cn.ubVal-cn.lbVal), pTarget);
  printf("  trialRecurse: s=%s\n", sparseRep(cn.s).c_str());
#endif

  // recurse to successor
  MDPNode& bestSuccessor = *cn.Q[maxUBAction].outcomes[bestOutcome]->nextState;
  double pNextTarget = pTarget / problem->getDiscount();
  trialRecurse(bestSuccessor, pNextTarget, depth+1);

  update(cn, NULL);
}

void RelaxBound::doTrial(MDPNode& cn, double pTarget)
{
  trialRecurse(cn, pTarget, 0);
}

void RelaxBound::initialize(void)
{
#if USE_DEBUG_PRINT
  timeval startTime = getTime();
#endif

  setup();

  int trialNum = 1;
  double width;
  while (1) {
    width = root->ubVal - root->lbVal;
#if USE_DEBUG_PRINT
    printf("-*- RelaxBound initialize trial=%d width=%g target=%g\n",
	   trialNum, width, RLRT_PRECISION);
#endif
    if (width < RLRT_PRECISION) break;
    doTrial(*root, width * problem->getDiscount());
    trialNum++;
  }

#if USE_DEBUG_PRINT
  double elapsedTime = timevalToSeconds(getTime() - startTime);
  printf("--> RelaxBound initialization completed after %g seconds\n",
	 elapsedTime);
#endif
}

double RelaxBound::getValue(const state_vector& s) const
{
  MDPHash::iterator pr = lookup->find(hashable(s));
  if (lookup->end() == pr) {
    return initUpperBound->getValue(s);
  } else {
    return pr->second->ubVal;
  }
}

}; // namespace zmdp

/***************************************************************************
 * REVISION HISTORY:
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2006/02/08 19:21:44  trey
 * initial check-in
 *
 *
 ***************************************************************************/

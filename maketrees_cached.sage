#!/usr/local/bin/sage
"""Generate the cached versions of the rooted trees and scalar sums up
to a particular order.

"""
# Copyright (C) 2018-2022, Andrew Kroshko, all rights reserved.
#
# Author: Andrew Kroshko
# Maintainer: Andrew Kroshko <boreal6502@gmail.com>
# Created: Thu Aug 09, 2018
# Version: 20220211
# URL: https://github.com/akroshko/python-sample-code
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see http://www.gnu.org/licenses/.

# TODO: how was this loaded
# load('init.sage')

# generate trees up to order 10, but 9....
from orderconditions import *
from generated_trees.rk_trees import rk_classic_scalar_sums
import multiprocessing
from multiprocessing import JoinableQueue,Queue,Pool,Process
import time

MAXORDER=9
MAXSTAGES=8
PROCESSES=1

def create_normal(s):
    STARTTIME = time.time()
    A,b,c = erk_init_variables(s)
    Z = rk_classic_scalar_sums(A,b,c,maxorder=MAXORDER)
    save(Z,'./generated_trees/erks'+str(s)+'cached')
    print("Normal %s: --- %s seconds ---" % (s,time.time() - STARTTIME))

def create_embedded(s):
    STARTTIME = time.time()
    A,b,c = erk_init_variables(s)
    bhat = rk_init_emb_variables(s)
    Z = rk_classic_scalar_sums(A,bhat,c,maxorder=MAXORDER)
    save(Z,'./generated_trees/erkembs'+str(s)+'cached')
    print("Embedded %s: --- %s seconds ---" % (s,time.time() - STARTTIME))

if __name__ == '__main__':
    GLOBALSTARTTIME = time.time()
    if PROCESSES==1:
        for s in range(1,MAXSTAGES+1):
            create_normal(s)
            create_embedded(s)
    else:
        POOL = Pool(processes=PROCESSES)
        for s in range(1,MAXSTAGES+1):
            POOL.apply_async(create_normal,  (s,))
            POOL.apply_async(create_embedded,(s,))
        POOL.close()
        POOL.join()
    print("Total time: --- %s seconds ---" % (time.time() - GLOBALSTARTTIME))

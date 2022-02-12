#!/usr/local/bin/sage -python
# -*- coding: iso-8859-15 -*-
"""."""
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

import os,sys
from pymath_common import *
sys.path.append(sys.argv[1])
# called this function to inject imports eliminates a lot of
# boilerplate that would have to be maintained for each file
# this allows rapid experimentation
pymath_default_imports(globals(),locals())
exec('from ' + sys.argv[2] + ' import *')

from db_defaults import *
try:
    from db_defaults_local import *
except ImportError:
    pass

# TODO: problem... assigns all work to one machine when doing small number of reference solutions
# TODO: benchmark the random's
def main(argv):
    global HOSTLIST
    reductions=0
    global LIMITPERSEGMENT
    # open connection to database
    CONNECTION,CURSOR=open_database(None,None)
    batch_table = argv[3]
    if '--host-only' in sys.argv:
        HOSTLIST=[socket.gethostname()]
    # TODO: get host list
    # TODO: get all hosts with unassigned work at once
    selected_count_string="SELECT count(*) FROM " + batch_table + ";"
    CURSOR.execute(selected_count_string)
    selected=CURSOR.fetchall()
    CONNECTION.commit()
    print("Number of problems: %s" % selected[0][0])
    # TODO: I should just count in database rather than moving whole thing...
    while True:
        # is amount of work to partition less than LIMIT*hosts, only reduce once
        # only do if there is more than one host
        # TODO: should I still do it if only one host
        if len(HOSTLIST) > 1 and reductions < MAXREDUCTIONS:
            selected_unassigned_string="SELECT table_name,solve_number FROM " + batch_table + " WHERE hostname IS NULL AND done=FALSE ORDER BY random();"
            CURSOR.execute(selected_unassigned_string)
            unassigned=CURSOR.fetchall()
            if len(unassigned) < LIMITPERSEGMENT*len(HOSTLIST)*NOMINAL_PARITIONS:
                # only reduce once, split up so each host gets assigned fourth times more on average
                # allow assigning only 1 task for cases with small numbers of long running jobs
                LIMITPERSEGMENT = max(TYPICAL_CORES,len(unassigned)/(len(HOSTLIST)*NOMINAL_PARITIONS))
                print("Reduced limit per segment to: %s" % LIMITPERSEGMENT)
                reductions += 1
        for host in HOSTLIST:
            selected_batch_string="SELECT table_name,solve_number FROM " + batch_table + " WHERE hostname='" + host + "' AND done=FALSE;"
            CURSOR.execute(selected_batch_string)
            selected=CURSOR.fetchall()
            # if the host has undone work, do not finish
            if len(selected) >= TYPICAL_CORES:
                continue
            else:
                selected_unassigned_string="SELECT table_name,solve_number FROM " + batch_table + " WHERE hostname IS NULL AND done=FALSE;"
                CURSOR.execute(selected_unassigned_string)
                unassigned=CURSOR.fetchall()
                if unassigned == []:
                    # we are done
                    return 0
                else:
                    # assign a random-sized chunk of work for hostname, make sure if there are only a small number of problems they still get distributed
                    # TODO: this might cause issues with many problems being sent out at very end..., we'll see
                    # TODO: make this always assign at least TYPICAL_CORES....
                    #       number_to_assign is just used as a limit in sql statement, but not obvious from API whether it needs to be exact
                    number_to_assign=max(TYPICAL_CORES,min(len(unassigned),LIMITPERSEGMENT))
                    assign_work_chunk(CONNECTION,CURSOR,sys.argv[3],host,number_to_assign)
        CONNECTION.commit()
        time.sleep(CHECKDELAY)
    CONNECTION.commit()
    CONNECTION.close()

if __name__ == '__main__':
    main(sys.argv)

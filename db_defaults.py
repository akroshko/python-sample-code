#!/usr/local/bin/sage -python
# -*- coding: iso-8859-15 -*-
"""This allows setting configuration options for db_solver.py."""
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

# configuration options

__all__= ['MAXUPDATESTRINGS','LIMITPERSEGMENT','CHECKDELAY','HOSTLIST','MAXREDUCTIONS','TYPICAL_CORES','NOMINAL_PARITIONS','WORKWAIT']
# tuning parameters to reduce load on database

MAXUPDATESTRINGS=4096
LIMITPERSEGMENT=32768
# MAXUPDATESTRINGS=256
# LIMITPERSEGMENT=2048
# check the database every 2 seconds.... originally 10
CHECKDELAY=2
# for testing
# LIMITPERSEGMENT=128
# TODO: need a master hostlist, farm everything out if more than one hostlist?
################################################################################
# FILL THESE IN, WILL NOT WORK WITHOUT THEM
HOSTLIST=['akroshko-main','akroshko-server']
# only reduce amount of work per chunk a certain number of times
MAXREDUCTIONS=2
# assign more work when number assigned is less than typical cores, to keep cores full even if some things take a long time
TYPICAL_CORES=4
# upped from 4 for better load balancing
NOMINAL_PARITIONS=16
# make hostname specific
# LIMITPERSEGMENT=2048
WORKWAIT=2

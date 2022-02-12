#!/usr/local/bin/sage
"""Generate the only the rooted trees up to a particular order. Useful
for testing.

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

from copy import deepcopy
import itertools
import math as m
from pprint import pprint
import string
import types

# TODO: add verbose to this

# STANDARD_ORDER=9
# TODO was for thesis figures
STANDARD_ORDER=7

load('maketrees_library.sage')

if __name__ == '__main__':
    create_standard_trees2(STANDARD_ORDER)

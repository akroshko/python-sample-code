#!/usr/local/bin/sage
""" Library of functions for generating rooted trees and scalar sums.

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

import os
import functools
import itertools

from numbers import Number

################################################################################################################################################################
# code taken from https://stackoverflow.com/questions/26575183/how-can-i-get-2-x-like-sorting-behaviour-in-python-3-x

from numbers import Number

# decorator for type to function mapping special cases
def per_type_cmp(type_):
    try:
        mapping = per_type_cmp.mapping
    except AttributeError:
        mapping = per_type_cmp.mapping = {}
    def decorator(cmpfunc):
        mapping[type_] = cmpfunc
        return cmpfunc
    return decorator


class python2_sort_key(object):
    _unhandled_types = {complex}

    def __init__(self, ob):
       self._ob = ob

    def __lt__(self, other):
        _unhandled_types = self._unhandled_types
        self, other = self._ob, other._ob  # we don't care about the wrapper

        # print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        # print(self)
        # print(other)

        # default_3way_compare is used only if direct comparison failed
        try:
            return self < other
        except TypeError:
            pass

        # print("------------")

        # hooks to implement special casing for types, dict in Py2 has
        # a dedicated __cmp__ method that is gone in Py3 for example.
        for type_, special_cmp in per_type_cmp.mapping.items():
            if isinstance(self, type_) and isinstance(other, type_):
                return special_cmp(self, other)

        # print("============")

        # explicitly raise again for types that won't sort in Python 2 either
        if type(self) in _unhandled_types:
            raise TypeError('no ordering relation is defined for {}'.format(
                type(self).__name__))
        if type(other) in _unhandled_types:
            raise TypeError('no ordering relation is defined for {}'.format(
                type(other).__name__))

        # default_3way_compare from Python 2 as Python code
        # same type but no ordering defined, go by id
        if type(self) is type(other):
            return id(self) < id(other)

        # None always comes first
        if self is None:
            return True
        if other is None:
            return False

        # Sort by typename, but numbers are sorted before other types
        self_tname = '' if isinstance(self, Number) else type(self).__name__
        other_tname = '' if isinstance(other, Number) else type(other).__name__

        # print(self_tname)
        # print(other_tname)
        # print(self_tname < other_tname)
        # print("++++++++++++")

        if self_tname != other_tname:
            return self_tname < other_tname

        # same typename, or both numbers, but different type objects, order
        # by the id of the type object
        return id(type(self)) < id(type(other))

@per_type_cmp(dict)
def dict_cmp(a, b, _s=object()):
    if len(a) != len(b):
        return len(a) < len(b)
    adiff = min((k for k in a if a[k] != b.get(k, _s)), key=python2_sort_key, default=_s)
    if adiff is _s:
        # All keys in a have a matching value in b, so the dicts are equal
        return False
    bdiff = min((k for k in b if b[k] != a.get(k, _s)), key=python2_sort_key)
    if adiff != bdiff:
        return python2_sort_key(adiff) < python2_sort_key(bdiff)
    return python2_sort_key(a[adiff]) < python2_sort_key(b[bdiff])

@per_type_cmp(tuple)
def tuple_cmp(a, b, _s=object()):
    # see https://hg.python.org/cpython/file/tip/Objects/tupleobject.c
    # check element by element to find ones less than others
    for i in range(min(len(a),len(b))):
        # any element less than another element gives true
        if python2_sort_key(a[i]) < python2_sort_key(b[i]):
            return True
        elif python2_sort_key(a[i]) > python2_sort_key(b[i]):
            return False
    # if one is shorter, that is less
    if len(a) != len(b):
        return len(a) < len(b)
    else:
        # otherwise they are equal, same length and not <
        return False

@per_type_cmp(list)
def list_cmp(a, b, _s=object()):
    # see https://hg.python.org/cpython/file/tip/Objects/tupleobject.c
    # check element by element to find ones less than others
    for i in range(min(len(a),len(b))):
        # any element less than another element gives true
        if python2_sort_key(a[i]) < python2_sort_key(b[i]):
            return True
        elif python2_sort_key(a[i]) > python2_sort_key(b[i]):
            return False
    # if one is shorter, that is less
    if len(a) != len(b):
        return len(a) < len(b)
    else:
        # otherwise they are equal, same length and not <
        return False

################################################################################################################################################################

countree = 0
# change this to change order

leaflist = None
EXPRESSION_ROOT_TRANSLATE = {'f':'b'}
EXPRESSION_BRANCH_TRANSLATE = {'f':'A'}
EXPRESSION_TIP_TRANSLATE = {'f':'c'}

def addleaf(tree):
    newtrees = []
    for leaf in leaflist:
        treecopy = deepcopy(tree)
        # add a branch to the tree root
        if is_string(treecopy):
            treecopy = (treecopy,[leaf])
        else:
            treecopy[1].append(leaf)
        newtrees.append(treecopy)
        if not is_string(tree):
            for i,subtree in enumerate(tree[1]):
                # add a leaf to every tree
                subleaves = addleaf(subtree)
                # deepcopy the trees
                for subleaf in subleaves:
                    newtree = deepcopy(tree)
                    newtree[1][i] = deepcopy(subleaf)
                    newtrees.append(newtree)
    # XXXX: comment following lines in order to accurately count duplicates for thesis document
    #       add in return newtrees at end of function
    #       takes 2min5s instead of 17s, and gammas, sigmas and sums will be wrong
    newtrees = [tree_sort(newtree) for newtree in newtrees]
    newtrees2 = []
    # this is weird
    [newtrees2.append(i) for i in newtrees if not i in newtrees2]
    return newtrees2
    # return newtrees

def is_string(object):
    return type(object) is str

def is_tuple(object):
    return type(object) is tuple

def tree_sort(tree):
    if is_string(tree) or is_string(tree[1]):
        return tree
    else:
        sorted_tree_1 = []
        for t in tree[1]:
            if type(t) is tuple:
                sorted_tree_1.append((t[0],[tree_sort(tt) for tt in t[1]]))
            else:
                # XXXX can this only be a string
                sorted_tree_1.append(t)
        sorted_tree_1=sorted(sorted_tree_1,key=python2_sort_key)
        sorted_tree=(tree[0],sorted_tree_1)
        return sorted_tree

def tree_order(tree):
    repr_tree = repr(tree)
    # is this always accurate?
    return repr_tree.count('\'')/2

def tree_gamma(tree):
    gamm = 1
    # calculate gamma
    # first one
    gamm *= tree_order(tree)
    # now start stripping things away
    subtrees = tree
    if type(tree) is not str:
        for subtree in subtrees[1]:
            gamm *= tree_gamma(subtree)
        # while True:
        #     new_subtrees = []
        #     for subtree in subtrees[1]:
        #         gamm *= tree_order(subtree)
        #         new_subtrees.extend(subtree)
        #     subtrees=new_subtrees
        #     if all([(type(subtree) == types.StringType) for subtree in subtrees]):
        #         break
    return gamm

def tree_sigma(tree):
    if not is_string(tree):
        # partition the tree
        # (functools.cmp_to_key(cmp_python2_behaviour))
        tree_sorted = (tree[0],sorted(tree[1],key=python2_sort_key))
        partitions = {}
        start_index = 0
        for i,subtree in enumerate(tree_sorted[1]):
            if i == len(tree_sorted[1])-1:
                partitions[(start_index,i)] = subtree
            elif tree_sorted[1][i+1] != subtree:
                partitions[(start_index,i)] = subtree
                start_index = i+1
            else:
                pass
        sigma = 1
        for partition in partitions:
            sigma*=m.factorial((partition[1]-partition[0])+1)
        for subtree in tree_sorted[1]:
            if not is_string(subtree):
                sigma*=tree_sigma(subtree)
    else:
        sigma=1
    return sigma

def tree_alpha(tree):
    return (m.factorial(tree_order(tree)))/(tree_sigma(tree)*tree_gamma(tree))

def tree_scalar_sum():
    pass

def index_tree(tree,index):
    try:
        inner = tree[index[0]]
        for indici in index[1:]:
            inner =  inner[1][indici]
    except IndexError:
         return None
    return inner

def make_expression_levels(tree):
    current_index = 0
    index_stack = [0]
    highest_used_index = 0
    # XXXX: second part of A[,] always appears on the second level
    expression_levels = []
    # do a depth first search on the tree building up the expressions
    tree_index = [0]
    while True:
        # should we increment across the tree rather than diving in
        backout = False
        if ((len(tree_index) == 1 and tree_index[0] < len(tree[1]) and is_string(tree[1][tree_index[0]]))
            or
            index_tree(tree[1],tree_index) != None and is_string(index_tree(tree[1],tree_index))):
            # XXXX don't add new indices in the case of a c
            # is this one a c[], if it's an A[,] then we will get it in the else
            # don't increment expression level if we are incrementing across
            expression_levels.append(current_index)
            if ((len(tree_index) == 1
                 and
                 tree_index[0] < len(tree[1]))
                or
                tree_index[-1] <= len(index_tree(tree[1],tree_index[:-1])[1])):
                tree_index[-1] += 1
            else:
                backout = True
        elif is_tuple(index_tree(tree[1],tree_index)) and index_tree(tree[1],tree_index) != None:
            # go deeper and a new index
            # add an A[,] to connect old and new
            highest_used_index += 1
            expression_levels.append((current_index,highest_used_index,index_tree(tree[1],tree_index)[0]))
            # deal with indices
            index_stack.append(current_index)
            current_index = highest_used_index
            tree_index.append(0)
        else:
            backout = True
        if backout == True:
            # start backing out if tree can't be incremented validly
            while len(tree_index) > 1 and (tree_index[-1] >= (len(index_tree(tree[1],tree_index[:-1])[1]) - 1)):
                tree_index = tree_index[:-1]
                # pop the index stack
                current_index = index_stack[-1]
                index_stack = index_stack[:-1]
            if len(tree_index) == 0 or ((len(tree_index) == 1 and tree_index[-1] >= len(tree[1]))):
               # is this the last branch in the top level
               break
            else:
                tree_index[-1] += 1
    # print("----------")
    # print(tree)
    # print(expression_levels)
    return expression_levels

def indent_expression(expression,indent=4):
    split_expression = expression.split('\n')
    split_expression = [line.rstrip() for line in split_expression]
    split_expression = [(indent*' '+line) for line in split_expression]
    return '\n'.join(split_expression) + '\n'

def make_expression(expression_levels):
    # turn out top part of expression
    expression_top = ['bi1']
    # find the max index in the expression
    max_index = 0
    for i in expression_levels:
        if type(i) is tuple:
            expression_top.append(EXPRESSION_BRANCH_TRANSLATE[i[2]] + 'i' + str(i[0]+1) + 'i' + str(i[1]+1))
            max_index = max(i[0],i[1],max_index)
        else:
            expression_top.append('ci' + str(i+1))
            max_index = max(i,max_index)
    # print(expression_top)
    expression_nested = []
    for j in range(max_index+1):
        expression_nested.append([])
        for i in expression_levels:
            if type(i) is tuple:
                if j == i[0]:
                    expression_nested[j].append(i)
                elif j == i[1]:
                    expression_nested[j].append((None,i[1],i[2]))
            else:
                if j == i:
                    expression_nested[j].append(i)
    expression_nested = [list(set(item)) for item in expression_nested]
    # convert into real stuff
    expression_iter = []
    expression_zip = []
    initial = True
    for j in expression_nested:
        if initial:
            expression_iter.append(['bi1'])
            expression_zip.append(['b'])
            initial = False
        else:
            expression_iter.append([])
            expression_zip.append([])
        for i in j:
            if type(i) is tuple:
                if i[0] == None:
                    expression_iter[-1].append(EXPRESSION_BRANCH_TRANSLATE[i[2]] + 'i' + str(i[1]+1))
                    expression_zip[-1].append(EXPRESSION_BRANCH_TRANSLATE[i[2]] + 't')
                else:
                    expression_iter[-1].append(EXPRESSION_BRANCH_TRANSLATE[i[2]] + 'i' + str(i[0]+1) + 'i' + str(i[1]+1))
                    expression_zip[-1].append(EXPRESSION_BRANCH_TRANSLATE[i[2]] + 'i' + str(i[1]+1))
            else:
                expression_iter[-1].append('ci' + str(i+1))
                expression_zip[-1].append('c')
    # print(expression_iter)
    z = len(expression_iter)
    expression_final = ''
    for i in range(z):
        expression_final += 2*i*' ' + 'sum(\n'
    expression_final = expression_final[:-1]
    expression_final += '*'.join(expression_top) + '\n'
    for i in range(z):
        if len(expression_zip[i]) == 1:
            expression_final += (2*z*' '+2*i*' '+'for ' + ','.join(expression_iter[i]) + ' in ' + ','.join(expression_zip[i])) + ')\n'
        else:
            expression_final += (2*z*' '+2*i*' '+'for ' + ','.join(expression_iter[i]) + ' in zip(' + ','.join(expression_zip[i])) + '))\n'
    return expression_final

# TODO: appears to be obsolete
# def tree_filter_leaves(tree):
#     new_tree = []
#     for i,t in enumerate(tree[1]):
#         if is_string(tree[1][i]):
#             new_tree.append('f')
#         else:
#             new_tree.append(tree_filter_leaves(tree[1][i]))
#     return (tree[0],new_tree)

# TODO: appears to be obsolete
# def tree_eliminate_duplicates(treelist):
#     treelist = [tree_sort(tree) for tree in treelist]
#     newtreelist = []
#     [newtreelist.append(i) for i in treelist if not i in newtreelist]
#     return newtreelist

def create_standard_trees2(order):
    global leaflist
    leaflist = ['f']
    trees = {1:leaflist}
    trees = {1:[(leaf,[]) for leaf in leaflist]}
    for i in range(2,order+1):
        trees[i] = []
        for tree in trees[i-1]:
            trees[i].extend(addleaf(tree))
        print("----------------------------------------")
        print("Order: ", i)
        print("Count before sort: ", len(trees[i]))
        trees[i] = [tree_sort(tree) for tree in trees[i]]
        trees2 = []
        [trees2.append(j) for j in trees[i] if not j in trees2]
        trees[i] = trees2
        print("Count after sort and depulicate: ", len(trees[i]))
    pprint(trees)
    return trees

def create_standard_trees(order):
    global leaflist
    trees=create_standard_trees2(order)
    pprint([len(trees[tree]) for tree in trees])
    os.makedirs('generated_trees')
    fh = open('generated_trees/rk_trees.py','w')
    # write out gammas
    fh.write('gammas = {')
    ii = len(trees)
    for i,tree in enumerate(trees):
        if i != 0:
            fh.write('          ')
        fh.write(str(i+1)+':[')
        jj = len(trees[tree])
        for j,t in enumerate(trees[tree]):
            fh.write(str(tree_gamma(t)))
            if j != jj-1:
                fh.write(',')
        fh.write(']')
        if i == ii-1:
            fh.write('}\n\n')
        else:
            fh.write(',\n')
    # write out sigmas
    fh.write('sigmas = {')
    ii = len(trees)
    for i,tree in enumerate(trees):
        if i != 0:
            fh.write('          ')
        fh.write(str(i+1)+':[')
        jj = len(trees[tree])
        for j,t in enumerate(trees[tree]):
            fh.write(str(tree_sigma(t)))
            if j != jj-1:
                fh.write(',')
        fh.write(']')
        if i == ii-1:
            fh.write('}\n\n')
        else:
            fh.write(',\n')
    for i,tree in enumerate(trees):
        for j,t in enumerate(trees[tree]):
            make_expression_levels(t)
    # write out alphas
    fh.write('alphas = {')
    ii = len(trees)
    for i,tree in enumerate(trees):
        if i != 0:
            fh.write('          ')
        fh.write(str(i+1)+':[')
        jj = len(trees[tree])
        for j,t in enumerate(trees[tree]):
            fh.write(str(tree_alpha(t)))
            if j != jj-1:
                fh.write(',')
        fh.write(']')
        if i == ii-1:
            fh.write('}\n\n')
        else:
            fh.write(',\n')
    for i,tree in enumerate(trees):
        # print(trees[tree])
        for j,t in enumerate(trees[tree]):
            make_expression_levels(t)
    # write out the scalar sums
    fh.write('def rk_classic_scalar_sums(A,b,c,maxorder=8):\n')
    fh.write('    orders = {}\n')
    for i,tree in enumerate(trees):
        fh.write('    if ' + str(i+1) + ' <= maxorder: \n')
        # TODO: relative import wasn't here originally for 2.7, and still unsure why I had to add it
        fh.write('        from .rk_trees' + make_doubledigit_string(i+1) + ' import scalarsums' + make_doubledigit_string(i+1) + '\n')
        fh.write('        orders[' + str(i+1) + ']=scalarsums' + make_doubledigit_string(i+1) + '(A,b,c)\n')
    fh.write('    return orders\n\n')
    for i,tree in enumerate(trees):
        fhs = open('generated_trees/rk_trees' + make_doubledigit_string(i+1) + '.py','w')
        fhs.write('def scalarsums' + make_doubledigit_string(i+1) + '(A,b,c):\n')
        fhs.write('    At = A.T\n')
        fhs.write('    return [\n')
        jj = len(trees[tree])
        for j,t in enumerate(trees[tree]):
            expression = indent_expression(make_expression(make_expression_levels(t)),indent=4)
            if j == jj-1:
                fhs.write(expression.rstrip())
            else:
                fhs.write(expression.rstrip()+',\n')
        fhs.write(']\n\n')
        fhs.close()
    fh.close()

def make_doubledigit_string(i):
    return '%02.0f' % i

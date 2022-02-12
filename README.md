## Example code from my Ph.D. thesis work

This repository is an example of Python code used in my Ph.D. thesis
work.  Some of the code is based on
[SageMath](https://www.sagemath.org/), which is a CAS (computer
algebra system) built on top of Python and the Python scientific
computing ecosystem.

The results of my work have not been published outside of my thesis
yet, this is only several files I use to demonstrate Python code I've
written.

The full code base if further described in my Ph.D. thesis found at:
https://harvest.usask.ca/handle/10388/11831

## Description of the code

### SageMath based code

The `maketrees.sage`, `maketrees_cached.sage`,
`maketrees_library.sage`, `maketrees_simple.sage` uses SageMAth to
generate Python code that evaluates certain rooted trees.  These
rooted trees are mathematical constructs used to derive the numerical
methods under study.  This code can be run with:

`sage maketrees.sage`

This will generate several Python files in a `generated trees`
subdirectory.  More information and references on rooted trees can be
found in Chapter 2 and 3 of my Ph.D. thesis linked above.

### Python based code

The `db_solver.py`, `db_watcher.py`, and `db_defaults.py` file are
part of code to run multiple numerical solvers in parallel at once and
keep the results updated in a PostgreSQL database.  Having the data on
performance of numerical methods in the PostgreSQL database allowed me
to perform both exploratory and final data analysis that would have
been extremely in other tools.

These files do not have any test code yet.

## Contact

Anyone who is interested in discussing the full code base or my thesis
work can contact me at boreal6502@gmail.com.

# Build log

- Plan: Python file whose module docstring is the prose, so markdown stays readable.
- First idea: print the file by reading it. Dropped, that is cheating.
- Used __doc__ for the prose and repr(s) for the code. Backslashes in the prose would break the byte match, so there are none.
- Visible cost: the triple-quote lines show on GitHub.
- check.sh runs the file and compares with cmp.

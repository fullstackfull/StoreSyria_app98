"""Brace/paren balance for Dart, strings stripped BEFORE comments.

The naive order (comments first) is wrong for any line containing a string that
holds `//` -- `startsWith('//')` loses its closing quote and both parens, which
is exactly how this reported a false imbalance three times running.
"""
import re, sys

STR = re.compile(r"""r?'(?:\\.|[^'\\\n])*'|r?"(?:\\.|[^"\\\n])*\"""")

def balance(path):
    b = p = 0
    for line in open(path, encoding='utf-8').read().splitlines():
        t = STR.sub('X', line)        # strings FIRST
        t = re.sub(r'//.*$', '', t)   # then comments
        b += t.count('{') - t.count('}')
        p += t.count('(') - t.count(')')
    return b, p

for path in sys.argv[1:]:
    b, p = balance(path)
    ok = (b == 0 and p == 0)
    print(f"  {'OK ' if ok else 'BAD'}  braces {b:+d}  parens {p:+d}   {path}")

from lwe_with_hints import *

import numpy as np
from random import randrange

import random

def genHint():
    # generate indices i of hints in error and secret
    # err_hint = [i,j..] (i<j) such that e[i] are known
    # sec_hint = [i,j..] (i<j)  such that s[i] are known
    # total hint = len(err_hint)+len(sec_hint) = n/2
    # sec_unk = [i,j..] (i<j) are remainding unknow secret
    n = len(A)
    num_err_hint = n/2
    num_sec_hint = n - num_err_hint

    err_hint = random.sample(range(n), int(num_err_hint))
    err_hint.sort()

    sec_hint = random.sample(range(n), int(num_sec_hint))
    sec_hint.sort()
    
    #err_unk = [i for i in range(n) if i not in err_hint]
    sec_unk = [i for i in range(n) if i not in sec_hint]
    
    return err_hint, sec_hint, sec_unk

def reduce(x, q):
    # inptut: x is a vector in [0,q]
    # output: y is a vector in [-q/2,q/2]
    xx = [ZZ(x[i]) for i in range(len(x))]
    
    for i in range(len(xx)):
        if xx[i] >= int(q/2):
            xx[i] -= q
        else:
            if xx[i] <= -int(q/2):
                xx[i]+= q
    return xx

def join(sec_unk, sec_hint, s_hint, s_unk):
    s = [0]*len(A)
    for i in range(len(sec_hint)):
        s[sec_hint[i]] = s_hint[i][0] 
    for i in range(len(sec_unk)):
        s[sec_unk[i]] = s_unk[i][0]
    return s

def solve(err_hint, sec_hint, sec_unk):
    vec_b = matrix(list(b)).T
    vec_s = matrix(list(s)).T
    vec_e = matrix(list(e)).T
    mat_A = matrix(A).T
    
    e_hint = vec_e[err_hint, :]
    s_hint = vec_s[sec_hint, :]
    
    A_unkq = matrix(Zmod(q),mat_A[err_hint, :][:, sec_unk])
    A_hint = mat_A[err_hint,:][:, sec_hint]
    vec_b_hint = vec_b[err_hint,:]
    
    s_unk = ~A_unkq*(vec_b_hint - e_hint - A_hint*s_hint)
    
    return reduce(join(sec_unk, sec_hint, s_hint, s_unk),q)

scheme = "Kyber512"
trials = 1
for i in range(trials):
  if scheme=="test":
    n = 10
    A,b,q,s,e = generateToyInstance( n = n, m = n, q = 7, eta = 2 )
  else:
    A,b,q,s,e = generateLWEInstance( scheme )
    
err_hint, sec_hint, sec_unk = genHint()
res = solve(err_hint, sec_hint, sec_unk)
print(res)
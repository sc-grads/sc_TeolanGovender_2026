import numpy as np

arr = np.arange(0,11)
print(arr,'\n','\n')

arradd = arr + arr
arrsub = arr - arr
arrmulti = arr * arr
arrmax = arr.max()
arrsin = np.sin(arr)
'''
try:
    arrdiv = arr / arr #returns error because of division by 0
except ZeroDivisionError:
'''


print(
    arradd,'\n',
    arrsub,'\n',
    arrmulti,'\n',
    arrmax,'\n',
    arrsin,'\n',
)


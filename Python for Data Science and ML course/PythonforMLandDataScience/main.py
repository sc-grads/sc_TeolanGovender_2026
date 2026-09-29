import numpy as np

#create an array of:
zer_arr = np.zeros(10)
one_arr = np.ones(10)
fiv_arr = np.ones(10) * 5
int_arr = np.arange(10,51)
even_arr = np.arange(10,51,2)
matrix3x3 = np.arange(0,9).reshape(3,3)
identity_matrix3x3 = np.eye(3)
rand_num = np.random.rand(1)
rand_25num = np.random.randn(25)

print(
    "array of zeros: ", zer_arr,'\n','\n',
    "array of ones: ", one_arr,'\n','\n',
    "array of fives: ", fiv_arr,'\n','\n',
    "array 10 - 50: ", int_arr,'\n','\n',
    ": ", even_arr,'\n','\n',
    ": ", matrix3x3,'\n','\n',
    ": ", identity_matrix3x3,'\n','\n',
    ": ", rand_num,'\n','\n',
    ": ", rand_25num,'\n','\n',
)
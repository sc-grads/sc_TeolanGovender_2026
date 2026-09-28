my_list = [1,2,3]
import numpy as np

arr = np.array(my_list)
my_mat = [[1,2,3],[4,5,6],[7,8,9]]
np.array(my_mat)
print(np.array(my_mat), "\n")

#arange([start,] stop[, step,], dtype=none)
np.arange(0,10, )
print(
    "np.arange: ", np.arange(0,10,1), "\n\n",
    np.zeros((2,3)), "\n\n",
    np.ones((2,3))
)


my_list = [1,2,3,4,5,6,7,8,9,10]
numpy_list = np.array([1,2,3,4,5,6,7,8,9,10])

print("normal list: ", my_list*2)
print("numpy array: ", numpy_list*2)

print(numpy_list.max())
print(numpy_list.min())
print(numpy_list.mean())
print(numpy_list.argmax())
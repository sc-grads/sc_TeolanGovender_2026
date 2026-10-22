import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt



print('\n','\n','-----------------Load Dataset-----------------','\n','\n')
df = pd.read_csv('csv/DATA/fake_reg.csv')
print(df.head())


print('\n','\n','-----------------Exploratory Data Analysis-----------------','\n','\n')
sns.pairplot(df)

print('\n','\n','-----------------Features and Target-----------------','\n','\n')

X = df[['feature1','feature2']].values# X = feature matrix - .values converts the Pandas DataFrame into a NumPy array
y = df['price'].values# y = target/label - .values converts the Pandas Series into a NumPy array

print(
    'X:',X[:5],'\n',
    'y:',y[:5]
)


print('\n','\n','-----------------Train Test Split-----------------','\n','\n')
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=0.30,random_state=42)

print(
    'X_train Shape:',X_train.shape,'\n',
    'X_test Shape:',X_test.shape,'\n',
    'y_train Shape:',y_train.shape,'\n',
    'y_test Shape:',y_test.shape
)


print('\n','\n','-----------------Feature Scaling-----------------','\n','\n')
from sklearn.preprocessing import MinMaxScaler
scaler = MinMaxScaler()


print('\n','\n','-----------------Fit Scaler to Training Data-----------------','\n','\n')
# Fit calculates the scaling parameters from X_train only
scaler.fit(X_train)


print('\n','\n','-----------------Transform Training and Test Data-----------------','\n','\n')
# Transform the data using the parameters learned from X_train
X_train = scaler.transform(X_train)
X_test = scaler.transform(X_test)

print(
    'X_train Min:',X_train.min(),'\n',
    'X_train Max:',X_train.max(),'\n',
    'X_train Shape:',X_train.shape
)




print('\n','\n','-----------------Part 2-----------------','\n','\n')

from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense


print('\n','\n','-----------------Create Neural Network-----------------','\n','\n')

model = Sequential()
# Hidden layer 1: 4 neurons
model.add(Dense(units=4,activation='relu'))
# Hidden layer 2: 4 neurons
model.add(Dense(units=4,activation='relu'))
# Hidden layer 3: 4 neurons
model.add(Dense(units=4,activation='relu'))
# Output layer: 1 neuron for the predicted price
model.add(Dense(units=1))

print(model.summary())





print('\n','\n','-----------------Compile Model-----------------','\n','\n')
# Optimizer controls how the network updates weights and biases
# MSE is appropriate for this regression problem
model.compile(optimizer='rmsprop',loss='mse')


print('\n','\n','-----------------Train Model-----------------','\n','\n')
history = model.fit(X_train,y_train,epochs=250,verbose=1)


print('\n','\n','-----------------Training History-----------------','\n','\n')
loss_df = pd.DataFrame(history.history)
print(loss_df.head())


print('\n','\n','-----------------Plot Training Loss-----------------','\n','\n')

loss_df.plot()

plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.title('Training Loss')

plt.show()
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

train = pd.read_csv('csv_files/titanic_train.csv')
print(train.head())

print('\n','\n','-----------------Missing Data-----------------','\n','\n')

sns.heatmap(train.isnull(),yticklabels=False,cbar=False,cmap='viridis')
print(train.isnull())# True = missing value
#plt.show()

print('\n','\n','-----------------Exploratory Data Analysis-----------------','\n','\n')
sns.set_style('whitegrid')
# Survival counts
sns.countplot(x='Survived',data=train)
#plt.show()

print('\n','\n','-----------------Survival by Sex-----------------','\n','\n')

sns.countplot(x='Survived',hue='Sex',data=train,palette='RdBu_r')

print('\n','\n','-----------------Survival by Passenger Class-----------------','\n','\n')

sns.countplot(x='Survived',hue='Pclass',data=train)

print('\n','\n','-----------------Age Distribution-----------------','\n','\n')
# Drop missing ages before plotting
sns.histplot(train['Age'].dropna(),bins=30,kde=False)

print('\n','\n','-----------------Age Distribution with Pandas-----------------','\n','\n')
train['Age'].plot.hist(bins=35,figsize=(10,4))

print('\n','\n','-----------------Siblings / Spouses-----------------','\n','\n')

sns.countplot(x='SibSp',data=train)

print('\n','\n','-----------------Fare Distribution-----------------','\n','\n')
train['Fare'].hist(bins=40,figsize=(10,4))




print('\n','\n','-----------------Part 2 - Age Imputation-----------------','\n','\n')

# Compare age distributions by passenger class
plt.figure(figsize=(10,7))
sns.boxplot(x='Pclass',y='Age',data=train)

print('\n','\n','-----------------Fill Missing Ages-----------------','\n','\n')

# Function to fill missing ages based on passenger class
def impute_age(cols):

    Age = cols['Age']
    Pclass = cols['Pclass']

    if pd.isnull(Age):
        if Pclass == 1:
            return 37
        elif Pclass == 2:
            return 29
        else:
            return 24
    else:
        return Age

# Apply function to Age and Pclass
train['Age'] = train[['Age', 'Pclass']].apply(impute_age,axis=1)
print(train[['Age', 'Pclass']].head())

print('\n','\n','-----------------Check Missing Age Values-----------------','\n','\n')
sns.heatmap(train.isnull(),yticklabels=False,cbar=False,cmap='viridis')
#plt.show()

print('\n','\n','-----------------Drop Cabin Column-----------------','\n','\n')
# Too many missing values to use effectively
train.drop('Cabin',axis=1,inplace=True)
print(train.head())

print('\n','\n','-----------------Drop Remaining Missing Values-----------------','\n','\n')
# Remove rows with remaining missing values
train.dropna(inplace=True)
sns.heatmap(train.isnull(),yticklabels=False,cbar=False,cmap='viridis') #recreate heatmap after applying cleaning
#plt.show()
print(train.isnull().sum())


print('\n','\n','-----------------Create Dummy Variables-----------------','\n','\n')
sex = pd.get_dummies(train['Sex'],drop_first=True,dtype=int)# Convert Sex into numerical columns
embark = pd.get_dummies(train['Embarked'],drop_first=True,dtype=int)# Convert Embarked into numerical columns

print(sex.head(),'\n',embark.head())

print('\n','\n','-----------------Add Dummy Variables-----------------','\n','\n')
# Add dummy columns to the original DataFrame
train = pd.concat([train,sex,embark],axis=1)
print(train.head())

print('\n','\n','-----------------Drop Unnecessary Columns-----------------','\n','\n')
# Remove original categorical/text columns
train.drop(['Sex','Embarked','Name','Ticket'],axis=1,inplace=True)
print(train.head())

print('\n','\n','-----------------Drop Passenger ID-----------------','\n','\n')
# PassengerId is only an index and isn't useful for prediction
train.drop('PassengerId',axis=1,inplace=True)
print(train.head(),'\n',train.columns)





print('\n','\n','-----------------Part 3 - Features & Target-----------------','\n','\n')

# X = features, y = target
X = train.drop('Survived',axis=1)
y = train['Survived']
print(X.head(),'\n',y.head())

print('\n','\n','-----------------Train Test Split-----------------','\n','\n')
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=0.30,random_state=101)

print(
    X_train.shape,'\n',
    X_test.shape,'\n',
    y_train.shape,'\n',
    y_test.shape
)

print('\n','\n','-----------------Logistic Regression Model-----------------','\n','\n')
from sklearn.linear_model import LogisticRegression

logmodel = LogisticRegression()
logmodel.fit(X_train,y_train)# Train the model

print('\n','\n','-----------------Predictions-----------------','\n','\n')
# Make predictions using the test features
predictions = logmodel.predict(X_test)
print(predictions)

print('\n','\n','-----------------Classification Report-----------------','\n','\n')
from sklearn.metrics import classification_report
print(classification_report(y_test,predictions))

print('\n','\n','-----------------Confusion Matrix-----------------','\n','\n')
from sklearn.metrics import confusion_matrix

print(confusion_matrix(y_test,predictions))
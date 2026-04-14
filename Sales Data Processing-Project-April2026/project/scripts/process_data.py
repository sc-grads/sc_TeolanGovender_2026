import pandas as pd
import datetime

data_set = pd.read_csv(r"/mnt/c/sc_TeolanGovender_2026/Sales Data Processing-Project-April2026/project/data/Messy_Sales_Data.csv")

#print whole dataset
pd.set_option('display.max_columns', None, 'display.width', None)
print(f'********************************************************************************\n'
      f'Uncleaned Dataset:\n'
      f'********************************************************************************\n'
      f'{data_set}\n')

print(f'********************************************************************************')
print(f'Inspecting Dataset')
print(f'********************************************************************************')

#tells me how many fields are empty in each row
print(f'Empty fields per column are as follows:\n{data_set.isnull().sum()}')

# Find duplicate rows based on transaction ID
print('\nChecking row duplication...')
duplicates = data_set[data_set.duplicated(subset='transaction_id')]
if duplicates.empty:
    print(f'No duplicated rows found\n')
else:
    print(f'duplicated rows found:'
          f'\nDuplicated rows based on transactionID are as follows:\n{duplicates}\n')
    data_set= data_set.drop_duplicates()

#check data types
for column in data_set.columns:
    print(f'Checking data type for {column}...{(pd.api.types.infer_dtype(data_set[column]))}')

print('')

# ensuring names are consistent
for col in ['product', 'category', 'region', 'salesperson']:
    data_set[col] = data_set[col].str.strip().str.title()
    print(f'Setting consistent strings for {col} if none...')

#cleaning missing values for salesperson
map_ = {'North':'John', 'East':'David', 'South':'Mary', 'West':'Sarah'}
data_set['salesperson'] = data_set['salesperson'].fillna(data_set['region'].map(map_))


# ensure all numeric fields are consistently numeric
data_set['quantity'] = pd.to_numeric(data_set['quantity'], errors='coerce')
data_set["quantity"] = data_set["quantity"].fillna(data_set["quantity"].mean())
data_set['price'] = pd.to_numeric(data_set['price'], errors='coerce')
data_set["price"] = data_set["price"].fillna(data_set["price"].mean())
print('formatting consistent numerical values...')

# ensure all date fields are consistent
data_set['date'] = pd.to_datetime(data_set["date"], errors='coerce')
print('Setting consistent date formats if none...\n')
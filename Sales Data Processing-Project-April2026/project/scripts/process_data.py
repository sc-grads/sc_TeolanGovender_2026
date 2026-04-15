import pandas as pd
import datetime
import calendar

data_set = pd.read_csv(r"/mnt/c/sc_TeolanGovender_2026/Sales Data Processing-Project-April2026/project/data/Messy_Sales_Data.csv")

#Create backup uncleaned Data
data_set.to_csv('../data/Messy_Sales_Data_Backup.csv', index=False)
print(f'Creating backup dataset...')

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
data_set["quantity"] = data_set["quantity"].fillna(data_set["quantity"].mean().round(0))
data_set['price'] = pd.to_numeric(data_set['price'], errors='coerce')
data_set["price"] = data_set["price"].fillna(data_set["price"].mean())
data_set['quantity'] = data_set['quantity'].astype(int).replace(r'\.0', '', regex=True) # removes trailing .0
print('formatting consistent numerical values...')

# ensure all date fields are consistent
data_set['date'] = pd.to_datetime(data_set["date"], errors='coerce')
print('Setting consistent date formats if none...\n')

#create new calculated fields for revenue = quantity * price
g = data_set.groupby('quantity')
data_set['revenue'] = data_set['quantity'] * data_set['price']

#create a month column to extract the month from the date
data_set['month'] = pd.to_datetime(data_set['date']).dt.month
data_set['month'] = data_set['month'].apply(lambda x: calendar.month_name[x])
print(f'*********************************************************************************************************\n'
      f'New dataset with calculated fields:\n'
      f'*********************************************************************************************************\n'
      f'{data_set}')

# Export to new file
data_set.to_csv('../output/clean_sales.csv', index=False)
print('\nsaving new dataset "clean_sales.csv" to output...')

print('\n****************************************************************************************')
print('Aggregated datasets')
print('****************************************************************************************')
#create aggregated datasets

# sales by region
print('Sales by region')
sales_by_region = data_set.groupby('region')['quantity'].sum().round(0)
print(sales_by_region)
sales_by_region.to_csv('../output/sales_by_region.csv')
print('saving sales by region dataset...')

print('****************************************************************************************')

# sales by product
print('sales by product')
sales_by_product = data_set.groupby('product')['quantity'].sum().round(0)
print(sales_by_product)
sales_by_product.to_csv('../output/sales_by_product.csv')
print('saving sales by product dataset...')

print('****************************************************************************************')

# Monthly revenue
print('Monthly revenue')
monthly_revenue = data_set.groupby('month')['revenue'].sum().round(0)
print(monthly_revenue)
monthly_revenue.to_csv('../output/monthly_revenue.csv')
print('saving monthly revenue dataset...')

print('****************************************************************************************')

# salesperson performance
print('salesperson performance')
salesperson_performance = data_set.groupby('salesperson')['revenue'].sum().round(0)
print(salesperson_performance)
salesperson_performance.to_csv('../output/salesperson_performance.csv')
print('saving salesperson performance dataset...')

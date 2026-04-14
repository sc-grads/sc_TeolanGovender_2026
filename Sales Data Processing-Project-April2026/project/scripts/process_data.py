import pandas as pd
import datetime

data_set = pd.read_csv(r"/mnt/c/sc_TeolanGovender_2026/Sales Data Processing-Project-April2026/project/data/Messy_Sales_Data.csv")

#print whole dataset
pd.set_option('display.max_columns', None, 'display.width', None)
print(f'********************************************************************************\n'
      f'Uncleaned Dataset:\n'
      f'********************************************************************************\n'
      f'{data_set}\n')
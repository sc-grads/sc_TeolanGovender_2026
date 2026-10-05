print('\n','\n','-----------------Predictions-----------------','\n','\n')

# Make predictions using the test features
predictions = lm.predict(X_test)

print(
    predictions
)

print('\n','\n','-----------------Predictions vs Actual Values-----------------','\n','\n')

# Compare actual prices with predicted prices
plt.scatter(
    y_test,
    predictions
)

plt.xlabel('Actual Prices')
plt.ylabel('Predicted Prices')
plt.title('Actual vs Predicted Prices')

print('\n','\n','-----------------Residuals-----------------','\n','\n')

# Residual = actual value - predicted value
residuals = y_test - predictions

# Plot distribution of residuals
sns.histplot(
    residuals,
    kde=True
)

plt.xlabel('Residual')
plt.title('Distribution of Residuals')

print('\n','\n','-----------------Regression Evaluation Metrics-----------------','\n','\n')

from sklearn import metrics

# Mean Absolute Error
mae = metrics.mean_absolute_error(
    y_test,
    predictions
)

# Mean Squared Error
mse = metrics.mean_squared_error(
    y_test,
    predictions
)

# Root Mean Squared Error
rmse = np.sqrt(mse)

print(
    'Mean Absolute Error:', mae,'\n',
    'Mean Squared Error:', mse,'\n',
    'Root Mean Squared Error:', rmse
)
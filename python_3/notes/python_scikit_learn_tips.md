### Scikit-learn tips

1. Use `fit_transform()` on training data, but `transform()` only on test data. You should not use `fit_transform()` on both training & test data **because**, it will apply the same transformations on both sets of data, which creates consistent columns and **prevents data leakage**
2. test data results from `train_test_split()` function.
3. `New data` is out of sample data where you don't know the target variable.
4. data leakage is when the model is learning from the test data. This should be avoided at all cost.
5. 
### Scikit-learn tips

1. Use `fit_transform()` on training data, but `transform()` only on test data. You should not use `fit_transform()` on both training & test data **because**, it will apply the same transformations on both sets of data, which creates consistent columns and **prevents data leakage**. 
2. `fit()` is the method you call to fit or 'train' your transformer, like you would a classifier or regression model. As for `transform()`, that is the method you call to actually transform the input data into the output data. For instance, calling `Binarizer.transform([8,2,2])` (after fitting!) might result in `[[1,0],[0,1],[0,1]]`.
3. test data results from `train_test_split()` function.
4. `New data` is out of sample data where you don't know the target variable.
5. data leakage is when the model is learning from the test data. This should be avoided at all cost.


### Data Modelling Tips

1. From the [documentation](https://scikit-learn.org/stable/modules/generated/sklearn.pipeline.Pipeline.html), the purpose of `pipeline` in Python  is to assemble several steps that can be cross-validated together while setting different parameters. A List of (name, transform) tuples (implementing fit/transform) that are chained.
2. In simple terms, Pipeline is just an abstract notion, it's not some existing ml algorithm. Often in ML tasks you need to perform sequence of different transformations (find set of features, generate new features, select only some good features) of raw dataset before applying final estimator. See this [SO post](https://stackoverflow.com/questions/33091376/python-what-is-exactly-sklearn-pipeline-pipeline) 
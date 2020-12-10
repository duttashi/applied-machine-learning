In Machine Learning parlance, the following nomenclature is used;

- `X` : referes to the data
- `y`: refers to the label

The `X` and `y` are esepcially helpful in a classification task. 
When the dataset needs to be split into train and test set, then the `X` and `y` split is quite helpful.
Example: `from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
iris_dat = load_iris()
X_train, X_test, y_train, y_test = train_test_split(iris_dat['data'],
                                                    iris_dat['target'],
                                                    random_state=0)` 
## An idiot's guide to evaluation metrics for machine learning

### 1. Supervised learning for classification problems

- Confusion matrix

I've always had difficulty recalling confusion matrix. The way, I understood it was by breaking down its syntax into simple terms. Example;

- True Positive (TP): TP consist of `True` + `Positive`. Llook at positive and read it as Yes. Then look at True and read it as True. Simplyfied, it says; You predicted Yes and observations were actually labelled Yes.
- True Negative (TN): You predicted No and and observations were actually labelled No.
- False Positive (FP): You predicted Yes and observations were actually labelled No. This is `Type I error`.
- False Negative (FN): You predicted No and observations were actually labelled Yes. This is `Type II error`. 
- Accuracy: Mathematically defined as (TP+TN)/Total. It tells you how often the classifier is correct in making the predictions. **Caution** For imbalanced data, do not rely on Accuracy.
- Recall: It answers the question: When it’s actually Yes, how often does the classifier predict yes? Mathematically calculated as TP/actual Yes.
- False Positive Rate (FPR) : It answers the question: When it’s actually no, how often does the classifier predict Yes? Mathematically calculated as FP/actual No. In this example, precision = 10/(35+10) = 0.22.
F1 Score: This is a harmonic mean of the Recall and Precision. Mathematically calculated as (2 x precision x recall)/(precision+recall). There is also a general form of F1 score called F-beta score wherein you can provide weights to precision and recall based on your requirement.

- Receiver Operator Characteristic (ROC) Curve: is a plot of the Recall (True Positive Rate) (on the y-axis) versus the False Positive Rate (on the x-axis) for every possible classification threshold. Whenever you apply a classifier to assign a label against an observation, the classifier generates a probability against the observation and not the label. The probability is the indicator of how confidently you can assign a label against the observation and then after comparing it with a preset threshold value you assign the label to it.

**Tip**

You would want to try to build a model that produces a ROC curve that is close to the upper left corner or in other words which have maximum Area Under the Curve (AUC). Also, if your AUC is less than 0.5 i.e. the ROC curve falls below the red line then your model is even worse than a model which is based on random guesses.

- Precision-Recall (PR) Curve: 

Another curve that is used to evaluate the classifier’s performance as an alternative to a ROC curve is a precision-recall curve (PRC), particularly in the case of imbalanced class distribution problems. It is a curve between precision and recall 

**Tip**
A good classifier will produce a PR-curve that is close to the upper right corner.

- Logarithmic Loss

Logarithmic Loss or Log Loss, tells you how confident the model is in assigning a class to an observation. If you use Log Loss as your performance metric you must assign a probability to each class for all the samples. For any given problem, a lower log-loss value means better predictions.

### 2. Supervised learning for regression problems

Another common type of machine learning problems in regression problems. Here, instead of predicting a discrete label/class for an observation, you predict a continuous value. 

- Mean Absolute Error (MAE)
Mean Absolute Error is the average of the difference between the original value and the predicted value. It gives you the measure of how far the predictions are from the actual output and obviously, you would want to minimize it. 

- Root Mean Square Error (RMSE)



- R Squared / Coefficient of Determination

R squared determines how much of the total variation in Y (dependent variable) is explained by the variation in X (independent variable).

A higher R-squared is preferable while doing linear regression. While a high r-square value gives you a sense of the goodness of fit of the model, it shouldn’t be used as the only metric to pick the best model. If you care about the absolute predictions then probably it’s better to check RMSE/MAE as well.

The drawback of R-Square is that if you add new predictors (X) to your model, the R-Square value only increases or remains constant but it never decreases because of which you cannot judge that by increasing the complexity of your model, are you making it more accurate? That is where Adjusted R-squared comes in, it increases only if the new predictor improves model accuracy.

- Adjusted R Square
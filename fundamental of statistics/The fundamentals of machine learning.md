### The fundamentals of machine learning

- Unsupervised

In unsupervised learning, a program does not learn from labeled data. Instead, it attempts to discover patterns in the data. For example, assume that you have collected data describing the heights and weights of people. An example of an unsupervised learning problem is dividing the data points into groups.
 
- Supervised

Now assume that the data is also labeled with the person's sex. An example of a
supervised learning problem is inducing a rule to predict whether a person is male or female based on his or her height and weight.

- Semi-supervised

Some types of problems, called semi-supervised learning problems, make use of both supervised and unsupervised data; these problems are located on the spectrum between supervised and unsupervised learning. An example of semi-supervised machine learning is reinforcement learning, in which a program receives feedback for its decisions, but the feedback may not be associated with a single decision. For example, a reinforcement learning program that learns to play a side-scrolling video game such as Super Mario Bros, may receive a reward when it completes a level or exceeds a certain score, and a punishment when it loses a life. 

- Common machine learning terminology

	- **Response variable** - is the output
	- **Features** - are the input
	- **Explanatory variables** - features that explain a phenomenon
	- **Training set/data** - features used for training the model
	- **Test set/data** - features used for testing the trained model

#### Machine Learning tasks

Two of the most common **supervised machine learning tasks** are `classifcation`
and `regression`. In classification tasks the program must learn to predict discrete values for the response variables from one or more explanatory variables. That is, the program must predict the most probable category, class, or label for new observations. Applications of classification include predicting whether a stock's price will rise or fall, or deciding if a news article belongs to the politics or leisure section. In regression problems the program must predict the value of a continuous response variable. Examples of regression problems include predicting the sales for a new product, or the salary for a job based on its description. Similar to classification, regression problems require supervised learning.

A common **unsupervised learning task** is to discover groups of related observations, called clusters, within the training data. This task, called clustering or cluster analysis, assigns observations to groups such that observations within groups are more similar to each other based on some similarity measure than they are to observations in other groups. Clustering is often used to explore a dataset. A common application of clustering is
discovering segments of customers within a market for a product. By understanding
what attributes are common to particular groups of customers, marketers can decide what aspects of their campaigns need to be emphasized.

**Dimensionality reduction** is another *common unsupervised learning task*. Dimensionality reduction is the process of discovering the explanatory variables that account for the greatest changes in the response variable.  

**Training data/set** comprise the experience that the algorithm uses
to learn. In supervised learning problems, each observation consists of an observed response variable and one or more observed explanatory variables.

**Test data/set** is a similar collection of observations that is used to evaluate the performance of the model using some performance metric. It is important that no observations from the training set are included in the test set. If the test set does contain examples from the training set, it will be difficult to assess whether the algorithm has learned to generalize from the training set or has simply memorized it.

**Validation/hold-out set** In addition to the training and test data, a third set of observations, called a validation or hold-out set, is sometimes required. The validation set is used to tune variables called **hyperparameters**, which control how the model is learned. The program is still evaluated on the test set to provide an estimate of its performance in the real world; its performance on the validation set should not be used as an estimate of the model's real-world performance since the program has been tuned specifically to the validation
data.

**Over-fitting** Memorizing the training set is called over-fitting. A program that memorizes its observations may not perform its task well, as it could memorize relations and structures that are noise or coincidence. Balancing memorization and generalization, or over-fitting and under-fitting, is a problem common to many machine learning algorithms. ***Regularization***, can be applied to a model to ***reduce over-fitting***. 

**Data partitioning**

There are no requirements for the sizes of the partitions, and they ***may vary according to the amount of data available***. It is common to allocate 50 percent or more of the data to the training set, 25 percent to the test set, and the
remainder to the validation set.

- Cross-validation

When training data is scarce, a practice called cross-validation can be used to train and validate an algorithm on the same data. In cross-validation, the training data is partitioned. The algorithm is trained using all but one of the
partitions, and tested on the remaining partition. The partitions are then rotated several times so that the algorithm is trained and evaluated on all of the data.

#### Performance measures, bias, and variance

There are two fundamental causes of prediction error: a model's **bias** and its **variance**.

A model with a high bias will produce similar errors for an input regardless of the training set it was trained with; the model biases its own assumptions about the real relationship over the relationship demonstrated in the training data.

Conversely a model with high variance, will produce different errors for an input depending on the training set that it was trained with. A model with high bias is inflexible, but a model with high variance may be so flexible that it models the noise in the training set. That is, a model with high variance over-fits the training data, while a model with high bias under-fits the training data.

Example: It can be helpful to visualize bias and variance as darts thrown at a
dartboard. Each dart is analogous to a prediction from a different dataset. A model with high bias but low variance will throw darts that are far from the bull's eye, but tightly clustered. A model with high bias and high variance will throw darts all over the board; the darts are far from the bull's eye and each other. A model with low bias and high variance will throw darts that are closer to the bull's eye, but poorly clustered. Finally, a model with low bias and low variance will throw darts that are tightly clustered around the bull's eye. Therefore, **An ideal model must have low bias and low variance**. Ideally, a model will have both low bias and variance, but efforts to decrease one will
frequently increase the other. This is known as the **bias-variance trade-off**.    

- ***Supervised learning performance measure metrics***


- ***Unsupervised learning performance measure metrics***

 







# Hyper-Parameter in Machine Learning 

Different ML algorithms are suitable for different types of problems or datasets [1]. In general, building an effective machine learning model is a complex and time-consuming process that involves determining the appropriate algorithm and obtaining an optimal model architecture by tuning its hyper-parameters (HPs) [2]. 

Two types of parameters exist in machine learning models: 
- one that can be initialized and updated through the data learning process (e.g., the weights of neurons in neural networks), named *model parameters*; while the other, named 
- *hyper-parameters*, cannot be directly estimated from data learning and must be set before training a ML model because they define the model architecture [3]. 
### Hyper-Parameter Optimisation (HPO)

The main aim of HPO is to automate hyper-parameter tuning process and make it possible for users to apply machine learning models to practical problems effectively (3). Some important reasons for applying HPO techniques to ML models are as follows [6]:

1. It reduces the human effort required, since many ML developers spend considerable time tuning the hyper-parameters, especially for large datasets or complex ML algorithms with a large number of hyper-parameters.

2. It improves the performance of ML models. Many ML hyper-parameters have different optimums to achieve best performance in different datasets or problems.

3. It makes the models and research more reproducible. Only when the same level of hyper-parameter tuning process is implemented can different ML algorithms be compared fairly; hence, using a same HPO method on different ML algorithms also helps to determine the most suitable ML model for a specific problem.

### Hyper-parameter classification

The hyper-parameter optimization process consists of four main components: an estimator (a regressor or a classifier) with its objective function, a search space (configuration space), a search or optimization method used to find hyper-parameter combinations, and an evaluation function to compare the performance of different hyper-parameter configurations.

Hyper-parameters are classified as continuous, discrete, and categorical hyper-parameters. 

### Hyper-parameter optimization techniques

- **Grid search (GS)** is one of the most commonly-used methods to explore hyper-parameter configuration space [120]. GS can be considered an exhaustive search or a brute-force method that evaluates all the hyper-parameter combinations given to the grid of configurations.
	- Drawbacks: inefficiency for high-dimensionality hyper-parameter configuration space, since the number of evaluations increases exponentially as the number of hyper-parameters grows. 
- **Random Search (RS)** To overcome certain limitations of GS, random search (RS) was proposed in [13]. RS is similar to GS; but, instead of testing all values in the search space, RS randomly selects a pre-defined number of samples between the upper and lower bounds as candidate hyper-parameter values, and then trains these candidates until the defined budget is exhausted. 
	- Drawback: There are still a large number of unnecessary function evaluations since it does not exploit the previously well-performing regions [2].

- **Gradient-based Optimization** Although gradient-based algorithms have a faster convergence speed to reach local optimum than the previously-presented methods.
	- *Drawbacks*: Firstly, they can only be used to optimize continuous hyper-parameters because other types of hyper-parameters, like categorical hyper-parameters, do not have gradient directions. Secondly, they are only efficient for convex functions because the local instead of a global optimum may be reached for non-convex functions.

- **Bayesian optimization (BO)** [83] is an iterative algorithm that is popularly used for HPO problems. Unlike GS and RS, BO determines the future evaluation points based on the previously-obtained results. 
	- BO models balance the exploration and the exploitation processes to detect the current most likely optimal regions and avoid missing better configurations in the unexplored areas. 
	- BO is more efficient than GS and RS since it can detect the optimal hyper-parameter combinations by analyzing the previously-tested values, and running a surrogate model is often much cheaper than running the entire objective function.
	- However, since Bayesian optimization models are executed based on the previously-tested values, they belong to sequential methods that are difficult to parallelize.

- **Multi-fidelity optimization algorithms**
One major issue with HPO is the long execution time, which increases with a larger hyper-parameter configuration space and larger datasets. The execution time can take several hours, several days, or even more [89]. Multi-fidelity optimization techniques are common approaches to solve the constraint of limited time and resources. 


**Bayesian Optimization in R**

- See this [link](https://www.r-bloggers.com/2020/03/grid-search-and-bayesian-hyperparameter-optimization-using-tune-and-caret-packages/)






**Refernces**

[1] M.-A. Zöller, M.F. Huber, Benchmark and Survey of Automated Machine Learning Frameworks, arXiv preprint arXiv:1904.12054, (2019). https://arxiv.org/abs/1904.12054

[2] R.E. Shawi, M. Maher, S. Sakr, Automated machine learning: State-of-the-art and open challenges, arXiv preprint arXiv:1906.02287, (2019). http://arxiv.org/abs/1906.02287

[3] M. Kuhn, K. Johnson Applied Predictive Modeling Springer (2013) ISBN: 9781461468493. 

[4] F. Hutter, L. Kotthoff, J. Vanschoren (Eds.), Automatic Machine Learning: Methods, Systems, Challenges, 9783030053185, Springer (2019)





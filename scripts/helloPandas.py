import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

pd.set_option("display.precision",2)

# read the data
df = pd.read_csv("../data/telecom_churn.csv")
#print(df.head())
print(df[df['State'].apply(lambda state: state[0] == 'W')].head())

sns.countplot(x='International plan', hue='Churn', data=df)
# In PyCharm IDE, to show the plot, use plt.show()
plt.show()

df['Many_service_calls'] = (df['Customer service calls'] > 3).astype('int')
pd.crosstab(df['Many_service_calls'], df['Churn'], margins=True)
sns.countplot(x='Many_service_calls', hue='Churn', data=df)
plt.show()

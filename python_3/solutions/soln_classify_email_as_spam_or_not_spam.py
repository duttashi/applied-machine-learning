"""
Created on Mon Oct  5 08:09:14 2020
Question: How to classify a new email as spam/not spam?
Background: Given a text email content, classify it as spam or not spam.
For example, given an email text like, "Hi, I am Andrew and I want too buy VIAGRA"
Then the program should classify it as SPAM
@author: Ashish
"""
import string

from nltk.corpus import stopwords
import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report,confusion_matrix, accuracy_score
from sklearn.naive_bayes import MultinomialNB

#  Define training data
# Spam = 1 Not Spam = 0
df = pd.DataFrame(data={'Email': [
    "Hi, I am Andrew and I want too buy VIAGRA",
    "Dear subscriber, your account will be closed",
    "Please click below to verify and access email restore",
    "Hi Anne, I miss you so much! Can’t wait to see you",
    "Dear Professor Johnson, I was unable to attend class today",
    "I am pleased to inform you that you have won our grand prize.",
    "I can’t help you with that cuz it’s too hard.",
    "I’m sorry to tell you but im sick and will not be able to come to class.",
    "Can I see an example before all are shipped or will that cost extra?",
    "I appreciate your assistance and look forward to hearing back from you.",], 
    'Spam': [1, 1, 1, 0, 0, 1, 0, 0, 0, 0]})

# show the dataframe
#print(df)

def fun(text):    
    # Removing Punctuations
    remove_punc = [c for c in text if c not in string.punctuation]
    remove_punc = ''.join(remove_punc)

    # Removing StopWords
    cleaned = [w for w in remove_punc.split() if w.lower() not in stopwords.words('english')]

    return cleaned

# Create a vectorizer object to enable both fit_transform and just transform
vectorizer = CountVectorizer(analyzer=fun)
X = vectorizer.fit_transform(df['Email'])

X_train, X_test, y_train, y_test = train_test_split(X, df['Spam'], test_size = 0.25, random_state = 0)

classifier = MultinomialNB()
classifier.fit(X_train, y_train)

pred = classifier.predict(X_test)

print(classification_report(y_test ,pred ))
print('Confusion Matrix: \n', confusion_matrix(y_test,pred))
print()
print('Accuracy: ', accuracy_score(y_test,pred))

## Testing the function on new data
# Given a new email
new_email = "Hi, my name is Christopher and I like VIAGRA"

# Apply the same preprocessing steps and transformation
X_new = vectorizer.transform([fun(new_email)])

# Predict new email with already trained classifier
preds = classifier.predict(X_new)
print(preds)

# Assign predicted accuracy to a label and assign it to a dataframe as a column
if (preds > .6):
    pred_label = "spam"
else:
    pred_label = "not spam"

y_test['pred_label'] = pred_label
df_out = pd.merge(df, y_test[['pred_label']],
                  how='left', left_index=True,
                  right_index=True)
print(df_out)
df.to_csv("tempdf.csv", index=False)
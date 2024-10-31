# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.16.4
#   kernelspec:
#     display_name: venv
#     language: python
#     name: venv
# ---

# %% [markdown]
# ## Brief Review - Classification and Naive Bayes
#
# The task of classification is to assign a *class* (or *label*) to a *data point*. That is, given some kind of data, you want to determine which class it belongs to. Depending on the kind of classification task, these labels can vary. Text classification refers to a family of tasks where the data points in question come in text form. Formally, a text classification problem can be framed as one where a model is given a string of tokens $\omega \in \Sigma^*$ and must assign it a class $c \in C$. 
#
# For instance, in *sentiment analysis*, a model is given some text (a movie review, or comments on media content, social media messages about a brand) and must label it's *sentiment*: is it positive, negative, or neutral? The classes $C$ here would be the labels *positive*, *negative*, and *neutral*.
#
# In *language identification* (or language ID), a model is given some text and must decide what language that text is written in. The classes here would be some set of languages, with perhaps a class indicating that the language couldn't be identified (or to capture languages we may have missed, not unlike an UNK token). 
#
# Beyond these examples, there are many other tasks that fall under this label, including (if we're careful about how we frame them) language modeling or grammar checking!
#
# In a probabilistic framework, our instinct should be to model $p(c \mid \omega)$ --- the likelihood of the category given the text input. Naive Bayes makes a few moves to make this a usable strategy:
#
# First, since we are meant to label outputs, we assign $\omega$ the category $c \in C$ that maximizes $p(c \mid \omega)$. We write this as $\text{arg}\max\limits_{c \in C} p(c \mid \omega)$ 
#
# Then, we observe that we can apply Bayes Rule to show that $p(c \mid \omega) = \frac{p(\omega \mid c)p(c)}{p(\omega)}$. Thus, we can say that 
#
# $$ \text{arg} \max\limits_{c \in C} p(c \mid \omega) = \text{arg} \max\limits_{c \in C} \frac{p(\omega \mid c)p(c)}{p(\omega)} $$.
#
# Finally, we observe that $p(\omega)$ will be the same for everything we're taking the argmax over. That is, we want to compare $\frac{p(\omega \mid c)p(c)}{p(\omega)}$ for every possible value of $c$, but changing $c$ doesn't change $p(\omega)$, so we can ignore it when computing the argmax. Thus, we get that our label for the string $\omega$ should be
#
# $$ \text{arg} \max\limits_{c \in C} p(c \mid \omega) = \text{arg} \max\limits_{c \in C} p(\omega \mid c)p(c) $$.
#
# Now we need to determine a way to estimate $p(\omega \mid c)$ (a *generative* model of the data (think of this as a language model specifically for class $c$!) and $p(c)$ (a probability distribution over the classes themselves!). 
#
#
# ## Your Task
#
# Let's build a Naive Bayes classifier! Following J&M, we will model our text as a *bag-of-words* --- that is, our features are going to be the words that appear in our text. Since this is Naive Bayes, we will assume our features are *indepedendent*, which means their we can decompose $p(\omega \mid c)$ into a product of the conditional probabilities of each feature (i.e., word): $\prod_{w \in \omega} p(w \mid C)$. Note that this is just a class-specific unigram LM!
#
# First, let's build the unigram LM part of our model. We'll load in a subset of the IMDB dataset released by [Maas et al. (2011)](https://ai.stanford.edu/~amaas/papers/wvSent_acl2011.pdf). This subset consists of 2500 IMDB reviews (1250 positive and 1250 negative) for training and 1000 (500 positive and 500 negative) for testing. 

# %%
path = "./data/train/{}.txt"

with open(path.format("pos")) as pos_data_f:
    pos_data = pos_data_f.read().split()

with open(path.format("neg")) as neg_data_f:
    neg_data = neg_data_f.read().split()

n_tokens = 40
print("{} tokens of positive review text".format(n_tokens))
print(pos_data[:n_tokens])

print("{} tokens of negative review text".format(n_tokens))
print(neg_data[:n_tokens])

# %% [markdown]
# Now let's build a unigram model. Of course, that's just counting word frequencies. I've made you do this several times already, so I'll provide the code to you this time!
#
# Note that this is essentially the WordCounter activity from COMP128 (Data Structures!). 

# %%
from typing import Sequence, Iterable, Mapping
import numpy as np

def get_logfreqs(data : Iterable[str]) -> Mapping[str, int]: 
    counts = {}
    total = 0
    for w in data:
        counts[w] = counts.get(w, 0) + 1
        total += 1
        
    logprobs = {}
    for w, c in counts.items():
        logprobs[w] = np.log2(c) - np.log2(total)
        
    return logprobs

pos_ulm = get_logfreqs(pos_data)
neg_ulm = get_logfreqs(neg_data)

# %% [markdown]
# Unfortunately, this likelihood model is not enough (as you might remember from 128!) --- the top 10 most-frequent tokens in our positive and negative unigram LMs are very similar: just highly frequent, content-neutral words & punctuation. These kinds of tokens are often referred to as *stop words*, and for some methods are pre-processed out.

# %%
print("top positive tokens: {}".format(", ".join(sorted(pos_ulm, key=pos_ulm.get, reverse=True)[:10])))
print("top negative tokens: {}".format(", ".join(sorted(neg_ulm, key=neg_ulm.get, reverse=True)[:10])))


# %% [markdown]
# Now let's build our Native Bayes Classifier! Again, for each input $\omega$ we just need to compute the predicted label $\hat{c}(\omega)$, defined as so:
#
# $$ \hat{c}(\omega) = \text{arg} \max\limits_{c \in C} \prod_{w \in \omega} p(w \mid c) p(c) $$
#
# You just need to translate this into code! To make it easier, we can note that since our training data is *balanced* $p(c)$ is *uniform*: That means, both classes have equal frequency in our data! I am going to claim that this means we can ignore the $p(c)$ term --- make sure you understand why this is true!
#
# Also keep in mind that in code, we work in *log probs* --- what does the equation look like then?
#
# A few implementation tricks:
# - if a word is not in the vocabulary (i.e., seen in the data), we ignore it. Since we're comparing across classes, something both unigram models can't model shouldn't influence our decision making. 

# %%
class NaiveBayesSentimentClassifier:

    def __init__(self, pos_data : Iterable[str], neg_data : Iterable[str]):
        self.classes = ["pos", "neg"]
        self.ulm = {}
        
        self.vocab = set(pos_data + neg_data)
        
        self.ulm["pos"] = self.get_logfreqs(pos_data) # P(c)
        self.ulm["neg"] = self.get_logfreqs(neg_data)


    def get_logfreqs(self, data : Iterable[str]) -> Mapping[str, int]: 
        counts = {}
        total = 0
        for w in data:
            counts[w] = counts.get(w, 0) + 1
            total += 1
        
        logprobs = {}
        for w, c in counts.items():
            logprobs[w] = np.log2(c) - np.log2(total)
        
        return logprobs # P(w|c)?

    def label(self, example : Iterable[str]) -> str:
        # TODO: Complete the function!
        # for each class (positive and negative)
            # compute the log likelihood
        log_likelihoods = {}
        for c in self.classes:
            log_likelihood = 0
            for w in example:
                #log_likelihood += self.ulm[c][w] * -1
                log_likelihood += self.ulm[c].get(w, 0)
            log_likelihoods[c] = log_likelihood

        return max(log_likelihoods, key = log_likelihoods.get)
                
        # determine the class with the highest log likelihood and return it
        # return None

# %%
imdb_bayes = NaiveBayesSentimentClassifier(pos_data, neg_data)

# %% [markdown]
# ### Testing!
#
# Now let's test our model's accuracy!
#
# Each review is newline separated, so we'll split on newlines and check the label our model produces for each one.

# %%
test_path = "./data/test/{}.txt"

with open(test_path.format("pos")) as pos_data_f:
    pos_test = pos_data_f.read().split("\n")

with open(test_path.format("neg")) as neg_data_f:
    neg_test = neg_data_f.read().split("\n")

# %%
print(imdb_bayes.label(neg_test[0].split())) # should classify as negative!
print(imdb_bayes.label(pos_test[42].split())) # should classify as positive!

# %% [markdown]
# If all goes well, we should get the two given examples right!
#
# However, we have a bit of a problem... The first is that a lot of reviews will actually have likelihood of 0 --- it contains a word that's only in positive training examples and another word that's only in negative training examples!
#
# For example, the following example contains the token *submarine* that never appeared in a positive review in training, and the token *pendant* which never appeared in a negative review in training, thus giving it 0 likelihood under both unigram models!

# %%
print(pos_test[0])
print(imdb_bayes.label(pos_test[0].split())) # The label depends on the your disambiguation strategy!


# %% [markdown]
# Depending on how you wrote your argmax code, this could result in a label being assigned by default (if both have a log-likelihood of $-\infty$ --- or any matching log-likelihood for that matter --- one specific label gets returned), you could return a label at random, or you could be extra conservative in your evaluation and return None or a 3rd label to ensure your model get's that example incorrect when testing.
#
# An easy and practical solution to this is to do something you should be very familiar with: Laplace/add-1 smoothing! It should be straightforward enough to create a smoothed version of our classifier by updating the `get_logfreqs` methods of the class, so let's inherit from our old classifier and override that method!

# %%
class LaplaceNaiveBayesSentimentClassifier(NaiveBayesSentimentClassifier):
    
    def get_logfreqs(self, data : Iterable[str]) -> Mapping[str, int]: 
        # TODO: Rewrite so we output a dictionary that maps every word in our 
        # vocab to it's laplace count
        counts = {}
        total = 0
        for w in data:
            counts[w] = counts.get(w, 0) + 1
            total += 1
        
        logprobs = {}
        for w, c in counts.items():
            logprobs[w] = np.log2(c) - np.log2(total)
        
        return logprobs # P(w|c)?


# %%
smoothed_imdb_bayes = LaplaceNaiveBayesSentimentClassifier(pos_data, neg_data)

# %% [markdown]
# And now we can verify:

# %%
print(smoothed_imdb_bayes.label(pos_test[0].split())) # Should now be classified correctly!


# %% [markdown]
# To close us out for Naive Bayes, lets actually compute our model's accuracy over the test set. Just loop over both halves of the test set and count how many we get right!

# %%
def evaluate(model : NaiveBayesSentimentClassifier, test_pos : Iterable[str], test_neg : Iterable[str]) -> float:
    # TODO: Complete this
    return 0.0


# %%
evaluate(imdb_bayes, pos_test, neg_test)

# %%
evaluate(smoothed_imdb_bayes, pos_test, neg_test)

# %% [markdown]
# Your test-set accuracy for the unsmoothed model should be somewhere between 22--92% (probably closer to 57%), since it's guessing on a whopping 70% of examples! The smoothed model should land at a much more stable ~83% --- Not so bad!

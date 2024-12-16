import numpy as np
from typing import Sequence, Mapping, Iterable
from data import *

class NBBaseline:
    # Input is iterable of tuple. where the tuple is (sequence of words) and (classification of that word)
    # Right now. data is not in the form... its just in a list of sequence of words.

    def __init__(self, train_data : Iterable[tuple[Sequence[str], int]]):
        self.classes = set([c for _, c in train_data])
        self.smoothed_totals = {}

        self.vocab = set()
        for t in train_data:
            self.vocab.update(t[0])

        self.ulm = {} # key = class, value = log-frequency map of words in that class
        for c in self.classes: # split data into classes
            class_data = [t[0] for t in train_data if t[1] == c] # a 2d list of all the words in the class, split by sentence
            self.ulm[c] = self.get_logfreqs(c, [item for sublist in class_data for item in sublist]) # flatten list

    def get_logfreqs(self, c: int, data : Iterable[str]) -> Mapping[str, int]:
        total = 0
        counts = {}
        for w in data:
            counts[w] = counts.get(w, 0) + 1
            total += 1
        smoothed_total = total + len(self.vocab) # smoothed using laplace smoothing
        self.smoothed_totals[c] = smoothed_total # store in class-specific dictionary for unknown words

        logprobs = {}
        for w in self.vocab:
            smoothed_count = counts.get(w, 0) + 1 # second part to laplace smoothing
            logprobs[w] = np.log(smoothed_count / smoothed_total)

        return logprobs

    def label(self, data : Iterable[str]) -> int:
        log_likelihoods = {}
        for c in self.classes:
            log_likelihood = 0
            for w in data:
                log_likelihood += self.ulm[c].get(w, np.log(1 / self.smoothed_totals[c])) # default log-frequency of unknown words
            log_likelihoods[c] = log_likelihood

        return max(log_likelihoods, key=log_likelihoods.get)

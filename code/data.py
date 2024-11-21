from typing import Iterable, Sequence, Mapping
import os
import json

class VoxEmotionData:
    """ A class to store data from Vox Podcasts. Acts as a dataloader
    """

    def __init__(self, data_path : str):
        self.labels = {
            "anger": 0,
            "anticipation": 1,
            "disgust": 2,
            "fear": 3,
            "joy": 4,
            "negative": 5,
            "positive": 6,
            "sadness": 7,
            "surprise": 8,
            "trust": 9
        }

        self.data = self.load_data(data_path + "{}-NRC-Emotion-Lexicon.txt")

    def load_data(self, data_path_fs : str) -> Iterable[tuple[Sequence[str], int]]:
        """ Load labeled data from the provided file path
        """

        out = []
        for label, y in self.labels.items():
            with open(data_path_fs.format(label)) as data_f:
                for line in data_f:
                    out.append((line.split(), y))

            # Consider using this to just get the words associated with that emotion
            # for line in data_f:
            #     # Split the word and label (tab-separated)
            #     word, value = line.strip().split("\t")
            #     if value == "1":  # Only consider words labeled with '1'
            #         out.append((word, y))
        return  out


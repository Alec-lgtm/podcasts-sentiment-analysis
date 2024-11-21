import argparse

parser = argparse.ArgumentParser()


parser.add_argument("--data", type=str, help="path to the data folder")
parser.add_argument("--task", type=str, help="task (emotion or VAD)")
parser.add_argument("--model", type=str, help="naive bayes or transformer")
parser.add_argument("--save", type=str, help="path to model file to save")
parser.add_argument("--load", type=str, help="path to model file to load")

parser.add_argument("--measure", type=str, help="report the provided measure (acc, precision, recall, f1) over the dev set")
parser.add_argument("--label", action="store_true", help="print out the predicted label of each datapoint in test set, newline separated")

args = parser.parse_args()

# data pathway is ."../data/NRC-Emotion-Lexicon/OneFilePerEmotion/"

if args.task == "emotion":
    dataset = VOXData(args.data)
elif args.task == "vad":
    dataset = AuthorIDData(args.data)



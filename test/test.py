import argparse

args = argparse.ArgumentParser()
args.add_argument("--example", type=str)

args = vars(args.parse_args())
print(args["example"])

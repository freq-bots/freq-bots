# This repo sets up freqtrade bots in dry run mode for 3 ticker values, for one strategy, and pushes the results to a common repo where all strategies can be compared

## Directions

### (Optional) Setup an ec2 virtual machine

Read the directions inside **Setting up an AWS EC2.pdf**

### Everything else

Do not make any changes to `dry_run_results` except for `awsbots.csv`. You can edit `awsbots.csv` to add your strategy. Do not delete anything from it(unless it is information you added yourself and you want it out), only add to it

1. git clone https://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@github.com/freq-bots/freq-bots
2. cd freq-bots
3. run `./setup-1.sh`
3. Add the strategy you want to test to `dry_run_results/awsbots.csv` and `strategies`
5. run `./setup-2.sh` 

The bot should now be running the strategy on all tickers and scheduled to push the results to github everyday



## Viewing results

You can view the results by running `git clone https://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@github.com/freq-bots-results/dry_run_results`
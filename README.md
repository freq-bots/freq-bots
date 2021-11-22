# This repo sets up freqtrade bots in dry run mode for 3 ticker values, for one strategy, and pushes the results to a common repo where all strategies can be compared

## Directions

### (Optional) [Setup an ec2 virtual machine](https://github.com/samgermain/freqtrade-ec2-instructions)

### Everything else

Do not make any changes to `dry_run_results`. You can edit `strategies/awsbots.csv` to add your strategy. Do not delete anything from it(unless it is information you added yourself and you want it out), only add to it

1. git clone https://github.com/freq-bots/freq-bots
2. cd freq-bots
3. run `./setup_1.sh`
3. Add the strategy you want to test to `strategies/awsbots.csv` and `strategies`
5. run `./setup_2.sh` 

The bot should now be running the strategy on all tickers and scheduled to push the results to github everyday



## Viewing results

key1=ghp_ws19A
key2=naO5M5WQ6
key3=mPX4PDLGT5zJYDCd1Frscc

You can view the results by running `git clone https://{key1}{key2}{key3}@github.com/freq-bots-results/dry_run_results`

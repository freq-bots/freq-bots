#Get strategy name
if [[ $# -eq 0 ]] ; then
    echo 'Provide a strategy: '
    read strategy_name
else
    strategy_name=$1
fi

#Get the ticker values that freqtrade will run using
ticker_input=""
while [[ $ticker_input -ne "1" ]] && [[ $ticker_input -ne "2" ]]; do
    echo "
    Which tickers? 
    1: 1m 15m 1h 
    2: 5m 30m 4h"
    read ticker_input
done
    
if [[ ticker_input -eq 1 ]]; then
    tickers="1m 15m 1h"
else
    tickers="5m 30m 4h"
fi

#Adds new strategy to strategy repo
git_dir_strat="$(pwd)/user_data/strategies"
git_repo_strat="https://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@github.com/freq-bots-results/strategies.git"
git -c $git_dir_strat config pull.rebase false
git -C $git_dir_strat add -A
git -C $git_dir_strat commit -m "Added ${strategy_name}"
git -C $git_dir_strat pull $git_repo_strat master 
git -C $git_dir_strat push $git_repo_strat master

#install dependencies
sudo apt-get update
sudo apt-get install python3.9 screen <<< 'y'
minute=$(awk -v strategy=$strategy_name -F ',' '$3==strategy {print $4}' dry_run_results/awsbots.csv)

#Download, and setup freqtrade
git clone https://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@github.com/freqtrade/freqtrade
cwd=$(pwd)
mv freqtrade ..
cd ../freqtrade
./setup.sh -i <<< 'n n n n'
rm -rf user_data
mv $cwd ./user_data

#Install dependencies for some strategies
~/freqtrade/.env/bin/python3 -m pip install sklearn ta

#Start freqtrade for every ticker value
for ticker in $tickers
do
    screen -d -m -s $ticker ~/freqtrade/.env/bin/python3 ~/freqtrade/freqtrade/main.py trade -s $strategy_name --db-url sqlite:///user_data/dry_run_results/${strategy_name}-${ticker}.dryrun.sqlite -c ~/freqtrade/user_data/config.json
done

begin="ghp"
mid="RJcCM31TberK1BmPZq"
end="HGLKDAF6sVHc3mAgit"
token="${begin}_${mid}_${end}"

git_dir="$(pwd)/user_data/dry_run_results"
git_repo="https://${token}@github.com/freq-bots-results/dry_run_results"

git -c $git_dir config pull.rebase false
hour=5

#Uncomment the next two lines to test
# minute=$(echo $(date "+%M")+1 | bc -l)
# hour=$(date "+%H" | sed 's/^0//g')

#Create a cronfile which will push to github at the same time every day
(crontab -l 2>/dev/null; echo "
    $(echo $minute + 0 | bc -l) $hour * * * git -C $git_dir add -A
    $(echo $minute + 1 | bc -l) $hour * * * git -C $git_dir commit -m 'Daily update ${strategy_name}'
    $(echo $minute + 2 | bc -l) $hour * * * git -C $git_dir pull $git_repo master
    $(echo $minute + 3 | bc -l) $hour * * * git -C $git_dir push $git_repo master
") | crontab -
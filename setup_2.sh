cwd=$(pwd)
freqtrade_dir="${cwd}/freqtrade"
initial_strategy_dir="${cwd}/strategies"
initial_results_dir="${cwd}/dry_run_results"
user_data="${freqtrade_dir}/user_data"
freqtrade_strategy_dir="${user_data}/strategies"
freqtrade_results_dir="${user_data}/dry_run_results"
aws_bots_csv="${freqtrade_strategy_dir}/awsbots.csv"
freqtrade_script="${freqtrade_dir}/freqtrade/main.py"
python="${freqtrade_dir}/.env/bin/python3"

function results_key {
    begin="ghp"
    mid="3PQpKb3Vay06C6Cjoy"
    end="RrS3YWxLS5TN0OGMjU"
    echo "${begin}_${mid}${end}"
}

git_repo="https://${results_key}@github.com/freq-bots-results"

function install_dependencies {
    sudo apt-get update
    sudo apt-get install python3.9 screen <<< 'y'
}

function add_strategy_to_repo {
    strategy_repo="${git_repo}/strategies.git"
    git -c $freqtrade_strategy_dir config pull.rebase false  #turns off some confirmation warning
    git -C $freqtrade_strategy_dir add -A
    git -C $freqtrade_strategy_dir commit -m "Added ${strategy_name}"
    git -C $freqtrade_strategy_dir pull $strategy_repo master 
    git -C $freqtrade_strategy_dir push $strategy_repo master
}

function get_tickers {
    # Get the ticker values that freqtrade will run using
    ticker_input=""
    while [[ $ticker_input -ne "1" ]] && [[ $ticker_input -ne "2" ]]; do
        echo "
            Which tickers? 
            1: default
            2: 1m 15m 1h 
            3: 5m 30m 4h
        "
        read ticker_input
    done
        
    if [[ ticker_input -eq 2 ]]; then
        tickers="1m 15m 1h"
    elif [[ ticker_input -eq 3 ]]; then
        tickers="5m 30m 4h"
    fi
}

function freqtrade_setup {
    #Download, and setup freqtrade
    git clone https://github.com/freqtrade/freqtrade
    mv freqtrade $cwd
    cd $freqtrade_dir
    sh ${freqtrade_dir}/setup.sh -i <<< 'n n n n'
    rm -rf ${freqtrade_strategy_dir}
    mv ${initial_strategy_dir} ${freqtrade_strategy_dir}
    mv ${initial_results_dir} ${freqtrade_results_dir}
    $python -m pip install sklearn ta
    git -c $freqtrade_results_dir config pull.rebase false
}

function run_freqtrade {
    config_file="${user_data}/config.json"
    sqlite_file="sqlite:///${freqtrade_results_dir}/${strategy_name}.dryrun.sqlite"
    screen -d -m -s $strategy_name $python ${freqtrade_script} trade -s $strategy_name --db-url $sqlite_file -c $config_file
}

function get_minute {
    strategy_name=$1
    test_run=$2
    if [ $test_run = true ]; then
        echo $(echo $(date "+%M")+1 | bc -l)
    else
        echo $(awk -v strategy=$strategy_name -F ',' '$3==strategy {print $4}' ${aws_bots_csv})
    fi
}

function get_hour {
    strategy_name=$1
    test_run=$2
    if [ $test_run = true ]; then
        date "+%H" | sed 's/^0//g'
    else
        echo 5
    fi
}

function create_cronfile {
    strategy_name=$1
    test_run=$2
    minute=$(get_minute $strategy_name $test_run)
    hour=$(get_hour $strategy_name $test_run)
    git_results_repo="${git_repo}/dry_run_results.git"
    #Create a cronfile which will push to github at the same time every day
    (crontab -l 2>/dev/null; echo "
        $(echo $minute + 0 | bc -l) $hour * * * git -C $freqtrade_results_dir add -A
        $(echo $minute + 1 | bc -l) $hour * * * git -C $freqtrade_results_dir commit -m 'Daily update ${strategy_name}'
        $(echo $minute + 2 | bc -l) $hour * * * git -C $freqtrade_results_dir pull $git_results_repo master
        $(echo $minute + 3 | bc -l) $hour * * * git -C $freqtrade_results_dir push $git_results_repo master
    ") | crontab -
}

function help {
    echo "usage:"
    echo "	-s,--strategy    Install freqtrade from scratch"
    echo "	-t,--test        Test run."
}

function main {
    #install dependencies
    install_dependencies
    add_strategy_to_repo
    freqtrade_setup
    create_cronfile $strategy_name $test_run
    run_freqtrade
}

#Get strategy name
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -s|--strategy)
      strategy_name="$2"
      shift # past argument
      shift # past value
      ;;
    -t|--test)
      test_run=true
      shift # past argument
      shift # past value
      ;;
    *)    # unknown option
    help
    ;;
  esac
done

# main
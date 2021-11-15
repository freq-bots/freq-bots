source setup_2.sh

echo "results_key"
results_key
echo "get_minute test_strategy test_run=true"
get_minute "test_strategy" true
echo "get_minute test_strategy test_run=false"
get_minute "test_strategy" false
echo "get_hour test_strategy test_run=true"
get_hour "test_strategy" true
echo "get_hour test_strategy test_run=false"
get_hour "test_strategy" false
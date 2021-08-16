begin="ghp"
mid="RJcCM31TberK1BmPZq"
end="HGLKDAF6sVHc3mAgit"
token="${begin}_${mid}${end}"

rm -rf dry_run_results
git clone https://${token}@github.com/freq-bots-results/dry_run_results
rm -rf strategies
git clone https://${token}@github.com/freq-bots-results/strategies
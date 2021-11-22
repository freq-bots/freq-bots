begin="ghp"
mid="3PQpKb3Vay06C6Cjoy"
end="RrS3YWxLS5TN0OGMjU"
results_key="${begin}_${mid}${end}"

if [ -d "./dry_run_results" ]; then
    echo "Directory ./dry_run_results exist"
elif [ -d "./strategies" ]; then
    echo "Directory ./strategies does not exist"
else
    git clone https://${results_key}@github.com/freq-bots-results/dry_run_results
    git clone https://${results_key}@github.com/freq-bots-results/strategies
fi
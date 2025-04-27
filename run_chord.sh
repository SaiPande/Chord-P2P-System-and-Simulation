#!/bin/bash

# Compile the Pony program once
ponyc .

# Create a CSV file with headers
echo "Nodes,AverageJumps" > chord_results.csv

# Loop from 5 to 100000 with intervals of 500
for num_nodes in $(seq 5 500 100000); do
    echo "Running Chord with $num_nodes nodes and 5 messages..."
    output=$(./project3 $num_nodes 5)
    
    # Extract average jumps from the output
    avg_jumps=$(echo "$output" | grep "Average jumps for all lookups:" | awk '{print $NF}')
    
    if [ -n "$avg_jumps" ]; then
        echo "$num_nodes,$avg_jumps" >> chord_results.csv
        echo "Success: Results for $num_nodes nodes added to chord_results.csv"
    else
        echo "Failed: No average jumps found for $num_nodes nodes"
    fi
done

echo "All simulations completed. Plotting the results..."

# Run the Python script to plot the results
python plot_results.py
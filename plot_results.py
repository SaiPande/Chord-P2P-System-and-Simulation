import matplotlib.pyplot as plt
import pandas as pd

# Read the CSV file
df = pd.read_csv('chord_results.csv')

# Create the plot
plt.figure(figsize=(12, 6))
plt.plot(df['Nodes'], df['AverageJumps'], marker='o')
plt.title('Average Jumps vs Number of Nodes in Chord Network')
plt.xlabel('Number of Nodes')
plt.ylabel('Average Jumps')
plt.grid(True)

# Save the plot
plt.savefig('chord_performance.png')
print("Plot saved as chord_performance.png")

# Calculate and print some statistics
print("\nStatistics:")
print(f"Total number of data points: {len(df)}")
print(f"Minimum average jumps: {df['AverageJumps'].min():.2f} (Nodes: {df.loc[df['AverageJumps'].idxmin(), 'Nodes']})")
print(f"Maximum average jumps: {df['AverageJumps'].max():.2f} (Nodes: {df.loc[df['AverageJumps'].idxmax(), 'Nodes']})")
print(f"Overall average jumps: {df['AverageJumps'].mean():.2f}")
import pandas as pd
import matplotlib.pyplot as plt
import sys

if len(sys.argv) != 2:
    print("Usage: python py.py <input_file>")
    sys.exit(1)

file_path = sys.argv[1]
data = pd.read_csv(file_path, sep='\t')

B_series = data[data['Position'].str.startswith('B')]
A_series = data[data['Position'].str.startswith('A')]
bin_series = data[data['Position'].str.startswith('bin')]

data_sorted = pd.concat([B_series, bin_series, A_series])

x_sorted = data_sorted['Position']
y_Q1_sorted = data_sorted['Q1']
y_median_sorted = data_sorted['Median']
y_Q3_sorted = data_sorted['Q3']

colors_final = ['green' if 'B' in pos or 'A' in pos else 'orange' for pos in x_sorted]

plt.figure(figsize=(16, 6))

plt.scatter(x_sorted, y_Q1_sorted, color=colors_final, label='Q1', alpha=0.6, marker='o', s=20)
plt.scatter(x_sorted, y_median_sorted, color=colors_final, label='Median', alpha=0.6, marker='x', s=20)
plt.scatter(x_sorted, y_Q3_sorted, color=colors_final, label='Q3', alpha=0.6, marker='s', s=20)

plt.xlabel('Position')
plt.ylabel('IPD ratio')  
plt.xticks(rotation=90)  
plt.legend()

plt.gca().set_facecolor('white') 
plt.grid(False)  

plt.tight_layout()

output_pdf = file_path.replace('.txt', '_plot.pdf')
plt.savefig(output_pdf)

print(f"Plot saved as {output_pdf}")

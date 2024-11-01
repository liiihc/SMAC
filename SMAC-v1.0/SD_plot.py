import pandas as pd
import matplotlib.pyplot as plt
import sys

if len(sys.argv) != 2:
    print("Usage: python py.py <input_file>")
    sys.exit(1)

file_path = sys.argv[1]
data_new = pd.read_csv(file_path, sep='\t', header=None)

W_strand = data_new[1]
C_strand = data_new[2]

plt.figure(figsize=(8, 8)) 
plt.scatter(W_strand, C_strand, color='lightblue', alpha=0.1, s=0.1) 

plt.xlabel('W strand IPD ratio SD')
plt.ylabel('C strand IPD ratio SD')

plt.xlim(0, 1)
plt.ylim(0, 1)

plt.gca().set_facecolor('white') 
plt.grid(False) 

plt.gca().set_aspect('equal', adjustable='box')

output_png = file_path.replace('.txt', '_scatter_plot.png')
plt.tight_layout()
plt.savefig(output_png)

print(f"Plot saved as {output_png}")

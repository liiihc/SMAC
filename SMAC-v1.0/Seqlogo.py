import argparse
import pandas as pd
import logomaker
import matplotlib.pyplot as plt
import sys

def main():
    parser = argparse.ArgumentParser(description='Plot a sequence logo from nucleotide frequency data.')
    parser.add_argument('input_file', help='Input file containing nucleotide frequencies.')
    parser.add_argument('-o', '--output', help='Output file to save the plot (e.g., sequence_logo.png).')
    args = parser.parse_args()
    input_file = args.input_file
    output_file = args.output
    try:
        df = pd.read_csv(input_file, sep='\t')
    except Exception as e:
        print(f"Error reading the input file: {e}")
        sys.exit(1)
    if 'Position' not in df.columns:
        print("Error: 'Position' column is missing in the input file.")
        sys.exit(1)
    try:
        df.set_index('Position', inplace=True)
    except KeyError:
        print("Error: 'Position' column not found.")
        sys.exit(1)
    df = df.transpose()
    try:
        df.index = pd.to_numeric(df.index)
    except ValueError:
        print("Error: 'Position' index contains non-numeric values.")
        sys.exit(1)
    min_pos = df.index.min()
    if min_pos < 0:
        df.index = df.index + abs(min_pos)
    row_sums = df.sum(axis=1)
    if (row_sums == 0).any():
        print("Error: Some rows have a sum of zero, cannot normalize.")
        sys.exit(1)
    df = df.div(row_sums, axis=0)
    try:
        logo = logomaker.Logo(df)
    except Exception as e:
        print(f"Error creating the logo: {e}")
        sys.exit(1)
    logo.style_spines(visible=False)
    logo.style_spines(spines=['left', 'bottom'], visible=True)
    logo.ax.set_ylabel('Frequency')
    logo.ax.set_xlabel('Position')
    logo.ax.set_xticks(range(len(df)))
    original_positions = df.index - abs(min_pos) if min_pos < 0 else df.index
    logo.ax.set_xticklabels(original_positions)
    if output_file:
        try:
            plt.tight_layout()
            plt.savefig(output_file, dpi=300)
            print(f"Sequence logo saved as {output_file}")
        except Exception as e:
            print(f"Error saving the plot: {e}")
            sys.exit(1)
    else:
        plt.show()

if __name__ == "__main__":
    main()

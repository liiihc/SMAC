![微信图片_20250214093902](https://github.com/user-attachments/assets/3308567f-2b71-4432-a7d9-c053d27ce9c1)
# SMAC: Single-Molecule 6mA Analysis Pipeline

SMAC (Single Molecule 6mA analysis of CCS reads) is a comprehensive tool designed for the identification and analysis of DNA N6-methyladenine (6mA) at single-molecule resolution using SMRT Circular Consensus Sequencing (CCS) data. This pipeline includes a series of Perl scripts for data computation and Python scripts for data visualization, which are interconnected by six shell scripts named Step1-6.sh. Each script serves a specific purpose in the pipeline, guiding users from raw data processing to comprehensive analysis of 6mA methylation.

## Getting Started

### Prerequisites

Before using SMAC, follow these preparation steps:

1. Make sure to make the shell scripts executable and add them to your environment's PATH:
   ```sh
   chmod u+x Step*.sh
   ```
   
2. Ensure the required software and modules are installed:

#### Python Modules
- lmfit: (`pip install lmfit`)
- scipy: (`pip install scipy`)
- statsmodels: (`pip install statsmodels`)
- pandas: (`pip install pandas`)
- matplotlib: (`pip install matplotlib`)
- numpy: (`pip install numpy`)
- logomaker: (`pip install logomaker`)

#### Perl Modules
- Statistics::Descriptive: (`cpan install Statistics::Descriptive`)

## Step-by-Step Instructions

### Step 1: Initial Data Processing and Quality Control

```sh
Step1.sh -input <input_bam> -name <project_prefix> -ref <reference_fasta> [-cpu <cpu>] [-passes <passes>] [-fragmentsize <size>] [-identity <identity>] [-coverage <coverage>] [-cut <cut>] [-binnumber <bin_number>]
```

- The user can set the project name using the `-name` parameter, specify the input subreads BAM file using the `-input` parameter, and provide the reference genome in FASTA format with the `-ref` parameter. 
- The script first sorts the raw data and generates consensus sequences. It then performs quality control on sequencing quality and insert fragment length, and the quality control results are saved in the `zmw_metrics.json_QC` file.
- To remove potential contaminants, the consensus sequences are aligned to the reference genome using `blastn`. For each file, users can set the alignment identity and coverage cut-off values, representing the percentage of bases aligned to the matched region and the percentage of the matched region over the total read length, respectively.
- The ZMW IDs of single molecules that pass the filtering are saved in `Full_length_ccs.txt`, while the ZMW IDs of those that do not pass are saved in `Low_quality_reads.txt`.
- The consensus sequences and original data are then split into several files. At this step, users can set thresholds for the minimum number of passes and the minimum insert fragment length, and files that meet these thresholds will be retained. 
- The script will perform alignment and IPD ratio calculations. It integrates the IPD ratio values for all adenines and normalizes all reads to the same length, evaluating the fluctuations in IPD ratio across different read positions, which reflects the impact of adapters on sequencing during the sequencing process.
- Users can set the number of bases at both ends of the reads to be displayed in detail using the `-cut` parameter and set the number of bins for the central part of the reads using the `-binnumber` parameter. 
- The results are saved in the `IPDr_Statistics_plot.pdf` file.

### Step 2: Bases near adapter Trimming and IPD Ratio Analysis

```sh
Step2.sh -name <project_prefix> [-cpu <cpu>] [-trimmer <trimmer>]
```

- The project name should be consistent with the name used in the previous step. Users can set how many bases should be trimmed from both ends of the reads based on the influence of adapters calculated in the previous step using the `-trimmer` parameter.
- Once the trimming is completed, all adenines are realigned to the genome, and the IPD ratio values that successfully align are used for following steps. After performing a log2 transformation, the bimodal distribution of the data is analyzed. A Gaussian distribution is specifically fitted to the right peak (using data with log2(IPDr) ≥ 1.6 by default) to determine the recommended cut-off value and calculate false positive/negative rates. Notably, the threshold of log2(IPDr) ≥ 1.6 was empirically optimized from our multiple samples to ensure the fitted Gaussian curve aligns well with the actual distribution of the right peak. Users can adjust this threshold by modifying the 6mA_axdistribution_rightpeak.py script if needed.
- The results are stored in the `A_IPDr_distribution/A` directory.

### Step 3: Obtaining IPD Ratio Cut-off for 6mA Detection

```sh
Step3.sh -name <project_prefix> -ipd_cutoff <value> [-cpu <cpu>]
```

- Users can input the cut-off value used to determine 6mA using the `-ipd_cutoff` parameter. This value can come from the results of Step2.sh or be manually specified.
- Since the cut-off from Step2 is obtained based on the log2-transformed IPD ratio distribution, the cut-off in subsequent use will be treated as a power of 2 (for example, if 1.5 is input, the actual cut-off will be 2 to the power of 1.5).
- Based on this cut-off, the standard deviation (SD) of all non-6mA adenine IPD ratios can be calculated, and a scatter plot of SD values for the Watson and Crick strands is generated and saved as `SD_scatter_plot.png`.

### Step 4: Background Noise Filtering and 6mA Identification

```sh
Step4.sh -name <project_prefix> -ref <reference_fasta> -sd_cutoff [value] -ipd_cutoff <value> [-cpu <cpu>]
```

- Users manually set a threshold based on the SD value distribution and input it using the `-sd_cutoff` parameter to filter out single molecules with high background noise.
- After filtering, the input IPD ratio cut-off is used to determine 6mA, and the percentage of 6mA/A in the sample is provided.
- The identification results at the single-molecule level are stored in `back2genome.txt_6mAorA`. At the composite level, the penetrance of each adenine base is saved in `penetrance.xls`. A `.bw` format file is also provided, which can be imported into genome browsers (e.g., IGV) for viewing.
- In addition, motifs 5bp upstream and downstream of 6mA are given. The motif image is saved as `6mA_motif.pdf`, and the probability matrix is stored in `6mAorA_motif`.

### Step 5: Obtaining the Second Round of IPD Ratio Cut-off for 6mApT-Enriched Samples

```sh
Step5.sh -name <project_prefix> -ipd_cutoff <value> [-cpu <cpu>]
```

- For all ApT dinucleotides, the IPD ratio of adenine on the opposing strand is calculated when the IPD ratio of adenine on one strand exceeds the cut-off.
- A bimodal distribution is also fitted, and shifted cut-off values for the Watson and Crick strands are provided separately.
- Note that by default, `6mA_axdistribution_leftpeak.py` is called for the calculation. If the ApT peak is found to be not lower than the 6mApT peak after fitting, try using `6mA_axdistribution_rightpeak.py` for recalculation.

### Step 6: Re-Evaluation with Updated Cut-offs

```sh
Step6.sh -name <project_prefix> -all_cutoff <value> -W_cutoff <value> -C_cutoff <value> -ref <genome.fasta>
```

- The cut-off values for all adenines, Watson strand, and Crick strand are entered separately, and the script re-identifies 6mA based on the sequence context of each adenine and the methylation status of the opposing strand.
- The single-molecule level identification results are stored in the `shifted_cutoff` folder, and detailed output information is saved in `6mAratio.xls`.
- At the composite level, the penetrance information for all ApT sites is saved in `6mApTorApT_penetrance`, and the corresponding `.bw` file is also provided.

### Visualizing 6mA Sites Using genome browsers
To visualize 6mA sites in genome browsers, the following steps utilize the `6mAviewer.pl` script and samtools to generate a BAM file:
```sh
perl 6mAviewer.pl ${name}.sorted.hifi.mapped.sam [${name}_back2genome.txt_6mAorA| ${name}_back2genome.txt_6mApTorApT] reference_genome.fasta ${name}_single_molecules.sam 
samtools view -bS ${name}_single_molecules.sam -o ${name}_single_molecules.bam
samtools sort -@ $CPU ${name}_single_molecules.bam -o ${name}_single_molecules_sorted.bam
samtools index ${name}_single_molecules_sorted.bam
```
Once these steps are completed, the resulting indexed BAM file (${name}_single_molecules_sorted.bam) can be loaded into genome browsers (e.g., IGV, https://igv.org) to visualize 6mA modifications at the single-molecule and single-base resolution.


![6mA viewer](https://github.com/user-attachments/assets/dafe8b67-26de-4c72-9350-5553daed07e9)
##### Penetrance, coverage and identified 6mA sites calculated by SMAC, showcased in a representative genomic region from the native DNA sample in the IGV. In the single-molecule section, the gray bands represent the positions of single molecules, while 6mA on the Watson and Crick strands are marked in yellow and blue, respectively.


## Citation
If you use SMAC in your research, please cite:
> Li et al., SMAC: Identifying DNA N6-methyladenine (6mA) at the single-molecule level using SMRT Circular Consensus Sequencing (CCS) data

## Contact
For questions, please contact Haicheng at [liiihc0924@gmail.com].


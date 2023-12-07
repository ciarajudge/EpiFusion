#!/bin/bash
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ciara.judge@lshtm.ac.uk # Where to send mail
#SBATCH --ntasks=2                    # Run on a single core
#SBATCH --cpus-per-task=8
#SBATCH --mem=1gb                     # Job memory request
#SBATCH --time=150:00:00               # Time limit hrs:min:sec
#SBATCH --output=serial_%j.log   # Standard output and error log

pwd; hostname; date

module load java/8.0_371

java -jar EpiFusion_improved.jar AAAGK.xml

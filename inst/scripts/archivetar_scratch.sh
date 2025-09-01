#!/bin/bash

# Instructions for using this script
# 1. Download this script to your home directory and make it executable:
#    chmod +x archivetar_scratch.sh
# 2. Ensure that the folder you want to archive is placed in /nfs/turbo/seas-zhukai/archives/
# 3. Submit this script as a Slurm job with the following command:
#    sbatch --export=TARGET_FOLDER='<target folder>',UNIQUE_NAME='<unique name>' --job-name='<job name>' archivetar_scratch.sh
# 4. Upon job completion, copy the tar files from scratch to the Data Den using Globus.
# 5. Once the transfer to the Data Den is complete, you may delete related files from Turbo and Scratch.

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=24:00:00
#SBATCH --account=zhukai0
#SBATCH --partition=standard
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=youremail@domain.com  # Add your email here

# Input validation
if [[ -z "${TARGET_FOLDER}" || -z "${UNIQUE_NAME}" ]]; then
  echo "Error: TARGET_FOLDER and UNIQUE_NAME environment variables are required."
  exit 1
fi

# Navigate to the target directory
cd /nfs/turbo/seas-zhukai/archives/${TARGET_FOLDER} || { echo "Error: Target folder not found."; exit 1; }

# Load necessary module
module load archivetar || { echo "Error: Failed to load archivetar module."; exit 1; }

# Perform archiving
archivetar --prefix ${TARGET_FOLDER} --zstd --bundle-path /scratch/zhukai_root/zhukai0/${UNIQUE_NAME} --size 100G || { echo "Error: Archiving failed."; exit 1; }

echo "Archiving completed successfully."

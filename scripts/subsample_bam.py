#!/usr/bin/env python3
"""
Script to use samtools to downsample a BAM file.

This script takes a BAM file and downsamples it to a specified target size in megabytes.
The downsampled BAM file will be saved in the specified target directory, with a name
indicating the original file name and the downsampled size.

If the target directory is not specified, the output will be saved in the directory
where the script is run.

A subsample seed is used to influence which subset of reads is kept. The seed is
randomly generated unless specified by the user. If subsampling data that has
previously been subsampled, be sure to use a different seed value from those used
previously to avoid retaining more reads than expected.

Example usage:
    python3 script.py --bam_file path/to/file.bam --target_mb 30 --target_dir /path/to/output/ --subsample_seed 42
"""

# ---   Load Packages   --- #
# ------------------------- #

import argparse
import os
import logging
import sh
import sys
import random

# ---   Load Inputs   --- #
# ----------------------- #


def load_inputs():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bam_file", type=str, required=True, help="Path to BAM file")
    parser.add_argument(
        "--target_mb",
        type=int,
        required=True,
        help="Target size of the output BAM file in megabytes",
    )
    parser.add_argument(
        "--target_dir",
        type=str,
        required=False,
        help="Target directory to write downsampled BAM file to",
    )
    parser.add_argument(
        "--output_name",
        type=str,
        required=False,
        help="Custom name for the output BAM file",
    )
    parser.add_argument(
        "--subsample_seed",
        type=int,
        required=False,
        help="Subsampling seed used to influence which subset of reads is kept",
    )

    args = parser.parse_args()

    if not os.path.exists(args.bam_file):
        raise FileNotFoundError(f"Input BAM file not found: {args.bam_file}")

    # Set target_dir to the directory where the script is run if not provided
    if args.target_dir is None:
        args.target_dir = os.getcwd()

    # Generate a random seed if not provided
    if args.subsample_seed is None:
        args.subsample_seed = random.randint(1, 1000000)

    return args


# ---   Main   --- #
# ---------------- #


def main():
    try:
        args = load_inputs()

        # Calculate fraction and confirm with the user if it's at the minimum
        fraction, actual_target_mb = calculate_fraction(args.bam_file, args.target_mb)

        if fraction == 0.01:
            print(
                f"Warning: The minimum allowed fraction is 0.01, which corresponds to {actual_target_mb} MB."
            )
            proceed = input(
                "Do you want to proceed with this minimum allowed fraction? (yes/no): "
            )
            if proceed.lower() != "yes":
                print("Operation aborted by the user.")
                return 1

        # Generate the target BAM file name
        target_bam = generate_target_bam_name(
            args.bam_file, actual_target_mb, args.target_dir, args.output_name
        )
        logging.info(f"Target BAM file path: {target_bam}")

        # Check if the target file already exists and confirm overwrite
        if os.path.exists(target_bam):
            overwrite = input(f"{target_bam} already exists. Overwrite? (yes/no): ")
            if overwrite.lower() != "yes":
                print("Operation aborted by the user.")
                return 1

        # Perform the downsampling
        downsample_bam(args.bam_file, fraction, target_bam, args.subsample_seed)
        return 0
    except Exception as e:
        logging.error(f"An error occurred: {str(e)}")
        return 1


# ---   Functions   --- #
# --------------------- #


def calculate_fraction(original_bam, target_mb):
    logging.info(f"Calculating fraction for {original_bam} targeting {target_mb} MB.")
    # Get the original BAM file size in MB using sh package
    original_size_mb = int(sh.du("-m", original_bam).split()[0])
    logging.info(f"Original BAM file size: {original_size_mb} MB.")

    # Calculate the fraction to subsample
    fraction = round(target_mb / original_size_mb, 2)
    logging.info(f"Calculated fraction: {fraction}")

    # Ensure the fraction is not lower than 0.01
    if fraction < 0.01:
        fraction = 0.01
        logging.warning(f"Fraction adjusted to minimum allowed value: {fraction}")
    actual_target_mb = round(original_size_mb * fraction, 2)

    return fraction, actual_target_mb


def generate_target_bam_name(original_bam, target_mb, target_dir, custom_name=None):
    if custom_name:
        # Use the custom name, but ensure it has a .bam extension
        base_name = os.path.splitext(custom_name)[0]
        target_bam = os.path.join(target_dir, f"{base_name}.bam")
    else:
        # Use the original naming scheme
        bam_filename = os.path.basename(original_bam)
        base_filename = os.path.splitext(bam_filename)[0]
        target_bam = os.path.join(
            target_dir, f"{base_filename}_ds{int(target_mb)}mb.bam"
        )

    logging.info(f"Generated target BAM name: {target_bam}")
    return target_bam


def downsample_bam(original_bam, fraction, target_bam, subsample_seed):
    logging.info(
        f"Starting downsampling with fraction {fraction} and seed {subsample_seed}."
    )

    # Run the samtools command to subsample using sh package
    with open(target_bam, "wb") as f:
        try:
            sh.samtools.view(
                "-bs",
                str(fraction),
                "--subsample-seed",
                str(subsample_seed),
                original_bam,
                _out=f,
            )
            logging.info(f"Subsampling complete: {target_bam} created.")
        except Exception as e:
            logging.error(f"Error during downsampling: {str(e)}")
            raise


# ---   Main Guard   --- #
# ---------------------- #

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    sys.exit(main())

#!/usr/bin/env python3
import os
import sys
import re

def list_files(directory):
    file_list = []
    
    for filename in os.listdir(directory):
        if os.path.isfile(os.path.join(directory, filename)):
            file_list.append(filename)
    
    return file_list

def concat(directory_paths, rnaseq_id): 
    R1 = []
    R2 = []

    for directory_path in directory_paths:
        files_in_directory = list_files(directory_path)
        for filename in files_in_directory:
            tmp = filename.replace("-", "_")
            if re.search(r"_R1.*?\.gz$", tmp,  re.IGNORECASE):
                R1.append(os.path.join(directory_path,filename))
            elif re.search(r"_R2.*?\.gz$", tmp, re.IGNORECASE):
                R2.append(os.path.join(directory_path,filename))

    R1.sort()
    R2.sort()
    print(R1)
    print(R2)

    assert len(R1) > 0, "Please check FASTQ filename format"
    assert len(R2) > 0, "Please check FASTQ filename format"

    command = f"cat {' '.join(R1)} > {rnaseq_id}_all_R1.fastq.gz && cat  {' '.join(R2)} > {rnaseq_id}_all_R2.fastq.gz;"
    return command

cmd = concat(sys.argv[1].split(","), sys.argv[2])

# Shell script to execute
shell_script = f"""
#!/bin/bash

{cmd}
"""

file_path = "run_concat.sh"

with open(file_path, "w") as file:
    file.write(shell_script)

#!/usr/bin/env bash
# Check for parameters, return usage if empty
if [ $# -ne 1 ];
then
    printf "\n usage: add_biorepo_dirs <REPOSITORY PATH>
    \n Creates common repository directories for a biopipe as needed
    \n "
else
    repo_dirs=("config"
               "resources"
               "test/inputs"
               "tools/shell"
               "workflow/scripts")

for dir in "${repo_dirs[@]}";
do
   mkdir -p $1/$dir
done
fi

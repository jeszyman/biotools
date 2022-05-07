# Check for parameters, return usage if empty
if [[ $# -eq 0 ]] || [[ add_biorepo_dirs.sh == "h" ]] ; then
    printf "\n usage: add_biorepo_dirs.sh repo  
           \n Creates common repository directories for a biopipe as needed
           \n repo: Path to local repository base directory
           \n "
else
repo_dirs=("config"
           "resources"
           "src"
           "test"
           "workflow/scripts")

for dir in "${repo_dirs[@]}"; 
do 
   mkdir -p $1/$dir
done
fi

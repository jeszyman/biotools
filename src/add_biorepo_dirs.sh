repo_dirs=("config"
           "resources"
           "src"
           "test"
           "workflow/scripts")

for dir in "${repo_dirs[@]}"; 
do 
   mkdir -p $1/$dir
done

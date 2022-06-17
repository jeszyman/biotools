#!/bin/bash
# Get variables
project="USER INPUT"
repos_dir="USER INPUT"
read -p "Project name: " project
read -p "Repositories main directory: " repos_dir
repos_dir="${repos_dir:=home/jeszyman/repos}"
project_dir=$(echo "$project" | sed 's/_/-/')

echo Project is $project
echo Project directory is $project_dir
echo Repo will be cloned to $repos_dir

# Clone
cd "${repos_dir}"

git clone git@github.com:jeszyman/biocollab "${project_dir}" && echo "cloned"


echo "project=$project" >> "${project_dir}/config/main"
echo "project_dir=$project_dir" >> "${project_dir}/config/main"
#ln -s ${repos_dir}/basecamp "${repos_dir}/${project_dir}"/
# Add symlinks
#wait
#ln -s ${repos_dir}/basecamp "${repos_dir}/${project_dir}"/
#ln -s "${repos_dir}/biotools" "${repos_dir}/${project_dir}/"
#ln -s "${repos_dir}/latex" "${repos_dir}/${project_dir}/"

#mv "${repos_dir}/${project_dir}/biocollab.org" "${repos_dir}/${project_dir}/${project_id}.org"

#ln -s "${repos_dir}/${project_dir}/${project_id}.org" "${repos_dir}/org/"

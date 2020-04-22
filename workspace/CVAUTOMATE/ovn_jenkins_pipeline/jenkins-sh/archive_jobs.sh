function check_archive_folder()
{
  jenkins_home="/var/lib/jenkins"
  # If archives folder doesn't exist create the folder and add the config file.
  if [ ! -d $jenkins_home"/jobs/archives" ]; then
    mkdir $jenkins_home"/jobs/archives"
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cp $DIR"/jenkins_folder_config.xml" $jenkins_home"/jobs/archives"
    mv $jenkins_home"/jobs/archives/jenkins_folder_config.xml" $jenkins_home"/jobs/archives/config.xml"
  fi
  if [ ! -d $jenkins_home"/jobs/archives/jobs" ]; then
    mkdir $jenkins_home"/jobs/archives/jobs"
  fi
}

function archive_jobs()
{
  jenkins_home="/var/lib/jenkins"
  check_archive_folder
  if [[ -f /tmp/jobs_to_archive.txt ]]; then
    rm /tmp/jobs_to_archive.txt
  fi
  find  $jenkins_home"/jobs" -type d -maxdepth 1 -print0 >> /tmp/jobs_to_archive.txt
  while IFS= read -r -d '' jname; do
    if [[ -f "$jname/config.xml" ]]; then  # This checks if this is either a jenkins job or folder.
      if [[ $(basename "$jname") != 'archives' ]]; then  # Don't move the archives folder into itself. (Crazy!!).

        # <scriptPath> exists in config if job is created from jenkinsfile
        if grep "</flow-definition>" "$jname/config.xml" > /dev/null
        then
          echo "This job has a pipeline script"
        else
          echo "Moving this job "$jname
          mv "$jname" $jenkins_home"/jobs/archives/jobs"
        fi
      fi
    fi
  done < /tmp/jobs_to_archive.txt

}

function unarchive_jobs()
{
  jenkins_home="/var/lib/jenkins"
  check_archive_folder
  if [[ -f /tmp/jobs_to_unarchive.txt ]]; then
    rm /tmp/jobs_to_unarchive.txt
  fi
  find  $jenkins_home"/jobs/archives/jobs" -type d -maxdepth 1 -print0 >> /tmp/jobs_to_unarchive.txt
  while IFS= read -r -d '' jname; do
    if [[ -f "$jname/config.xml" ]]; then  # This checks if this is either a jenkins job or folder.
      if [[ $(basename "$jname") != 'archives' ]]; then  # Don't move the archives folder into itself. (Crazy!!).

        # <scriptPath> exists in config if job is created from jenkinsfile
        if grep "</flow-definition>" "$jname/config.xml" > /dev/null
        then
          echo "This job has a pipeline script"
        else
          echo "Moving this job "$jname
          mv "$jname" $jenkins_home"/jobs"
        fi
      fi
    fi
  done < /tmp/jobs_to_unarchive.txt
}

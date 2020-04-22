Clearing Job

Role deploys the clearing job and will be a polling task at 30 min interval on to Nomad server to get delivery data. 
The task currently polls for availability of data from Bridge EA.
The hcl job/task schedules it self on Nomad as directed in its hcl content.


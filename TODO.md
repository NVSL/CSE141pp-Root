# TODO


## Requirements For Class

* rate limit student submissions (only one non-completed job at a time)
  * need cancelation support
* make benchmarks work
* make gradescope work
* get moneta working
* Add auto dependence tracking to make file.
* test job timeouts
* reconsider how we implement solution checking.
* make --limit show the most recent jobs instead of the oldest
4. Figure out what to do with the secrets
4. Fix app secret in REST/app.py
3. Setup simpler cli for students.
   * alias for `cse142 job run`
* silly names for jobs https://github.com/and3rson/codename/blob/master/codename/codename.py
* ability to easily re-run a job.
* Add CRCs to manifest
* filter out moneta trace files
* Tool to monitor runners

##

* maybe add email/username to Job 
* make 'LAST' return the last job for the current user
* make jobs cancelable while running.
* Cancelation probably doesn't for non-admin accounts.
   * make it a job store operation and make sure it's atomic
   * Provide test-and-set primitive on http UPDATE so we can do an atomic state transition.

* create /tmp/djr_scratch if it doesn't exist
* efficient large file upload


5. Update config/cloud/bootstrap_server.sh

3. Get rid of the `REST` directory.
4. Give `--no-http` some sensible meaning.  It currently means different things for different cli tools.
* make it easy to hide some objects.
* DJRDirectClient is never in "testing" mode

* cse142 lab update --set foo  gives unhandled exception

* Need to move field update permissions into Job subclasses.  Had to have a DockerJob field to the JobAPI.
* Redesign BaseObject so we declare fields allowing us to set type, default, and marshalling functions.  maybe uniqueness constraints too.

* compute_create_args should probably be a method of the LocalObjecStore
  instead of the API.  Otherwise, compute_create_args never get's called unless
  you are going through the REST api.
* There should probably be a singleton ObjectStore for each type and global registry so you can access them from anywhere.  I went through some messiness to get access LabSpec inside CSE142L.x

# Done

5. Maybe bring over environment variables
* format dates in job listing and labspec listing
* Command to watch running job
* command to write out results of running job
2. More intelligent file upload
2. Developer/TA documentation.
* Why does'nt uploading executables work?
* Fix permissions on zipped files
* use columnify
* collect stderr
1. Google login.
3. Merge deploy directory into config directory
3. Implement 'djr user *' functionality to create/delete/etc. users

# Benchmark Algorithm

git clone starter_repo
make -m starter_repo/Makefile command


git clone starter_repo
spec= starter_repo/lab.json
cp spec['input_files'] -> starter_repo
cd starter_repo
run spec['commands'][command]
cp spec['output_files'] ../



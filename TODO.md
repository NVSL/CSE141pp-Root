# TODO

## Requirements For Class

* make benchmarks work
* make gradescope work
* fix autograder stuff
* add bulk useradd/update
* Move standard error mtrace into notebook
* Move rate-limiting logic onto the server side. Make it not apply to admins and "root" users.

* Fluid interface for running and collecting data about fiddles.
* merge utility function for panda dataframes

* Only display compiler etc. output on error.

* fix intermittent error with cfg generation.


* rename "login.ipynb" to "authenticate.ipynb"

* add time stamp to `cse142 job run` output.

* make get-cpu-freqs behave itself when it can't actually run.

* see about formatting the output of cse142 so it looks nice in jupyter notebook.
	* colorize cse142 job run output
  
* Insert newlin after "Updated these files: ./build/hello_world.cpp" in file output writing.
	
* move 'whereaim' and other bash functions into scripts so they will work in JupyterNotebook

* progress bar for mtrace
* Remove trailing , in libarchlab output.

* unified tagging system

* Script to strip 'outputs' from jupyter notebooks for deploying labs.

* add cron job to cleanup stalled jobs
  * to create a stalled job, start a job and then kill the runner.
  * maybe have it email me when this happens.
* ability to easily re-run a job.
* make --limit show the most recent jobs instead of the oldest
4. Fix app secret in REST/app.py
3. Setup simpler cli for students.
     * alias for `cse142 job run`
* silly names for jobs https://github.com/and3rson/codename/blob/master/codename/codename.py
* Tool to monitor runners
* Stream job output via telnet
* build error for CANELA testes during docker build
 
##

4. Figure out what to do with the secrets
* remove --json option from djrrun

* standardize output formatting
  * put errors in stderr (err=True for click.echo)
  * abstract away formatting for errors, info, warnings by color
  * standarize usage
  
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
* There should probably be a singleton ObjectStore for each type and global registry so you can access them from anywhere.  I went through some messiness to get access LabSpec inside CSE142L.

* Job state changes should be transactional.  Otherwise, we have to be very lenient about state transitions.  For instance, Exec_time_out -> total_time_out shouldn't be allowed, but if the client and the subimtter race about it, it's a problem.


# Done

* remove 'make: runlab: Command not found' from output
* cse142dev  should check for existing containers that are created but not running.
* Add function to check if we are in jupyter Notebook.
  
  * remove interactivity in jupyter notebook
	* make login work in jupyter notebook
	* kill running jobs automatically in jupyter notebook.
	* add command line option '--force' to avoid interactivity.

* get the secrets out of runner.docker!

* make archlab work
* make jobs cancelable while running.
* make 'LAST' return the last job for the current user
* maybe add email/username to Job 
* Check that stderr capture works when using docker.
* filter out moneta trace files
* Add CRCs to manifest
* Add auto dependence tracking to make file.
* get moneta working
* test job timeouts
* rate limit student submissions (only one non-completed job at a time)
* need cancelation support
* reconsider how we implement solution checking.
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

* notebook sanitizer:
	* Mark everything but the question cells as immutable.
    * strip outputs
	* Parse metadata annotations in cells and apply them.
https://nbformat.readthedocs.io/en/latest/format_description.html#top-level-structure



# Benchmark Algorithm

git clone starter_repo
make -m starter_repo/Makefile command


git clone starter_repo
spec= starter_repo/lab.json
cp spec['input_files'] -> starter_repo
cd starter_repo
run spec['commands'][command]
cp spec['output_files'] ../



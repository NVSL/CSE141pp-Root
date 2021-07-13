# TODO


*** Make the labs work

* rate limit student submissions 
* make jobs cancelable while running.
* create /tmp/djr_scratch if it doesn't exist
* large file upload
* test job timeouts
* Cancelation probably doesn't for non-admin accounts.
   * make it a job store operation and make sure it's atomic
   * Provide test-and-set primitive on http UPDATE so we can do an atomic state transition.
* make --limit show the most recent jobs
4. Figure out what to do with the secrets
4. Fix app secret in REST/app.py
5. Update config/cloud/bootstrap_server.sh
3. Setup simpler cli for students.
3. Get rid of the `REST` directory.
4. Give `--no-http` some sensible meaning.  It currently means different things for different cli tools.
5. Maybe bring over environment variables
* make it easy to hide some objects.
* DJRDirectClient is never in "testing" mode
* silly names for jobs

# Done

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

# Setting up CSE142L Development

## System Overview

The course's lab runner provide allow students to run short-running jobs on
bare-metal servers in the cloud.  The basic flow is this:

1.  Students edit their source code.
2.  They submit a command to run in the cloud.
3.  The tools zip up their local files, ship them to the cloud, run the command,  collect the results, and ship them back.

This underlying system is built on four cloud-based services:

1.  A data base (Google Cloud Datastore)
2.  A blob store (Google Cloud Storage)
3.  A publish/subscribe system (Google Cloud Pub/Sub) 
4.  A web-based REST API for manipulating the above (Running in Google App Engine).

The main interface to the system is the `cse142` command line tool.  It takes
numerous subcommands to manipulate the above resources and submit jobs.

User authenticate to the system using their UCSD Google credentials (i.e,
either their @eng or @ucsd.edu email addresses.)


## Getting into Docker

To set up your development environment initially:

First, I suggest you set up an ssh-agent to avoid typing your password over and over:

```
eval `ssh-agent`
ssh-add
```

Then 

```
git clone --recurse-submodules git@github.com:NVSL/CSE141pp-Root.git
```

This clones the root repo and several sub-repos.

```
cd CSE141pp-Root
. env.sh
make bootstrap
```

You'll need to build the docker images locally:

```
cd CSE141pp-Root
make
```

This will run for a while.  You can do then do

```
docker images
```

and see them:

```
REPOSITORY                       TAG             IMAGE ID       CREATED         SIZE
stevenjswanson/cse142l-runner    latest          e3cb52c116d7   2 hours ago     12.2GB
stevenjswanson/cse142l-runner    s21-dev         e3cb52c116d7   2 hours ago     12.2GB
stevenjswanson/cse142l-dev       latest          c90dcd27a70e   2 hours ago     7.84GB
stevenjswanson/cse142l-dev       s21-dev         c90dcd27a70e   2 hours ago     7.84GB
stevenjswanson/cse142l-service   latest          d28b327b0ada   2 hours ago     7.84GB
stevenjswanson/cse142l-service   s21-dev         d28b327b0ada   2 hours ago     7.84GB
```

Then, to get yourself into a development docker container:

```
cd CSE141pp-Root
. env.sh
cse142dev
```

This will drop you into `/cse142L` in the docker container which is mapped to
the root of your `CSE141pp-Root` directory.  You can edit your files from
outside the container using the editor of your choice and the changes will be
reflected here.

`cse142dev` automaticaly creates an `ssh-agent` to store your ssh key and invokes `ssh-add` to add it.  If `cse142dev` asks for a password, this is why.


The first time you do this, you should do

```
./setup.sh
```

To build everything from source.  It will take a little while.  After that, invoking `CSE141pp-Root/bin/cse142dev` should be all you need to get into docker and start working.

From inside the docker container you can see information about the docker container with 

```
whereami
```

## Creating Your Account

`cse142dev` drops you into docker container that has priviliged, direct access
to the resources above, so you don't have to authenticate to use it.  You will
use this capability to create an account for yourself.  From then on, you'll
authenticate and use it as a student would.

The command lines to create and edit users are similar to those you'll use to
manipulate other data (e.g., jobs and labs).

First, check if everything is working (it may take a little bit.  Direct access
is slow.):

```
cse142 --no-http user list
```

The `--no-http` bypasses authentication.  `user` means we are going to do
something to users.  `list` means list them.

This should give you list of current users.  It will at least include
`swanson@eng.ucsd.edu` and probably others.

To create your user with admin priviliges:

```
cse142 --no-http user create --email <your @ucsd.edu or @eng.ucsd.edu email> --name "<your full name>" --role "ADMIN"
```

Check to see that it worked:

```
cse142 --no-http user list
```

You should see yourself:

```
3341f94e-254d-4f58-9f5c-a825e067f9a7	sjswanson@ucsd.edu	sjswanson@ucsd.edu	['USER']
cb531cf4-2aa3-4e48-8629-3c36ffadee4c	swanson@eng.ucsd.edu	swanson@eng.ucsd.edu	['ADMIN']
```

The fields are a unique ID, email, full name, and roles (for permissions).


Now you can authenticate:

```
cse142 login <your email>
```

and follow the instructions to login via a web browser.

You should then be able to 

```
cse142 user list
```

You should see yourself again.  If you made a mistake you can edit your account like so:

```
cse142 user update sjswanson@ucsd.edu --set name="Steven Swanson"
```

You can pass either your email or the id.

To see more detail about yourself do:

```
cse142 user list -l sjswanson@ucsd.edu
```

and get something like

```
{   'created_time': datetime.datetime(2021, 7, 10, 5, 59, 55, 399152, tzinfo=tzutc()),
    'email': 'sjswanson@ucsd.edu',
    'id': '3341f94e-254d-4f58-9f5c-a825e067f9a7',
    'last_authenticated_time': datetime.datetime(2021, 7, 10, 5, 59, 55, 399208, tzinfo=tzutc()),
    'last_login_time': None,
    'mood': '',
    'name': 'Steven Swanson',
    'namespace': 'default',
    'project_id': 'cse142l-dev',
    'roles': ['USER'],
    'secret': ''}
```




## Running A Job

The job runner is supposed to approximate the experience of running command
line commands on a machine in the cloud.  Each job runs in a fresh docker
container that is nearly identical to the one you are working in but has fewer
permissions.

Each job is run in the context of a "lab" that specifies which exact docker
image to use.  You can see the list of available labs with 

```
cse142 lab list
```

You should get something like this:

```
76c847c9-c3fa-4d3b-b56e-87fcfab46edf	test	2021-07-06 10:35:00-07:00	stevenjswanson/cse142l-runner:latest	test2
```

The field  are id, short-name, due date, docker image, and full name.

To run your first job:

```
mkdir t
cd t
cse142 job run --lab test "echo hello world"
```

You'll get something like this:

```
You are submitting a job for lab test2 (test).
Creating job e4e80402-9217-4835-9e6b-56c7ef3b4977 0.00 0.00
Ready for submission. 1.27 1.27
Job e4e80402-9217-4835-9e6b-56c7ef3b4977 is in state 'PUBLISHED'. 0.56 1.83
Job e4e80402-9217-4835-9e6b-56c7ef3b4977 is in state 'PUBLISHED'. 1.08 2.90
Job e4e80402-9217-4835-9e6b-56c7ef3b4977 is in state 'RUNNING'. 1.07 3.97
Job e4e80402-9217-4835-9e6b-56c7ef3b4977 is in state 'RUNNING'. 1.06 5.03
Job e4e80402-9217-4835-9e6b-56c7ef3b4977 is in state 'DONE_RUNNING'. 1.06 6.09
Job e4e80402-9217-4835-9e6b-56c7ef3b4977 is in state 'DONE_RUNNING'. 1.14 7.24
Job e4e80402-9217-4835-9e6b-56c7ef3b4977 is in state 'DONE_RUNNING'. 1.07 8.31
Job e4e80402-9217-4835-9e6b-56c7ef3b4977 is in state 'DONE_RUNNING'. 1.06 9.36
Job e4e80402-9217-4835-9e6b-56c7ef3b4977 succeeded. 1.06 10.42
Writing results 1.00 11.42
hello world
Job Complete 0.55 11.97
```

It tracks the lifetime of the job.  The numbers at the end are the latency
since last update and total execution time.  You can see the output of your job
near the bottom.

You can list the jobs you've run with

```
cse142 job list
```

As an admin, you'll see all the jobs run on the system.  It'll be a lot.

You can list the last job you ran with 

```
cse142 job list LAST
```

or 

```
cse142 job list -l LAST
```

## Life Cycle of a Job

The steps in a jobs execution are as follows:

1. Create the job object.
2. Recursively zip up most of the files in the current directory. ("Ready for submission")
3. Upload them to the cloud.
4. Submit the job for execution (state "PUBLISHED")
5. One of the job runners pulls it (state "SCHEDULED", not shown here)
6. Runs it (state "RUNNING")
7. Zips up modified files (state "DONE_RUNNING")
8. Upload the modified files to the cloud.
9. Finish up ("succeeded")

All the while, your `cse142` command is polling the job for updates.  When it
sees it's succeeded, it downloads the zip file of updated files, and unzips it.
It also prints the `stdout`/`stderr` for the command ("hello world").

We created the `t` directory above to prevent the job for sucking in all the
source code in your directory.  It takes a long time (and might fail).

## More Complicated Jobs

Here are some things to try:

Create `main.c`:

```
#include<stdio.h>

void main() {
	printf("Hello world\n");
}
```

Then:

```
cse142 job run --lab test 'gcc main.c -o main; ./main'
```

and then

```
gcc main.c -o main
cse142 job run --lab test './main'
```

or even

```
cse142 job run --lab test 'gcc main.c -o main'
./main
```

## Dogfooding and Testing

We would like the course tools to be as user-friendly as possible.  So, please
use them for developing the labs.  IF you have feedback about how we can make
the tools more pleasant to use, please let Professor Swanson know.

In particular, `cse142` should meeting the following requirements

1.  The user should never get at python stack dump.  If you get one, it's bug
    please send me the command line and the output.
2.  You shouldn't see "Command failed due to uncaught exception" errors either.  They are a catchall to avoid stack dumps.   If you can 
2.  The error messages make sense.  If you find one misleading or confusing, let me know.
3.  The use of color should be consistent.


## Running a Lab 

To get started working on lab, let's run the final project.  It's here:

```
cd labs/CSE141pp-Lab-FinalProject/
```

You should be able to run the lab locally with 

```
make
```

It'll take a little while.  Ignore the `make: runlab: Command not found`

Then you can run it in the cloud with 

```
cse142 job run --lab test 'make clean; make```


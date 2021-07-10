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

```
git clone --recurse-submodules git@github.com:NVSL/CSE141pp-Root.git
```

This clones the root repo and several sub-repos.

```
cd CSE141pp-Root
. env.sh
make bootstrap
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

Your home directory is mounted at `/root`.

If you have your .ssh keys setup, you should be able to do:

```
git pull
```

If you want to avoid typing your password you can do:

```
eval `ssh-agent`
ssh-add
```


# Creating Your Account

`cse142dev` drops you into docker container that has priviliged, direct access
to the resources above, so you don't have to authenticate to use it.  You will
use this capability to create an account for yourself.

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

You should see yourself.

Now you can authenticate:

```
cse142 login <your email>
```

and follow the instructions to login via a web browser.



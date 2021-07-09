# Setting up CSE142L Development

To set up your development environment initially:

```
git clone --recurse-submodules https://github.com/NVSL/CSE141pp-Root.git
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
	

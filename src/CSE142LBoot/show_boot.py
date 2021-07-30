import click
import textwrap
import os
import urllib
import sys

def insert_github_token(url, token):
    if not url.startswith("https"):
        raise Exception(f"Need an https url.  Got {url}")
    parsed = urllib.parse.urlparse(url)
    return f"{parsed.scheme}://x-token-auth:{token}@{parsed.netloc}{parsed.path}"

def import_env(*vars):
    return "".join([f"export {v}={os.environ[v]}\n" for v in vars])


@click.command()
@click.option("--installer", default="apt-get", help="apt-get like tool to use for installation")
def main(installer=None):
    
    root_repo = insert_github_token(os.environ['HTTP_ROOT_REPO'], os.environ["GITHUB_OAUTH_TOKEN"])

    exports = ["HTTP_ROOT_REPO",
               "ROOT_REPO_BRANCH",
               "HTTP_ARCHLAB_REPO",
               "ARCHLAB_REPO_BRANCH"]

    sys.stdout.write(textwrap.dedent(f"""
    #!/bin/bash
    set -ex

    {installer} -y update
    {installer} -y install unzip git gcc
    export APTGET={installer}
    
    # we need these below
{textwrap.indent(import_env(*exports), "    ")}

    mkdir -p /bootstrap
    pushd /bootstrap/
    rm -rf cse142L
    git clone --branch $ROOT_REPO_BRANCH $HTTP_ROOT_REPO cse142L
    cd cse142L
    rm -rf cse141pp-archlab
    git clone --branch $ARCHLAB_REPO_BRANCH $HTTP_ARCHLAB_REPO 
    export INSTALL_ROOT=$PWD
    . env.sh
    
    if [ -v FAKE_IT ]; then
        echo Would run cloud/server_setup.sh, but I\'m faking it, so I won\'t.
        exit 0
    else
        bash bin/setup_server.sh
    fi
    """))
    # and again to override env.sh
#    {textwrap.indent(import_env(*exports), "    ")}


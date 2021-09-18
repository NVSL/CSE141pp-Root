
if [ "3.10.0-1160.25.1.el7.x86_64" = `uname -r` ]; then

   export LD_LIBRARY_PATH=$PWD/lib:$LD_LIBRARY_PATH
   export PATH=$PWD/bin:$PATH

   export https_proxy=campus-proxy.ucsd.edu:3128
   export http_proxy=campus-proxy.ucsd.edu:3128
fi
   

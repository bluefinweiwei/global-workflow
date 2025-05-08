help([[
Load environment to run GFS workflow setup scripts on Hera
]])

append_path("MODULEPATH","/glade/work/epicufsrt/contrib/derecho/rocoto/modulefiles")
load("rocoto")

prepend_path("MODULEPATH", "/glade/work/epicufsrt/contrib/spack-stack/derecho/spack-stack-1.6.0/envs/upp-addon-env/install/modulefiles/Core")

load(pathJoin("stack-intel", os.getenv("stack_intel_ver") or "2021.10.0"))
local python_ver=os.getenv("python_ver") or "3.10.13"

load(pathJoin("stack-intel", stack_intel_ver))
load(pathJoin("python", python_ver))
load("py-jinja2")
load("py-pyyaml")
load("py-numpy")

whatis("Description: GFS run setup environment")

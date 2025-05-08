help([[
Load environment to run GFS on Derecho
]])

local spack_mod_path=(os.getenv("spack_mod_path") or "1.6.0")
prepend_path("MODULEPATH", "/glade/work/epicufsrt/contrib/spack-stack/derecho/spack-stack-1.6.0/envs/upp-addon-env/install/modulefiles/Core")
prepend_path("MODULEPATH","/lustre/desc1/scratch/epicufsrt/contrib/modulefiles_extra")

load(pathJoin("stack-intel", (os.getenv("stack_intel_ver") or "2021.10.0")))
load(pathJoin("cray-pals", (os.getenv("crap-pals_ver") or "1.2.11")))
load(pathJoin("stack-cray-mpich", (os.getenv("stack_cray_mpich_ver") or "8.1.25")))
load(pathJoin("stack-python", (os.getenv("stack_python_ver") or "3.10.13")))

load(pathJoin("ncl", (os.getenv("ncl_ver") or "6.6.2")))
load(pathJoin("jasper", (os.getenv("jasper_ver") or "2.0.32")))
load(pathJoin("libpng", (os.getenv("libpng_ver") or "1.6.37")))
load(pathJoin("cdo", (os.getenv("cdo_ver") or "2.4.2")))
load(pathJoin("perl", (os.getenv("perl_ver") or "5.38.0")))

load(pathJoin("netcdf-c", (os.getenv("netcdf_c_ver") or "4.9.2")))
load(pathJoin("netcdf-fortran", (os.getenv("netcdf_fortran_ver") or "4.6.1")))
load(pathJoin("parallelio", (os.getenv("parallelio_ver") or "2.5.10")))

load(pathJoin("nco", (os.getenv("nco_ver") or "5.0.6")))
load(pathJoin("prod_util", (os.getenv("prod_util_ver") or "2.1.1")))
load(pathJoin("grib-util", (os.getenv("grib_util_ver") or "1.3.0")))
load(pathJoin("g2tmpl", (os.getenv("g2tmpl_ver") or "1.13.0")))
load(pathJoin("crtm", (os.getenv("crtm_ver") or "2.4.0.1")))
load(pathJoin("bufr", (os.getenv("bufr_ver") or "12.0.1")))
load(pathJoin("wgrib2", (os.getenv("wgrib2_ver") or "3.1.1")))
load(pathJoin("py-f90nml", (os.getenv("py_f90nml_ver") or "1.4.3")))
load(pathJoin("py-netcdf4", (os.getenv("py_netcdf4_ver") or "1.5.8")))
load(pathJoin("py-pyyaml", (os.getenv("py_pyyaml_ver") or "6.0")))
load(pathJoin("py-jinja2", (os.getenv("py_jinja2_ver") or "3.0.3")))
load(pathJoin("py-pandas", (os.getenv("py_pandas_ver") or "1.5.3")))
load(pathJoin("py-python-dateutil", (os.getenv("py_python_dateutil_ver") or "2.8.2")))
load(pathJoin("met", (os.getenv("met_ver") or "11.1.0")))
load(pathJoin("metplus", (os.getenv("metplus_ver") or "5.1.0")))
load(pathJoin("py-xarray", (os.getenv("py_xarray_ver") or "2023.7.0")))
load(pathJoin("hdf5", (os.getenv("hdf5_ver") or "1.14.0")))
setenv("WGRIB2","wgrib2")

-- Stop gap fix for wgrib with spack-stack 1.6.0
-- TODO Remove this when spack-stack issue #1097 is resolved
setenv("WGRIB","wgrib")
setenv("UTILROOT",(os.getenv("prod_util_ROOT") or "None"))

--prepend_path("MODULEPATH", pathJoin("/scratch1/NCEPDEV/global/glopara/git/prepobs/v" .. (os.getenv("prepobs_run_ver") or "None"), "modulefiles"))
--load(pathJoin("prepobs", (os.getenv("prepobs_run_ver") or "None")))

--prepend_path("MODULEPATH", pathJoin("/scratch1/NCEPDEV/global/glopara/git/Fit2Obs/v" .. (os.getenv("fit2obs_ver") or "None"), "modulefiles"))
--load(pathJoin("fit2obs", (os.getenv("fit2obs_ver") or "None")))

whatis("Description: GFS run environment")

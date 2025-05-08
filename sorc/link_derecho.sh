#!/bin/bash

#--make symbolic links for lookup tables and executables--#
#--based on link_workflow.sh in emc-global-workflow--#
#--Weiwei Li (weiweili@ucar.edu)--#

HOMEgfs="$(cd "$(dirname  "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd )"
echo "${HOMEgfs}"
TRACE=NO source "${HOMEgfs}/ush/preamble.sh"

LINK="ln -fs"
LINK_OR_COPY="ln -fs"

# shellcheck disable=SC1091
COMPILER="intel" source "${HOMEgfs}/sorc/gfs_utils.fd/ush/detect_machine.sh"  # (sets MACHINE_ID)
## shellcheck disable=
machine=$(echo "${MACHINE_ID}" | cut -d. -f1)

#------------------------------
#--Set up build.ver and run.ver
#------------------------------
${LINK_OR_COPY} "${HOMEgfs}/versions/build.${machine}.ver" "${HOMEgfs}/versions/build.ver"
${LINK_OR_COPY} "${HOMEgfs}/versions/run.${machine}.ver" "${HOMEgfs}/versions/run.ver"

# Link GDASapp python packages in ush/python
packages=("jcb")
for package in "${packages[@]}"; do
    cd "${HOMEgfs}/ush/python" || exit 1
    [[ -s "${package}" ]] && rm -f "${package}"
    ${LINK} "${HOMEgfs}/sorc/gdas.cd/sorc/${package}/src/${package}" .
done

# Link fix directories
FIX_DIR="/glade/work/weiweili/WPO_land/fix"
if [[ -n "${FIX_DIR}" ]]; then
  if [[ ! -d "${HOMEgfs}/fix" ]]; then mkdir "${HOMEgfs}/fix" || exit 1; fi
fi
cd "${HOMEgfs}/fix" || exit 1
for dir in aer \
            am \
            chem \
            cice \
            cpl \
            datm \
            gsi \
            lut \
            mom6 \
            orog \
            sfc_climo \
            ugwd \
            verif \
            wave
do
  if [[ -d "${dir}" ]]; then
    [[ "${RUN_ENVIR}" == "nco" ]] && chmod -R 755 "${dir}"
    rm -rf "${dir}"
  fi
  ${LINK_OR_COPY} "${FIX_DIR}/${dir}" "${dir}"
done


#---------------------------------------
#--add files from external repositories
#---------------------------------------
#--copy/link NoahMp table form ccpp-physics repository
cd "${HOMEgfs}/parm/ufs" || exit 1
${LINK_OR_COPY} "${HOMEgfs}/sorc/ufs_model.fd/tests/parm/noahmptable.tbl" .

cd "${HOMEgfs}/parm/post" || exit 1
for file in params_grib2_tbl_new nam_micro_lookup.dat
do
  ${LINK_OR_COPY} "${HOMEgfs}/sorc/upp.fd/parm/${file}" .
done
for dir in gfs gefs sfs
do
  ${LINK_OR_COPY} "${HOMEgfs}/sorc/upp.fd/parm/${dir}" .
done
for file in ice.csv ocean.csv ocnicepost.nml.jinja2
do
  ${LINK_OR_COPY} "${HOMEgfs}/sorc/gfs_utils.fd/parm/ocnicepost/${file}" .
done

cd "${HOMEgfs}/scripts" || exit 8
${LINK_OR_COPY} "${HOMEgfs}/sorc/ufs_utils.fd/scripts/exemcsfc_global_sfc_prep.sh" .
if [[ -d "${HOMEgfs}/sorc/gdas.cd" ]]; then
  declare -a gdas_scripts=(exglobal_prep_ocean_obs.py \
                           exgdas_global_marine_analysis_ecen.py \
                           )
  for gdas_script in "${gdas_scripts[@]}" ; do
    ${LINK_OR_COPY} "${HOMEgfs}/sorc/gdas.cd/scripts/${gdas_script}" .
  done
fi
cd "${HOMEgfs}/ush" || exit 8
for file in emcsfc_ice_blend.sh global_cycle_driver.sh emcsfc_snow.sh global_cycle.sh; do
  ${LINK_OR_COPY} "${HOMEgfs}/sorc/ufs_utils.fd/ush/${file}" .
done
for file in make_ntc_bull.pl make_NTC_file.pl make_tif.sh month_name.sh ; do
  ${LINK_OR_COPY} "${HOMEgfs}/sorc/gfs_utils.fd/ush/${file}" .
done

# Link these templates from ufs-weather-model
cd "${HOMEgfs}/parm/ufs" || exit 1
declare -a ufs_templates=("model_configure.IN" "input_global_nest.nml.IN"\
                          "MOM_input_025.IN" "MOM_input_050.IN" "MOM_input_100.IN" "MOM_input_500.IN" \
                          "MOM6_data_table.IN" \
                          "ice_in.IN" \
                          "ufs.configure.atm.IN" \
                          "ufs.configure.atm_esmf.IN" \
                          "ufs.configure.atmaero.IN" \
                          "ufs.configure.atmaero_esmf.IN" \
                          "ufs.configure.s2s.IN" \
                          "ufs.configure.s2s_esmf.IN" \
                          "ufs.configure.s2sa.IN" \
                          "ufs.configure.s2sa_esmf.IN" \
                          "ufs.configure.s2sw.IN" \
                          "ufs.configure.s2sw_esmf.IN" \
                          "ufs.configure.s2swa.IN" \
                          "ufs.configure.s2swa_esmf.IN" \
                          "ufs.configure.leapfrog_atm_wav.IN" \
                          "ufs.configure.leapfrog_atm_wav_esmf.IN" \
                          "post_itag_gfs")
for file in "${ufs_templates[@]}"; do
  [[ -s "${file}" ]] && rm -f "${file}"
  ${LINK_OR_COPY} "${HOMEgfs}/sorc/ufs_model.fd/tests/parm/${file}" .
done

# Link the script from ufs-weather-model that parses the templates
cd "${HOMEgfs}/ush" || exit 1
[[ -s "atparse.bash" ]] && rm -f "atparse.bash"
${LINK_OR_COPY} "${HOMEgfs}/sorc/ufs_model.fd/tests/atparse.bash" .


#------------------------------
#--link executables
#------------------------------

if [[ ! -d "${HOMEgfs}/exec" ]]; then mkdir "${HOMEgfs}/exec" || exit 1 ; fi
cd "${HOMEgfs}/exec" || exit 1

for utilexe in fbwndgfs.x gaussian_sfcanl.x gfs_bufr.x supvit.x syndat_getjtbul.x \
  syndat_maksynrc.x syndat_qctropcy.x tocsbufr.x overgridid.x rdbfmsua.x \
  mkgfsawps.x enkf_chgres_recenter_nc.x tave.x vint.x ocnicepost.x webtitle.x \
  ensadd.x ensppf.x ensstat.x wave_stat.x
do
  [[ -s "${utilexe}" ]] && rm -f "${utilexe}"
  ${LINK_OR_COPY} "${HOMEgfs}/sorc/gfs_utils.fd/install/bin/${utilexe}" .
done

[[ -s "ufs_model.x" ]] && rm -f ufs_model.x
${LINK_OR_COPY} "${HOMEgfs}/sorc/ufs_model.fd/tests/ufs_model.x" .

[[ -s "upp.x" ]] && rm -f upp.x
${LINK_OR_COPY} "${HOMEgfs}/sorc/upp.fd/exec/upp.x" .

for ufs_utilsexe in emcsfc_ice_blend emcsfc_snow2mdl global_cycle fregrid; do
    [[ -s "${ufs_utilsexe}" ]] && rm -f "${ufs_utilsexe}"
    ${LINK_OR_COPY} "${HOMEgfs}/sorc/ufs_utils.fd/exec/${ufs_utilsexe}" .
done


#------------------------------
#--link source code directories
#------------------------------
cd "${HOMEgfs}/sorc" || exit 8
if [[ -d ufs_model.fd ]]; then
  [[ -d upp.fd ]] && rm -rf upp.fd
  ${LINK} ufs_model.fd/FV3/upp upp.fd
fi

if [[ -d gsi_enkf.fd ]]; then
  [[ -d gsi.fd ]] && rm -rf gsi.fd
  ${LINK} gsi_enkf.fd/src/gsi gsi.fd

  [[ -d enkf.fd ]] && rm -rf enkf.fd
  ${LINK} gsi_enkf.fd/src/enkf enkf.fd
fi

if [[ -d gsi_utils.fd ]]; then
  [[ -d calc_analysis.fd ]] && rm -rf calc_analysis.fd
  ${LINK} gsi_utils.fd/src/netcdf_io/calc_analysis.fd .

  [[ -d calc_increment_ens.fd ]] && rm -rf calc_increment_ens.fd
  ${LINK} gsi_utils.fd/src/EnKF/gfs/src/calc_increment_ens.fd .

  [[ -d calc_increment_ens_ncio.fd ]] && rm -rf calc_increment_ens_ncio.fd
  ${LINK} gsi_utils.fd/src/EnKF/gfs/src/calc_increment_ens_ncio.fd .

  [[ -d getsfcensmeanp.fd ]] && rm -rf getsfcensmeanp.fd
  ${LINK} gsi_utils.fd/src/EnKF/gfs/src/getsfcensmeanp.fd .

  [[ -d getsigensmeanp_smooth.fd ]] && rm -rf getsigensmeanp_smooth.fd
  ${LINK} gsi_utils.fd/src/EnKF/gfs/src/getsigensmeanp_smooth.fd .

  [[ -d getsigensstatp.fd ]] && rm -rf getsigensstatp.fd
  ${LINK} gsi_utils.fd/src/EnKF/gfs/src/getsigensstatp.fd .

  [[ -d recentersigp.fd ]] && rm -rf recentersigp.fd
  ${LINK} gsi_utils.fd/src/EnKF/gfs/src/recentersigp.fd .

  [[ -d interp_inc.fd ]] && rm -rf interp_inc.fd
  ${LINK} gsi_utils.fd/src/netcdf_io/interp_inc.fd .
fi

if [[ -d gsi_monitor.fd ]] ; then
  [[ -d oznmon_horiz.fd ]] && rm -rf oznmon_horiz.fd
  ${LINK} gsi_monitor.fd/src/Ozone_Monitor/nwprod/oznmon_shared/sorc/oznmon_horiz.fd .

  [[ -d oznmon_time.fd ]] && rm -rf oznmon_time.fd
  ${LINK} gsi_monitor.fd/src/Ozone_Monitor/nwprod/oznmon_shared/sorc/oznmon_time.fd .

  [[ -d radmon_angle.fd ]] && rm -rf radmon_angle.fd
  ${LINK} gsi_monitor.fd/src/Radiance_Monitor/nwprod/radmon_shared/sorc/verf_radang.fd radmon_angle.fd

  [[ -d radmon_bcoef.fd ]] && rm -rf radmon_bcoef.fd
  ${LINK} gsi_monitor.fd/src/Radiance_Monitor/nwprod/radmon_shared/sorc/verf_radbcoef.fd radmon_bcoef.fd

  [[ -d radmon_bcor.fd ]] && rm -rf radmon_bcor.fd
  ${LINK} gsi_monitor.fd/src/Radiance_Monitor/nwprod/radmon_shared/sorc/verf_radbcor.fd radmon_bcor.fd

  [[ -d radmon_time.fd ]] && rm -rf radmon_time.fd
  ${LINK} gsi_monitor.fd/src/Radiance_Monitor/nwprod/radmon_shared/sorc/verf_radtime.fd radmon_time.fd
fi

for prog in global_cycle.fd emcsfc_ice_blend.fd emcsfc_snow2mdl.fd ;do
    [[ -d "${prog}" ]] && rm -rf "${prog}"
    ${LINK} "ufs_utils.fd/sorc/${prog}" "${prog}"
done

for prog in enkf_chgres_recenter_nc.fd \
  fbwndgfs.fd \
  gaussian_sfcanl.fd \
  gfs_bufr.fd \
  mkgfsawps.fd \
  overgridid.fd \
  rdbfmsua.fd \
  supvit.fd \
  syndat_getjtbul.fd \
  syndat_maksynrc.fd \
  syndat_qctropcy.fd \
  tave.fd \
  tocsbufr.fd \
  vint.fd \
  webtitle.fd \
  ocnicepost.fd
do
  if [[ -d "${prog}" ]]; then rm -rf "${prog}"; fi
  ${LINK_OR_COPY} "gfs_utils.fd/src/${prog}" .
done

exit 0

program decodeOSTIA

  use netcdf

  implicit none
  character (len=132) :: File, met_out_filename
  character (len=24) :: hdate,hdate1,hdate2 ! Valid date for data YYYY:MM:DD_HH:00:00
  integer :: indx,iargc,version
  integer :: ounit, io_status, istatus
  logical :: exists, is_used
  integer :: i,j,m,l,k,kf,sec,ns,status,ncid, varID
  integer :: nlat, nlon
  integer :: iproj = 0          ! Code for projection of data in array:
  real :: var
  integer :: time(1)
  real*4, dimension(:)    ,allocatable :: xlat, xlon
  real*4, dimension(:,:)  ,allocatable :: x
  real :: add_offset, scale_factor, fill_value, missing_value = -1.e+30
  integer*1, dimension(:,:)  ,allocatable :: mask
  integer*4, dimension(:,:)  ,allocatable :: sst
  character (len=21) :: field_netcdf    ! Name of the field
  character (len=9) :: field    ! Name of the field
  character (len=8) :: startloc
  character (len=25) :: units    ! Units of data
  character (len=32) :: map_source  !  Source model / originating center
  character (len=46) :: desc     ! Short description of data

  real :: xfcst                  ! Forecast hour of data
  real :: xlvl                   ! Vertical level of data in 2-d array
  real :: startlat, startlon     ! Lat/lon of point in array indicated by
                                 ! startloc string
  real :: deltalat, deltalon     ! Grid spacing, degrees
  real :: dx, dy                 ! Grid spacing, km
  real :: xlonc                  ! Standard longitude of projection
  real :: truelat1, truelat2     ! True latitudes of projection
  real :: EARTH_RADIUS = 6367.470
  logical :: is_wind_grid_rel    ! Flag indicating whether winds are 
                               !       relative to source grid (TRUE) or
                               !       relative to earth (FALSE)


  print *,'OSTIA data decoding for WPS/WRF'
  indx = iargc( )
  call getarg(1,File)
  inquire(file=trim(File), exist=exists)
  if (exists) then
     status = nf90_open(path = trim(File), mode = nf90_nowrite, ncid = ncid)
     call handle_err(status)
     print *,'Using OSTIA file: ',trim(File)        
  else
     print *,'OSTIA file ',trim(File),' does not exist'
     stop
  endif

  call get_var0(ncid,"LEN","lon",var,status)
  call handle_err(status)
  nlon = int(var)
  call get_var0(ncid,"LEN","lat",var,status)
  call handle_err(status)
  nlat = int(var)
  print *, nlat, nlon
  allocate (xlat(nlat), xlon(nlon))
  allocate (x(nlon,nlat), mask(nlon,nlat), sst(nlon,nlat))

  call get_var1( ncid,"lon",  xlon,1,nlon,status)
  call handle_err(status)
  call get_var1( ncid,"lat",  xlat,1,nlat,status)
  call handle_err(status)

! Cannot use get_var0 here because time is an integer
  status = nf90_inq_varid(ncid,"time", VarId)
  if (status == 0) status = nf90_get_var(ncid, VarId, time)
  time = time/60   ! convert from seconds since 1981-01-01 00:00:00 to hours
  print *,time

  hdate1 = "1981-01-01_00:00:00"
  call geth_newdate (hdate(1:16), hdate1(1:16), time)
  hdate = hdate(1:16)//":00"
  print *,hdate

  met_out_filename = "SST:"//hdate(1:13)
  print *,"Out Filename: ",met_out_filename
  do ounit=10,100
     inquire(unit=ounit, opened=is_used)
     if (.not. is_used) exit
  end do
  open(unit=ounit, file=trim(met_out_filename), status='unknown', &
       form='unformatted', iostat=io_status)
     
  if (io_status > 0) status = 1
! Set data parameters for all fields

  version = 5
  xfcst = 0.
  map_source = "METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2"
  xlvl = 200100.
  startloc = 'SWCORNER'
  startlat = xlat(1)
  startlon = xlon(1)
  deltalat = 0.05  !!xlat(2) - xlat(1)
  deltalon = 0.05  !!xlon(2) - xlon(1)
  is_wind_grid_rel = .False.

! Write land/sea mask
  ! field = "SST_LAND"
  ! units = "         "
  ! desc = "land/sea flag"

  ! write(unit=ounit) hdate, xfcst, map_source, field, &
  !      units, desc, xlvl, nlon, nlat, iproj
  ! write(unit=ounit) startloc, startlat, startlon, &
  !      deltalat, deltalon, earth_radius
  ! write(unit=ounit) is_wind_grid_rel
  ! print *,"Write: "//desc

  ! field = 'mask    '
  ! status = nf90_inq_varid(ncid,TRIM(field), VarId)
  ! if (status == 0) then
  !    status = nf90_get_var(ncid, VarId,mask,start=(/1,1,1/),count=(/nlon,nlat,1/))
  ! end if
  ! x = real(mask)
  ! print *,trim(field),minval(x),maxval(x)
  ! write(unit=ounit) x

  ! Write sea-ice-fraction
  field = "SEAICE   "
  units = "         "
  desc = "ice fraction"

  write(unit=ounit) version
  write(unit=ounit) hdate, xfcst, map_source, field, &
       units, desc, xlvl, nlon, nlat, iproj
  print *, hdate, xfcst, map_source, field, &
       units, desc, xlvl, nlon, nlat, iproj
  write(unit=ounit) startloc, startlat, startlon, &
       deltalat, deltalon, earth_radius
  write(unit=ounit) is_wind_grid_rel
  print *,"Write: "//desc

  field_netcdf = 'sea_ice_fraction'
  status = nf90_inq_varid(ncid,TRIM(field_netcdf), VarID)
  status = nf90_get_att(ncid, VarID, "_FillValue", fill_value)
  status = nf90_get_att(ncid, VarID, "add_offset", add_offset)
  status = nf90_get_att(ncid, VarID, "scale_factor", scale_factor)
  print *,add_offset,scale_factor
  
  if (status == 0) then
     status = nf90_get_var(ncid, VarId,mask,start=(/1,1,1/),count=(/nlon,nlat,1/))
  end if
  x = real(mask)*scale_factor + add_offset
  where(mask==fill_value)
     x = missing_value
  end where
  print *,trim(field),minval(x),maxval(x)
  write(unit=ounit) x

  ! Write SST
  field = "SST      "
  units = "         "
  desc = "analysed sea surface temperature"

  write(unit=ounit) version
  write(unit=ounit) hdate, xfcst, map_source, field, &
       units, desc, xlvl, nlon, nlat, iproj
  write(unit=ounit) startloc, startlat, startlon, &
       deltalat, deltalon, earth_radius
  write(unit=ounit) is_wind_grid_rel
  print *,"Write: "//desc

  field_netcdf = 'analysed_sst'
  status = nf90_inq_varid(ncid,TRIM(field_netcdf), VarID)
  status = nf90_get_att(ncid, VarID, "_FillValue", fill_value)
  status = nf90_get_att(ncid, VarID, "add_offset", add_offset)
  status = nf90_get_att(ncid, VarID, "scale_factor", scale_factor)
  print *,add_offset,scale_factor
  
  if (status == 0) then
     status = nf90_get_var(ncid, VarId,sst,start=(/1,1,1/),count=(/nlon,nlat,1/))
  end if
  x = real(sst)*scale_factor + add_offset
  where(sst==fill_value)
     x = missing_value
  end where
  print *,trim(field),minval(x),maxval(x)
  write(unit=ounit) x

  close(ounit)

  
end program decodeOSTIA

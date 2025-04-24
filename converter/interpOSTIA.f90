program interpOSTIA

  use netcdf

  implicit none
  character (len=132) :: File1, File2, met_out_filename
  character (len=24) :: hdate,hdate1,hdate2 ! Valid date for data YYYY:MM:DD_HH:00:00
  integer :: time_array(1)
  integer :: indx,iargc,version
  integer :: ounit, io_status, istatus
  logical :: exists, is_used
  integer :: i,j,m,n,l,k,idt
  integer :: status,ncid1,ncid2,varID
  integer :: nlat, nlon, iproj, nn=24 ! change time frequency, 4 for every 6 hours
  real :: var
  integer :: time(1)
  real, dimension(:)    ,allocatable :: xlat, xlon
  real, dimension(:,:)  ,allocatable :: sst, sst1, sst2, ice, ice1, ice2, mask_real,x
  real :: add_offset, scale_factor, fill_value, missing_value = -1.e+30
  integer*1, dimension(:,:)  ,allocatable :: mask
  integer*4, dimension(:,:)  ,allocatable :: var2d
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
  call getarg(1,File1)
  inquire(file=trim(File1), exist=exists)
  if (exists) then
     status = nf90_open(path = trim(File1), mode = nf90_nowrite, ncid = ncid1)
     call handle_err(status)
     print *,'Using OSTIA file: ',trim(File1)        
  else
     print *,'OSTIA file ',trim(File1),' does not exist'
     stop
  endif
  
  call getarg(2,File2)
  inquire(file=trim(File2), exist=exists)
  if (exists) then
     status = nf90_open(path = trim(File2), mode = nf90_nowrite, ncid = ncid2)
     call handle_err(status)
     print *,'Using OSTIA file: ',trim(File2)        
  else
     print *,'OSTIA file ',trim(File2),' does not exist'
     stop
  endif

  call get_var0(ncid1,"LEN","longitude",var,status)
  call handle_err(status)
  nlon = int(var)
  call get_var0(ncid1,"LEN","latitude",var,status)
  call handle_err(status)
  nlat = int(var)
  !!print *, nlat, nlon
  allocate (xlat(nlat), xlon(nlon))
  allocate (mask(nlon,nlat),var2d(nlon,nlat)) 
  allocate (sst(nlon,nlat),sst1(nlon,nlat),sst2(nlon,nlat))
  allocate (ice(nlon,nlat),ice1(nlon,nlat),ice2(nlon,nlat))

  call get_var1( ncid1,"longitude",  xlon,1,nlon,status)
  call handle_err(status)
  call get_var1( ncid1,"latitude",  xlat,1,nlat,status)
  call handle_err(status)

! Cannot use get_var0 here because time is an integer
  status = nf90_inq_varid(ncid1,"time", VarId)
  if (status == 0) status = nf90_get_var(ncid1, VarId, time)
  time = time/60   ! convert from seconds since 1981-01-01 00:00:00 to hours
  print *,time

  hdate = "1981-01-01_00:00:00"
  call geth_newdate (hdate1(1:16), hdate(1:16), time)
  print *, shape(hdate)
  print *, shape(hdate1)
  hdate1 = hdate1(1:16)//":00"
  print *,hdate1

! Set data parameters for all fields

  version = 5
  xfcst = 0.
  map_source = "METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2"
  xlvl = 200100.
  iproj = 0
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

  field = 'mask'
  status = nf90_inq_varid(ncid1,TRIM(field), VarId)
  if (status == 0) then
     status = nf90_get_var(ncid1, VarId,mask,start=(/1,1,1/),count=(/nlon,nlat,1/))
  end if
  x = real(mask)
  print *,trim(field),minval(x),maxval(x)
  ! write(unit=ounit) x

  ! Read mask data
  ! field_netcdf = 'mask'  ! or your mask variable name
  ! status = nf90_inq_varid(ncid1,TRIM(field_netcdf), VarID)
  ! call handle_err(status)
  ! mask_real = real(mask)
  ! print *,trim(field_netcdf),minval(mask),maxval(mask)
  ! write(unit=ounit) mask

  field_netcdf = 'sea_ice_fraction'
  status = nf90_inq_varid(ncid1,TRIM(field_netcdf), VarID)
  call handle_err(status)
  status = nf90_get_att(ncid1, VarID, "_FillValue", fill_value)
  call handle_err(status)
  status = nf90_get_att(ncid1, VarID, "add_offset", add_offset)
  call handle_err(status)
  status = nf90_get_att(ncid1, VarID, "scale_factor", scale_factor)
  call handle_err(status)
  print *,add_offset,scale_factor
  
  status = nf90_get_var(ncid1, VarId,mask,start=(/1,1,1/),count=(/nlon,nlat,1/))
  call handle_err(status)
  ice1 = real(mask)*scale_factor + add_offset
  where(mask==fill_value)
     ice1 = missing_value
  end where
  print *,trim(field),minval(ice1),maxval(ice1)

  status = nf90_get_var(ncid2, VarId,mask,start=(/1,1,1/),count=(/nlon,nlat,1/))
  call handle_err(status)
  ice2 = real(mask)*scale_factor + add_offset
  where(mask==fill_value)
     ice2 = missing_value
  end where
  print *,trim(field),minval(ice2),maxval(ice2)

  field_netcdf = 'analysed_sst'
  status = nf90_inq_varid(ncid1,TRIM(field_netcdf), VarID)
  status = nf90_get_att(ncid1, VarID, "_FillValue", fill_value)
  status = nf90_get_att(ncid1, VarID, "add_offset", add_offset)
  status = nf90_get_att(ncid1, VarID, "scale_factor", scale_factor)
  print *,add_offset,scale_factor
  
  status = nf90_get_var(ncid1, VarId, var2d,start=(/1,1,1/),count=(/nlon,nlat,1/))
  call handle_err(status)
  sst1 = real(var2d)*scale_factor + add_offset
  print *,trim(field),minval(sst1),maxval(sst1)

  status = nf90_get_var(ncid2, VarId, var2d,start=(/1,1,1/),count=(/nlon,nlat,1/))
  call handle_err(status)
  sst2 = real(var2d)*scale_factor + add_offset
  print *,trim(field),minval(sst2),maxval(sst2)
  
  idt = 24/nn
  do n=1,nn

! Figure dates in between
     time_array(1) = (n-1)*idt
     call geth_newdate (hdate(1:13), hdate1(1:13), time_array)
     print *,hdate(1:13)

! What is the filename
     met_out_filename = "SST:"//hdate(1:13)
     print *,"Out Filename: ",met_out_filename

     do ounit=10,100
        inquire(unit=ounit, opened=is_used)
        if (.not. is_used) exit
     end do
     open(unit=ounit, file=trim(met_out_filename), status='unknown', &
          form='unformatted', iostat=io_status)
     
     if (io_status > 0) istatus = 1

     field = "SST"
     units = "K"
     desc = "Sea surface temperature"

     write(unit=ounit) version
     write(unit=ounit) hdate, xfcst, map_source, field, &
          units, desc, xlvl, nlon, nlat, iproj
     write(unit=ounit) startloc, startlat, startlon, &
          deltalat, deltalon, earth_radius
     write(unit=ounit) is_wind_grid_rel

     call interp(nlon,nlat,sst1,sst2,nn,n,sst)

     where(sst < 260.)
        sst = missing_value
     end where

     print *,"Write: "//desc
     write(unit=ounit) sst

! Write sea-ice-fraction
     field = "SEAICE   "
     units = "         "
     desc = "sea ice area fraction"

     write(unit=ounit) version
     write(unit=ounit) hdate, xfcst, map_source, field, &
          units, desc, xlvl, nlon, nlat, iproj
     write(unit=ounit) startloc, startlat, startlon, &
          deltalat, deltalon, earth_radius
     write(unit=ounit) is_wind_grid_rel

     call interp(nlon,nlat,ice1,ice2,nn,n,ice)

     where(sst > 275.15)
        ice = 0.
     end where
     
     where(ice < 0.)
        ice = missing_value
     end where

     print *,"Write: "//desc
     write(unit=ounit) ice

! Write land sea mask


     field = "SST_MASK"
     units = "         "
     desc = "Land Sea mask"
     write(unit=ounit) version
     write(unit=ounit) hdate, xfcst, map_source, field, &
          units, desc, xlvl, nlon, nlat, iproj
     write(unit=ounit) startloc, startlat, startlon, &
          deltalat, deltalon, earth_radius
     write(unit=ounit) is_wind_grid_rel


     field_netcdf = 'mask'
     status = nf90_inq_varid(ncid1,TRIM(field_netcdf), VarId)
     if (status == 0) then
        status = nf90_get_var(ncid1, VarId,mask,start=(/1,1,1/),count=(/nlon,nlat,1/))
     end if


     mask_real=real(mask)
     print *,"before interp",minval(mask_real),maxval(mask_real)
     call interp(nlon,nlat,mask_real,mask_real,nn,n,mask_real)
     
     where(mask_real == 1.)
        mask_real = 0.
     end where

     where(mask_real == 2.)
        mask_real = 1.
     end where

     where(mask_real > 2.)
        mask_real = 0.
     end where

     print *,"Write: "//desc
     print *,trim(field),minval(mask_real),maxval(mask_real)
     write(unit=ounit) mask_real
     
     close(ounit)
  end do

contains 
  subroutine interp(nx,ny,x1,x2,nn,n,xx)
    implicit none 
    integer, intent (in) :: nx,ny,nn,n
    real, intent (in) :: x1(nx,ny),x2(nx,ny)
    real, intent (out) :: xx(nx,ny)

    xx = (real(nn-n+1)*x1 + real(n-1)*x2)/real(nn)

  end subroutine interp

end program interpOSTIA

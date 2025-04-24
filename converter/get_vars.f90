
!!!##################################################################################
subroutine handle_err(status)
  use netcdf
  implicit none
  integer, intent ( in) :: status

  if (status /= nf90_noerr) then
    print *, trim(nf90_strerror(status))
    stop "nf90 stopped"
  end if
end subroutine handle_err

!!!##################################################################################
subroutine get_var0(ncId,info,varname,var,stat)

  USE NETCDF

  IMPLICIT NONE
  
  CHARACTER(*)       ,INTENT(IN)    :: varname,info
  INTEGER            ,INTENT(IN)    :: ncId
  REAL               ,INTENT(OUT)   :: var
  INTEGER,optional   ,INTENT(INOUT) :: stat
  INTEGER                           :: VarId,DimId,aux
  
  IF(     TRIM(INFO).eq."VAR")THEN
     stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
     if (stat == 0) stat = nf90_get_var(ncid, VarId, var)
     
  ELSE IF(TRIM(INFO).eq."LEN")THEN
     stat = nf90_inq_dimid(ncid,TRIM(VARNAME), DimID)
     if (stat == 0) stat = nf90_inquire_dimension(ncid, DimID, len = aux)
     var = real(aux)
  END IF
  
end subroutine get_var0
!!!##################################################################################

!!!##################################################################################
subroutine get_var1(ncId,varname,var,is,ie,stat)

  USE NETCDF

  IMPLICIT NONE
  
  CHARACTER(*)         ,INTENT(IN)  :: varname
  INTEGER              ,INTENT(IN)  :: ncId,is,ie
  REAL,DIMENSION(is:ie),INTENT(OUT) :: var
  INTEGER                           :: VarId,stat,DimId,cnt
  
  cnt  = ie - is + 1
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  if (stat == 0) stat = nf90_get_var(ncid, VarId, var,start=(/is/), count=(/cnt/))
  
end subroutine get_var1
!!!##################################################################################

!!!##################################################################################
subroutine get_var2(ncId,varname,var,is,ie,js,je,stat)
  
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)               ,INTENT(IN)  :: varname
  INTEGER                    ,INTENT(IN)  :: ncId,is,ie,js,je
  REAL,DIMENSION(is:ie,js:je),INTENT(OUT) :: var
  INTEGER                                 :: VarId,stat,DimId,cnti,cntj
  
  cnti = ie - is + 1
  cntj = je - js + 1
  !!print *,VARNAME
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  if (stat == 0) stat = nf90_get_var(ncid, VarId, var, start=(/is,js/), count=(/cnti,cntj/))
  
end subroutine get_var2
!!!##################################################################################

!!!##################################################################################
subroutine get_var2S(ncId,varname,var,is,ie,js,je,stat)
! Version for string
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)               ,INTENT(IN)  :: varname
  INTEGER                    ,INTENT(IN)  :: ncId,is,ie,js,je
  CHARACTER(*),DIMENSION(is:ie,js:je),INTENT(OUT) :: var
  INTEGER                                 :: VarId,stat,DimId,cnti,cntj
  
  cnti = ie - is + 1
  cntj = je - js + 1
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  if (stat == 0) stat = nf90_get_var(ncid, VarId, var,start=(/is,js/), count=(/cnti,cntj/))
  
end subroutine get_var2S

!!!##################################################################################
subroutine get_var2SS(ncId,varname,var,is,ie,js,je,istr,stat)
! Version for string with last dimension (usually time) stride
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)               ,INTENT(IN)  :: varname
  INTEGER                    ,INTENT(IN)  :: ncId,is,ie,js,je,istr
  CHARACTER(*),DIMENSION(is:ie,js:je),INTENT(OUT) :: var
  INTEGER                                 :: VarId,stat,DimId,cnti,cntj
  
  cnti = ie - is + 1
  cntj = je - js + 1
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  if (stat == 0) stat = nf90_get_var(ncid, VarId, var,start=(/is,js/), count=(/cnti,cntj/), &
       stride=(/1,istr/))
  
end subroutine get_var2SS

!!!##################################################################################
subroutine get_var3(ncId,varname,var,is,ie,js,je,ks,ke,stat)
! Version for real
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)                     ,INTENT(IN)  :: varname
  INTEGER                          ,INTENT(IN)  :: ncId,is,ie,js,je,ks,ke
  REAL,DIMENSION(is:ie,js:je,ks:ke),INTENT(OUT) :: var
  INTEGER                                       :: VarId,stat,DimId,cnti,cntj,cntk
  
  cnti = ie - is + 1
  cntj = je - js + 1
  cntk = ke - ks + 1
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  if (stat == 0) then
     stat = nf90_get_var(ncid, VarId,var,start=(/is,js,ks/),count=(/cnti,cntj,cntk/))
  end if

end subroutine get_var3

!!!##################################################################################
subroutine get_var3S(ncId,varname,var,is,ie,js,je,ks,ke,istr,stat)
! Version with last dimension stride
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)                     ,INTENT(IN)  :: varname
  INTEGER                          ,INTENT(IN)  :: ncId,is,ie,js,je,ks,ke,istr
  REAL,DIMENSION(is:ie,js:je,ks:ke),INTENT(OUT) :: var
  INTEGER                                       :: VarId,stat,DimId,cnti,cntj,cntk
  
  cnti = ie - is + 1
  cntj = je - js + 1
  cntk = ke - ks + 1
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  !call handle_err(stat)
  if (stat == 0) then
     stat = nf90_get_var(ncid, VarId,var,start=(/is,js,ks/), &
          count=(/cnti,cntj,cntk/),stride=(/1,1,istr/))
  end if
  !call handle_err(stat)
  
end subroutine get_var3S

!!!##################################################################################
subroutine get_var3I(ncId,varname,var,is,ie,js,je,ks,ke,stat)
! Version for integer*2
  
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)                     ,INTENT(IN)  :: varname
  INTEGER                          ,INTENT(IN)  :: ncId,is,ie,js,je,ks,ke
  integer*2,DIMENSION(is:ie,js:je,ks:ke),INTENT(OUT) :: var
  INTEGER                                       :: VarId,stat,DimId,cnti,cntj,cntk
  
  cnti = ie - is + 1
  cntj = je - js + 1
  cntk = ke - ks + 1
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  if (stat == 0) then
     stat = nf90_get_var(ncid, VarId,var,start=(/is,js,ks/),count=(/cnti,cntj,cntk/))
  end if
  
end subroutine get_var3I
!!!##################################################################################


!!!##################################################################################
subroutine get_var4(ncId,varname,var,is,ie,js,je,ks,ke,ts,te,stat)
  
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)                           ,INTENT(IN)  :: varname
  INTEGER                                ,INTENT(IN)  :: ncId,is,ie,js,je,ks,ke,ts,te
  REAL,DIMENSION(is:ie,js:je,ks:ke,ts:te),INTENT(OUT) :: var
  INTEGER                                             :: VarId,stat,DimId,cnti
  INTEGER                                             :: cntt,cntj,cntk
  
  cnti = ie - is + 1
  cntj = je - js + 1
  cntk = ke - ks + 1
  cntt = te - ts + 1
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  if (stat == 0) then
     stat = nf90_get_var(ncid, VarId,var,start=(/is,js,ks,ts/),&
          count=(/cnti,cntj,cntk,cntt/))
  endif
  
end subroutine get_var4
!!!##################################################################################


!!!##################################################################################
subroutine get_var4ij(ncId,varname,var,is,js,ks,ke,ts,te,stat)
  
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)                           ,INTENT(IN)  :: varname
  INTEGER                                ,INTENT(IN)  :: ncId,is,js,ks,ke,ts,te
  REAL,DIMENSION(ks:ke,ts:te)            ,INTENT(OUT) :: var
  INTEGER                                             :: VarId,stat,DimId,cnti
  INTEGER                                             :: cntt,cntj,cntk
  
  cnti = 1
  cntj = 1
  cntk = ke - ks + 1
  cntt = te - ts + 1
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  if (stat == 0) then
     stat = nf90_get_var(ncid, VarId,var,start=(/is,js,ks,ts/),&
          count=(/cnti,cntj,cntk,cntt/))
  endif
  
end subroutine get_var4ij
!!!##################################################################################

!!!##################################################################################
subroutine get_var4I(ncId,varname,var,is,ie,js,je,ks,ke,ts,te,stat)
! Version for integers
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)                           ,INTENT(IN)  :: varname
  INTEGER                                ,INTENT(IN)  :: ncId,is,ie,js,je,ks,ke,ts,te
  INTEGER,DIMENSION(is:ie,js:je,ks:ke,ts:te),INTENT(OUT) :: var
  INTEGER                                             :: VarId,stat,DimId,cnti
  INTEGER                                             :: cntt,cntj,cntk
  
  cnti = ie - is + 1
  cntj = je - js + 1
  cntk = ke - ks + 1
  cntt = te - ts + 1
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  if (stat == 0) then
     stat = nf90_get_var(ncid, VarId,var,start=(/is,js,ks,ts/), &
          count=(/cnti,cntj,cntk,cntt/))
  endif
  
end subroutine get_var4I
!!!##################################################################################

!!!##################################################################################
subroutine get_var4S(ncId,varname,var,is,ie,js,je,ks,ke,ts,te,istr,stat)
! Version with last dimension stride
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)                           ,INTENT(IN)  :: varname
  INTEGER                                ,INTENT(IN)  :: ncId,is,ie,js,je,ks,ke,ts,te,istr
  real,DIMENSION(is:ie,js:je,ks:ke,ts:te),INTENT(OUT) :: var
  INTEGER                                             :: VarId,stat,DimId,cnti
  INTEGER                                             :: cntt,cntj,cntk
  
  cnti = ie - is + 1
  cntj = je - js + 1
  cntk = ke - ks + 1
  cntt = te - ts + 1
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  if (stat == 0) then
     stat = nf90_get_var(ncid, VarId,var,start=(/is,js,ks,ts/), &
          count=(/cnti,cntj,cntk,cntt/), stride=(/1,1,1,istr/))
  endif
  
end subroutine get_var4S
!!!##################################################################################

!!!##################################################################################
subroutine get_var5(ncId,varname,var,is,ie,js,je,ks,ke,ts,te,ps,pe,stat)
! Version for real
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)                           ,INTENT(IN)  :: varname
  INTEGER                                ,INTENT(IN)  :: ncId,is,ie,js,je,ks,ke,ts,te,ps,pe
  real,DIMENSION(is:ie,js:je,ks:ke,ts:te,ps:pe),INTENT(OUT) :: var
  INTEGER                                             :: VarId,stat,DimId
  INTEGER                                             :: cnti,cntj,cntk,cntt,cntp
  
  cnti = ie - is + 1
  cntj = je - js + 1
  cntk = ke - ks + 1
  cntt = te - ts + 1
  cntp = pe - ps + 1
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)

  if (stat == 0) then
     stat = nf90_get_var(ncid, VarId,var,start=(/is,js,ks,ts,ps/), &
          count=(/cnti,cntj,cntk,cntt,cntp/))
  end if
  
end subroutine get_var5
!!!##################################################################################

!!!##################################################################################
subroutine get_var5I(ncId,varname,var,is,ie,js,je,ks,ke,ts,te,ps,pe,stat)
! Version for integer
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)                           ,INTENT(IN)  :: varname
  INTEGER                                ,INTENT(IN)  :: ncId,is,ie,js,je,ks,ke,ts,te,ps,pe
  integer*2,DIMENSION(is:ie,js:je,ks:ke,ts:te,ps:pe),INTENT(OUT) :: var
  INTEGER                                             :: VarId,stat,DimId
  INTEGER                                             :: cnti,cntj,cntk,cntt,cntp
  
  cnti = ie - is + 1
  cntj = je - js + 1
  cntk = ke - ks + 1
  cntt = te - ts + 1
  cntp = pe - ps + 1
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)

  if (stat == 0) then
     stat = nf90_get_var(ncid, VarId,var,start=(/is,js,ks,ts,ps/), &
          count=(/cnti,cntj,cntk,cntt,cntp/))
  end if
  
end subroutine get_var5I
!!!##################################################################################

!!!##################################################################################
subroutine get_var5S(ncId,varname,var,is,ie,js,je,ks,ke,ts,te,ps,pe)
  
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)                           ,INTENT(IN)  :: varname
  INTEGER                                ,INTENT(IN)  :: ncId,is,ie,js,je,ks,ke,ts,te,ps,pe
  integer*2,DIMENSION(is:ie,js:je,ks:ke,ts:te,ps:pe),INTENT(OUT) :: var
  INTEGER                                             :: VarId,stat,DimId
  INTEGER                                             :: cnti,cntj,cntk,cntt,cntp
  
  cnti = ie - is + 1
  cntj = je - js + 1
  cntk = ke - ks + 1
  cntt = te - ts + 1
  cntp = pe - ps + 1

  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  if (stat == 0) then
     stat = nf90_get_var(ncid, VarId, var,start=(/is,js,ks,ts,ps/), &
          count=(/cnti,cntj,cntk,cntt,cntp/))
  end if
  
end subroutine get_var5S
!!!##################################################################################

!!!##################################################################################
subroutine get_var5SA(ncId,varname,var,is,ie,js,je,ks,ke,ts,te,ps,pe)
  
  USE NETCDF
  
  IMPLICIT NONE
  
  CHARACTER(*)                           ,INTENT(IN)  :: varname
  INTEGER                                ,INTENT(IN)  :: ncId,is,ie,js,je,ks,ke,ts,te,ps,pe
  integer*2,DIMENSION(is:ie,js:je,ks:ke,ts:te,ps:pe),INTENT(OUT) :: var
  integer*2, dimension(:,:,:,:,:), allocatable        :: aux
  INTEGER                                             :: VarId,stat,DimId
  INTEGER                                             :: cnti,cntj,cntk,cntt,cntp
  
  cnti = ie - is + 1
  cntj = je - js + 1
  cntk = ke - ks + 1
  cntt = te - ts + 1
  cntp = pe - ps + 1
  allocate(aux(cnti,cntj,cntk,cntt,cntp))
  stat = nf90_inq_varid(ncid,TRIM(VARNAME), VarId)
  if (stat == 0) then
     stat = nf90_get_var(ncid, VarId,aux,start=(/is,js,ks,ts,ps/), &
          count=(/cnti,cntj,cntk,cntt,cntp/))
     var = var + aux
  end if
  deallocate(aux)
  
end subroutine get_var5SA
!!!##################################################################################

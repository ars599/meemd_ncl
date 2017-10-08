;================================================
load "/short/p66/ars599/work_meemd/meemd_ncl/fun_plot2d.ncl"
load "/short/p66/ars599/work_meemd/meemd_ncl/fun_eemd2.ncl"
;================================================
begin

;; parameters

nos_img = 0.1;
goal = 5;
ens = 200;
nos_wn = 0.5;
dims   = 1
opt    = False

   Nlat   = 40
   Slat   = -40
   Elon   = 140
   Wlon   = 260

;; load data
  f      = addfile("HadISST_sst.2015-2016.pac.anom.nc","r")
  v1    = f->sst(11,:,:)
v1!0="lat"
v1!1="lon"
  soi    = v1({lat|Slat:Nlat},{lon|Elon:Wlon})
  printVarSummary(soi) ;; [20] x [20]
  dSizes = dimsizes(soi)

;; 2-D EEMD  

  soi  = where(ismissing(soi),0,soi)
  etmp = eemd2(soi, goal, ens, nos_wn)
;printVarSummary(etmp[0])

  vM2d = etmp[0]

;;==== plot =====
type="eps"
do i=0,goal-1
  name="conwomap"+i
  soi@long_name="EEMD Sinusoidal signal"
  soi@units="no unit"
  plot_2d(type,name,vM2d(:,:,i))
end do
;;==== plot =====

end

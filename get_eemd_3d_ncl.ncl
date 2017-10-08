;================================================
load "/short/p66/ars599/work_meemd/meemd_ncl/fun_plot2d.ncl"
load "/short/p66/ars599/work_meemd/meemd_ncl/test_sst2d/fun_eemd3.ncl"
;================================================
begin

;; parameters

nos_img = 0.1;
goal = 5;
ens = 200;
nos_wn = 0.5;

   Nlat   = 20
   Slat   = -20
   Elon   = 140
   Wlon   = 260

;; load data
  f      = addfile("HadISST_sst.1950-2016.pac.anom.nc","r")
  soi    = f->sst
  printVarSummary(soi) ;; [20] x [20]
  dSizes = dimsizes(soi)

;;==== plot =====
type="eps"
name="conwomap3d1"
soi@long_name="Sinusoidal signal"
soi@units="no unit"
  plot_2d(type,name,soi(10,:,:))
;;==== plot =====


;; 3-D EEMD  

  optEMD             = True
  optEMD@diro        =  "./"
  optEMD@rowFName    =  "eemd_row.nc"
  optEMD@colFName    =  "eemd_col.nc"
  optEMD@verFName    =  "eemd_ver.nc"

  soi  = where(ismissing(soi),0,soi)
  etmp = eemd3(soi, goal, ens, nos_wn,optEMD)
;printVarSummary(etmp[0])

printVarSummary(etmp) ;; [time | 63] x [lat | 20] x [lon | 20] x [3]

;;==== plot =====

;***********************
; Save 3D output MEEMD data
;***********************
  diro   = "./"
  outFile = diro+"sindata1_3d_meemd.nc"
  system("\rm "+outFile)
  fout         = addfile( outFile,"c")
  fout@title   = "meemd"
  fout->meemd  = etmp(time|:,nimf|:,lat|:,lon|:)

end

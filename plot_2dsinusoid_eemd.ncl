;=================================================
load "meemd_ncl/fun_eemd2.ncl"
;=================================================
begin

    N     = 200
    pi    = 4*atan(1.0)
    t     = fspan(0,1,N)*1.0

    S1    = sin(2*2*pi*t) ;; cos(2*5*pi*t)
;;    S2    = sin(2*2*pi*t)
;===================================;
;; putting matrix with time series ;;
print("Setting up input data ......")
   na = dimsizes(S1)
   nb = dimsizes(S1)
   SX = conform_dims( (/na, nb/), S1, (/ 1 /) )
;;   SY = conform_dims( (/na, nb/), S2, (/ 1 /) )

   SY = new((/na,nb/),typeof(S1))
   SY = 1

do i = 0,N-1
  do j = 0,N-1
    SY(i,j) = cos( 4*2*pi*t(i) + 4*2*pi*t(j) )  ;; np.cos(y*4*pi2 + 4*x*pi2)
  end do
end do

   SXY = SX +  SY

; EEMD options
  ensemble_size    = 50
  noise_strength   = 0.01
  rng_seed         = 0
  num_imfs         = 8          ; calculate 'M'

  opt              = True
  opt@S_number     = 6
  opt@num_siftings = 50
  opt@rng_seed     = 0

print("Working on EEMD ......")
  etmp             = eemd2(SXY, num_imfs, ensemble_size, noise_strength, opt)
IMFs = etmp[0]
printVarSummary(IMFs)

  diro   = "./"
  outFile = diro+"sinusoid2d.nc"
  system("\rm "+outFile)
  fout         = addfile( outFile,"c")
  fout@title   = "sinusoid"
  fout->imfs   = IMFs
print("saving files to-> "+outFile)
;=================================================;
; PLOT 
;=================================================;
  wks  = gsn_open_wks("eps","sinusoid2d")   ; send graphics to PNG file
  plot = new(3+num_imfs,graphic)                ; create graphic array

  res                      = True          ; plot mods desired

  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@cnFillOn             = True          ; turn on color
  res@cnFillPalette        = "gui_default" ; set color map
  res@lbLabelBarOn         = False        ; turn off individual lb's
 
  res@vpWidthF             = 0.5           ; change aspect ratio of plot
  res@vpHeightF            = 0.3

;  res@gsnMaximize         = True          ; maximize plot size
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       =  -1.0              ; set min contour level
  res@cnMaxLevelValF       =   1.0              ; set max contour level
  res@cnLevelSpacingF      =   0.2              ; set contour spacing

  plot(0) = gsn_csm_contour(wks,SX,res)       ; contour the variable
  plot(1) = gsn_csm_contour(wks,SY,res)       ; contour the variable
  plot(2) = gsn_csm_contour(wks,SXY,res)       ; contour the variable

; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar
  resP@lbLabelAutoStride   = True         ; auto stride on labels
  resP@txString            = "Input Signals"

  gsn_panel(wks,plot(0:2),(/3,1/),resP)     ; draw all 'neof' as one plot

  res@lbLabelBarOn         = True        ; turn off individual lb's
do i = 0,num_imfs-1
  plot(i+3) = gsn_csm_contour(wks,IMFs(:,:,i),res)       ; contour the variable
end do

  resP@txString            = "Output IMFs"
  resP@gsnPanelLabelBar    = False         ; add common colorbar
  gsn_panel(wks,plot(3:3+num_imfs-1),(/num_imfs/2,2/),resP)     ; draw all 'neof' as one plot

end

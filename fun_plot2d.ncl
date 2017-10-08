;=================================================;
; PLOT 2
;=================================================;

undef("plot_2d")

procedure plot_2d(type[1]:string,name[1]:string,data[*][*]:numeric)
begin

  wks  = gsn_open_wks(type,name)   ; send graphics to PNG file

  res                     = True          ; plot mods desired

  res@cnFillOn            = True          ; turn on color
  res@cnFillPalette       = "gui_default" ; set color map
 
  res@vpWidthF            = 0.5           ; change aspect ratio of plot
  res@vpHeightF           = 0.3

  res@gsnMaximize         = True          ; maximize plot size

  plot = gsn_csm_contour(wks,data,res)       ; contour the variable

end

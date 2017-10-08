;========================================
;Org: from https://github.com/leeneil
;convert to ncl
;owned by Arnold Sullivan
;history 08 10 2017
;========================================

undef("eemd3")

function eemd3(data[*][*][*]:numeric, goal[*]:integer, \
                        ens[*]:integer, nos_wn[*]:float ,opt : logical )
local i, modes, O, P, Q
begin

  opt@diro        =  opt@diro
  opt@rowFName    =  opt@rowFName
  opt@colFName    =  opt@colFName
  opt@verFName    =  opt@verFName

;; 3-D EEMD dim#1 "data in lat"
print("Solving layer one")
;; apply eemd on x direction of var
  sz = dimsizes(data)
  O = new((/sz(0), sz(1), sz(2), goal/),typeof(data),data@_FillValue)
  O = 0
O!0 = "time"
O!1 = "lat"
O!2 = "lon"
  dims   = 0
  opt    = False

do w =0,sz(2)-1
  print("Solving layer one w=" + (w+1) + " / " + sz(2))
  do u=0,sz(0)-1
    row_modes = eemd(data(u,:,w),goal,ens,nos_wn,opt,dims) ;; [3] x [20]
row_modes!0 = "nimf"
row_modes!1 = "lat"
    row_modes = where(ismissing(row_modes),0,row_modes)
    O(u,:,w,:)  = row_modes(lat|:, nimf|:) ;; [time | 63] x [lat-row | 20] x [lon | 20] x [nimf | 3]
  end do
end do

;***********************************************************
  print("Saving 3D-row ..............")
  diro    = opt@diro
  outFile = diro+opt@rowFName
  system("\rm "+outFile)
  fout         = addfile( outFile,"c")
  fout@title   = "3D-row"
  fout->row_meemd  = O
;***********************************************************

;; 3-D EEMD dim#2 "data in time"
print("Solving layer two")
  P = new((/sz(0), sz(1), sz(2), goal, goal/),typeof(data),data@_FillValue)
P!0 = "time"
P!1 = "lat"
P!2 = "lon"
P!3 = "m"
  P = 0

do m =0,goal-1
  print("Solving layer two mode m=" + (m+1) + " / " + goal)
  do w =0,sz(2)-1
    do v=0,sz(1)-1
      col_modes = eemd(O(:,v,w,m),goal,ens,nos_wn,opt,dims) ;; [3] x [63]
col_modes!0 = "nimf"
col_modes!1 = "time"
      col_modes = where(ismissing(col_modes),0,col_modes)
      P(:,v,w,m,:)  = col_modes(time|:, nimf|:) ;; [col-time | 63] x [lat | 20] x [lon | 20] x [m | 3] x [nimf | 3]
    end do
  end do
end do

delete(O)

;***********************************************************
  print("Saving 3D-col ..............")
  diro    = opt@diro
  outFile = diro+opt@colFName
  system("\rm "+outFile)
  fout         = addfile( outFile,"c")
  fout@title   = "3D-col"
  fout->col_meemd  = P
;***********************************************************

;; 3-D EEMD dim#3
print("Solving layer three")
  Q = new((/sz(0), sz(1), sz(2), goal, goal, goal/),typeof(data),data@_FillValue)
Q!0 = "time"
Q!1 = "lat"
Q!2 = "lon"
Q!3 = "m2"
Q!4 = "m1"
  Q = 0

do m1 =0,goal-1
  Qtmp = new((/sz(0), sz(1), sz(2), goal, goal/),typeof(data),data@_FillValue)
Qtmp!0 = "time"
Qtmp!1 = "lat"
Qtmp!2 = "lon"
Qtmp!3 = "m2"
  Qtmp = 0  ;; [time | 63] x [lat | 20] x [lon | 20] x [m2 | 3] x [3]
  Ptmp = P(time|:,lat|:,lon|:,m|:,nimf|m1)  ;; [time | 63] x [lat | 20] x [lon | 20] x [m | 3]
  do m2 =0,goal-1
    print("Solving layer three mode m2=" + (m2+1) + " / " + goal)
    do v=0,sz(1)-1
      do u=0,sz(0)-1
        stk = Ptmp(time|u,lat|v,lon|:,m|m2)
	stk_modes = eemd(stk,goal,ens,nos_wn,opt,dims) ;; [3] x [20]
	stk_modes = where(ismissing(stk_modes),0,stk_modes)
stk_modes!0 = "nimf"
stk_modes!1 = "lon" ;; [nimf | 3] x [stk | 20]
	Qtmp(u,v,:,m2,:) = stk_modes(lon|:,nimf|:) ;; [time | 63] x [lat | 20] x [stk-lon | 20] x [m2 | 3] x [nimf | 3]
      end do
    end do
  end do
  Q(:,:,:,:,m1,:) = Qtmp(time|:,lat|:,lon|:,m2|:,nimf|:)
end do

delete(P)

;***********************************************************
  print("Saving 3D-ver ..............")
  diro    = opt@diro
  outFile = diro+opt@verFName
  system("\rm "+outFile)
  fout         = addfile( outFile,"c")
  fout@title   = "3D-ver"
  fout->ver_meemd  = Q
;***********************************************************

;; Combine modes

  R = new((/sz(0), sz(1), sz(2), goal/),typeof(data),data@_FillValue)
R!0 = "time"
R!1 = "lat"
R!2 = "lon"
  R = 0
  ndim = 3 ;; 3D so imf starts from the fourth dimension

do m=goal-1,0,1
   print("Combine mode m=" + (m+1) + " / " + goal)
   R(:,:,:,m) = dim_sum_n_Wrap(Q(:,:,:,m::,m::,m::),(/3,4,5/))
   if m.lt.(goal-1) then
     R(:,:,:,m) = R(:,:,:,m) - dim_sum_n_Wrap(R(:,:,:,(m+1)::),ndim)
   end if
end do

R!3 = "nimf"

delete(Q)

  return(R)

end

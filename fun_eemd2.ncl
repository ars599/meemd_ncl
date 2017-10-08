
undef("eemd2")

function eemd2(data[*][*]:numeric, goal[*]:integer, \
                        ens[*]:integer, nos_wn[*]:float )
local i, modes, G, D
begin

;; 2-D EEMD dim#1

;; apply eemd on x direction of var
  sz = dimsizes(data)
  G = new((/sz(0), sz(1), goal/),typeof(data),data@_FillValue)
  G = 0
  dims   = 0
  opt    = False

do u=0,sz(0)-1
  row_modes = eemd(data(u,:),goal,ens,nos_wn,opt,dims) ;; [3] x [20]
row_modes!0 = "nimf"
row_modes!1 = "row"
  row_modes = where(ismissing(row_modes),0,row_modes)
;  G(i,:,:)  = permute(row_modes, [3 2 1])
  G(u,:,:)  = row_modes(row|:, nimf|:)
end do

;; 2-D EEMD dim#2

  D = new((/sz(0), sz(1), goal, goal/),typeof(data),data@_FillValue)
  D = 0
do m=0,goal-1
  do v = 0,sz(1)-1
  col_modes = eemd(G(:,v,m),goal,ens,nos_wn,opt,dims) ;; [3] x [20]
col_modes!0 = "nimf"
col_modes!1 = "col"
  col_modes = where(ismissing(col_modes),0,col_modes)
  D(:,v,m,:)  = col_modes(col|:, nimf|:)
  end do
end do

;; Combine modes

  H = new((/sz(0), sz(1), goal/),typeof(data),data@_FillValue)
  H = 0
do m = 0,goal-1
    do k = m,goal-1
        H(:,:,m) = H(:,:,m) + D(:,:,m,k);
        H(:,:,m) = H(:,:,m) + D(:,:,k,m);
    end do
    H(:,:,m) = H(:,:,m) - D(:,:,m,m);
end do
H!0 = "row"
H!1 = "col"
H!2 = "nimf"
modes = H

  return([/modes,G,D/])

end

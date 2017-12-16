;;  function [spmax, spmin, flag]= extrema(in_data)
;;
;; This is a utility program for cubic spline envelope,
;;   the code is to  find out max values and max positions
;;                            min values and min positions
;;    (then use matlab function spline to form the spline)
;;
;;   function [spmax, spmin, flag]= extrema(in_data)
;;
;; INPUT:
;;       in_data: Inputted data, a time series to be sifted;
;; OUTPUT:
;;       spmax: The locations (col 1) of the maxima and its corresponding
;;              values (col 2)
;;       spmin: The locations (col 1) of the minima and its corresponding
;;              values (col 2)
;;
;; NOTE:
;;      EMD uses Cubic Spline to be the Maximun and Minimum Envelope for
;;        the data.Besides finding spline,end points should be noticed. 
;;
;;References:  ? which paper?
;; 
;;
;;
;; code writer: Zhaohua Wu. 
;; footnote:S.C.Su
;;
;;  modify to NCL version: Arnold Sullivan 15/11/2017
;;
;; There are two seperste loops in this code .
;; part1.-- find out max values and max positions 
;;          process the start point and end point  
;; part2.-- find out min values and max positions 
;;          process the start point and end point  
;; Those parts are similar.
;;
;; Association:eemd.m
;; this function ususally used for finding spline envelope
;;
;; Concerned function: no
;;                     (all matlab internal function)

undef("extrema")

function extrema(in_data[*]:numeric )
;;function [spmax, spmin, flag]= extrema(in_data)

begin

flag=1;
dsize=dimsizes(in_data);
spmax = new((/dsize,2/),typeof(in_data)) 
spmax(0,0) = 0;
spmax(0,1) = in_data(0);
jj=1;
kk=1;
do while (jj .lt. dsize-2)
    if ( in_data(jj-1) .le. in_data(jj) .and. in_data(jj) .ge. in_data(jj+1) )
        spmax(kk,0) = jj
        spmax(kk,1) = in_data (jj)
        kk = kk+1
    end if
    jj=jj+1
end do


;vTemp(0,:)=spmax(:,0)
;vTemp(1,:)=spmax(:,1)
;  plot_1d(wks_type,wks_name,vTemp,optPlt)

;;end point
spmax(kk,0)=dsize;
spmax(kk,1)=in_data(dsize-1);

if kk .ge. 4 then
    slope1=(spmax(1,1)-spmax(2,1))/(spmax(1,0)-spmax(2,0));
    tmp1=slope1*(spmax(0,0)-spmax(1,0))+spmax(1,1);
    if tmp1 .gt. spmax(0,1) then
        spmax(0,1)=tmp1;
    end if

    slope2=(spmax(kk-1,1)-spmax(kk-2,1))/(spmax(kk-1,0)-spmax(kk-2,0));
    tmp2=slope2*(spmax(kk,0)-spmax(kk-1,0))+spmax(kk-1,1);
    if tmp2 .gt. spmax(kk,1) then
        spmax(kk,1)=tmp2;
    end if
else
    flag=-1;
end if
spmax = where(ismissing(spmax),0,spmax)

delete(tmp1)
delete(tmp2)

;;local min
spmin = new((/dsize,2/),typeof(in_data)) 
;;local min 
spmin(0,0) = 0;
spmin(0,1) = in_data(0);
jj=1;
kk=1;
do while (jj .lt. dsize-2)
    if ( in_data(jj-1) .ge. in_data(jj) .and. in_data(jj) .le. in_data(jj+1) )
        spmin(kk,0) = jj
        spmin(kk,1) = in_data (jj)
        kk = kk+1
    end if
    jj=jj+1
end do


;;local min
spmin(kk,0)=dsize-1
spmin(kk,1)=in_data(dsize-1)

if kk .ge. 4 then
    slope1=(spmin(1,1)-spmin(2,1))/(spmin(1,0)-spmin(2,0))
    tmp1=slope1*(spmin(0,0)-spmin(1,0))+spmin(1,1)
    if tmp1 .gt. spmin(0,1) then
        spmin(0,1)=tmp1
    end if

    slope2=(spmin(kk-1,1)-spmin(kk-2,1))/(spmin(kk-1,0)-spmin(kk-2,0))
    tmp2=slope2*(spmin(kk,0)-spmin(kk-1,0))+spmin(kk-1,1)
    if tmp2 .gt. spmin(kk,1) then
        spmin(kk,1)=tmp2
    end if
else
    flag=-1
end if
spmin = where(ismissing(spmin),0,spmin)

flag=1

return([/spmax,spmin,flag/])

end

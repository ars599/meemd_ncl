;; function omega = ifndq(vimf, dt)
;;
;;
;; INPUT:   
;;          vimf:        an IMF;
;;          dt:          time interval of the imputted data
;; OUTPUT:
;;          omega:       instantanesous frequency, which is 2*PI/T, where T
;;                       is the period of an oscillation
;; NOTE:
;;     this is a function to calculate instantaneous based on EMD method--
;;     normalize the absolute values and find maximum envelope for 5 times
;;     then calculate the Quadrature ,Phase angle,then take difference to them
;;     finally,the instantaneous frequency values of an IMF is found. 
;;
;;Reference:  
;;
;;
;;  code writer:Zhaohua Wu,mailbox:zhwu@cola.iges.org
;;  footnote:S.C.Su 2009/05/14
;;
;;  modify to NCL version: Arnold Sullivan 15/11/2017
;;
;; 1.set initial parameters
;; 2.find absolute values
;; 3.find the spline envelope for AM,take those out-loop start
;;   4.Normalize the envelope out (for 5 times)
;; 3.find the spline envelope for AM,take those out-loop end 
;; 5.flip back those negative values after AM been removed    
;; 6.Calculate the quadrature values
;; 7.Calculate the differece of the phase angle and give +/- sign
;; 8.create a algorithm to remove those outliner
;; 9.remove those marked outliner
;;10.use cubic spline to smooth the instantaneous frequency values 
;;11.return the values back
;;
;;
;; Association:  those procedure of HHT need this code
;;1.EMD 
;;2.EEMD
;;
;; Concerned function: no
;;
;;

undef("ifndq")

function ifndq(vimf[*]:numeric, dt[*]:numeric )

;local oemga
begin

;%
;%1.set initial parameters
 Nnormal=5 ; %number of spline envelope normalization for AM
 rangetop=0.90; %the threshold of outliner remove for instantaneous frequency values
 vlength = max( dimsizes(vimf) );
 vlength_1 = vlength -1;
 abs_vimf = new((/vlength/),typeof(vimf))
 nvimf    = new((/vlength/),typeof(vimf))
 dq       = new((/vlength/),typeof(vimf))
 devi     = new((/vlength/),typeof(vimf))
 omgcos   = new((/vlength/),typeof(vimf))
 dddTmp   = new((/vlength/),typeof(vimf))
 tempTmp  = new((/vlength/),typeof(vimf))
 omega    = new((/vlength/),typeof(vimf))
;%2.find absolute values
 do i=0,vlength_1
     abs_vimf(i)=vimf(i)
     if abs_vimf(i) .lt. 0 then
         abs_vimf(i)=-vimf(i)
     end if
 end do

;%3.find the spline envelope for AM,take those out-loop start
 do jj=0,Nnormal-1
      extvar=extrema(abs_vimf)
      spmaxTmp = extvar[0]
      spminTmp = extvar[1] 
      flag     = extvar[2]
      id_len   = get1Dindex(spmaxTmp(:,0),vlength)
      spmax    = spmaxTmp(0:id_len,:)
      id_len   = get1Dindex(spminTmp(:,0),vlength_1)
      spmin    = spminTmp(0:id_len,:)
;printVarSummary(spmax)

     dd    = ispan(0,vlength_1,1)
     upper = ftcurv(spmax(:,0),spmax(:,1),dd) ;; (xi, yi, 0.1, xo)
;%4.Normalize the envelope out 
     do i=0,vlength_1
         abs_vimf(i)=abs_vimf(i)/upper(i)
     end do
;delete(spmaxTmp)
delete(spmax)
;delete(spminTmp)
delete(spmin)
delete(extvar)
 end do
copy_VarMeta(vimf,upper)

;%5.flip back those negative values after AM been removed
 do i=0,vlength_1
     nvimf(i)=abs_vimf(i)
     if vimf(i) .lt. 0
         nvimf(i)=-abs_vimf(i)
     end if
 end do

;%6.Calculate the quadrature values
 do i=0,vlength_1
     dq(i)=sqrt(1-nvimf(i)*nvimf(i))
 end do
copy_VarMeta(vimf,dq)

;%7.Calculate the differece of the phase angle and give +/- sign
 do i=1,vlength-2
     devi(i)=nvimf(i+1)-nvimf(i-1)
     if devi(i) .gt. 0 .and. nvimf(i) .lt. 1
         dq(i)=-dq(i);
     end if
 end do
copy_VarMeta(vimf,devi)

;%8.create a algorithm to remove those outliner
rangebot=-rangetop
 do i=1,(vlength-2)
     if nvimf(i) .gt. rangebot .and. nvimf(i) .lt. rangetop
        ;%good original value,direct calculate instantaneous frequency  
         omgcos(i)=abs(nvimf(i+1)-nvimf(i-1))*0.5/sqrt(1-nvimf(i)*nvimf(i))
     else
        ;%bad original value,direct set -9999,mark them 
         omgcos(i)=-9999
     end if
 end do
 omgcos(0)=-9999;
 omgcos(vlength_1)=-9999;
copy_VarMeta(vimf,omgcos)

;%9.remove those marked outliner
 jj=0
 do i=0,vlength_1
     if omgcos(i) .gt. -1000
         dddTmp(jj)=i
         tempTmp(jj)=omgcos(i)
         jj=jj+1
     end if
 end do
 id_len   = jj-1
 ddd    = dddTmp(0:id_len)
 temp   = tempTmp(0:id_len)

;%10.use cubic spline to smooth the instantaneous frequency values 
 omgcos = ftcurv(ddd,temp,dd)

;%11.return the values back
 do i=0,vlength_1
     omega(i)=omgcos(i)
 end do
 pi2=get_pi("double")*2;
 omega=omega/dt

return(omega)

end

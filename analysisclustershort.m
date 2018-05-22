clear datain dataout udt vdt wdt ndt wddt pdt yhat ggg XXX XX1 XX2 A sorted ggg95 gggave ggg50 
clear ldt ldts udts vdts wdts ndts wddts pdts yhats gggs uu vv fitexpo qdt mddt sddt aa bb p 
clear loglik slog YY sprop OBJ SRED pMLE dd cc FF A wdts mddt p matr aa YY NN NY YYY NYY
clear figure(1),clear figure(2),clear figure(3)
% Input dat XX with total and partials on columns 4 5 6

N=1000;K=1;RRR=1;
datain(:,1:3)=XX;
XX2=XX;
XX2(:,4)=max(XX2(:,2),XX2(:,3));
datain(:,4)=(1/4)*((datain(:,3)-datain(:,2)).^2./datain(:,1)-1)./(datain(:,1)-1);
[udt vdt]=sort(datain(:,1));
wdt=datain(vdt,4);ndt=datain(vdt,1);
qdt=XX2(vdt,4)./udt;
ldt=length(datain);
for i=1:ldt
    LL=min(50,max(20,i));
    wddt(i)=mean(wdt(max(1,i-LL):min(ldt,i+LL)));
    sddt(i)=std(wdt(max(1,i-LL):min(ldt,i+LL)));
    sprop(i)=std(qdt(max(1,i-LL):min(ldt,i+LL)));
end
pdt=.5+sqrt(max(0,wddt'));
stdp=sqrt(max(10^-6,(1*((udt-1)./udt).^2.*sddt.^2'-(2/udt.^2)*(1/4-wddt').^2-4*wddt'.*(1/4-wddt')./udt)./(4.*(wddt'+(1/4-wddt')./udt))));

mdat=max(datain(:,1));
matr=eye(mdat);
for i=2:mdat-1
    matr(i,i)=2;
end
for i=1:mdat-1
    matr(i,i+1)=-1;
    matr(i+1,i)=-1;
end
YY=zeros(mdat,1);
YYY=zeros(mdat,1);
NN=YY;
NY=NN;
NYY=NY;
for i=1:mdat
    NN(i)=sum(datain(:,1)==i);
    if NN(i)>0
        YY(i)=mean(max(0,datain(datain(:,1)==i,4)));
    end
    NY(i)=NN(i)*YY(i);
end
lambda=1000;
aa=inv(diag(NN)+lambda*matr)*NY;
for i=1:mdat
    YYY(i)=((i-1)/i)^2*NN(i)*(YY(i)-aa(i))^2-4*aa(i)*(1/4-aa(i))/i-2*(1/4-aa(i))^2/i^2;
    YYY(i)=YYY(i)/(4*(aa(i)+(1/4-aa(i))/i));
    NYY(i)=NN(i)*YYY(i);
end
FF=1;TT=0;
while TT<0.002
    bb=inv(diag(NN)+FF*lambda*matr)*NYY;
    cc=sqrt(max(10^-6,bb));
    FF=FF+.1;
    TT=cc(end);
end
    dd=1/2+sqrt(aa);

figure(1),plot(udt,stdp),grid,zoom
figure(2),plot(udt,pdt),grid,zoom
figure(3),plot([dd-cc dd dd+cc]),grid,zoom

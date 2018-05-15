function [A,B, FCoor,DicI,Iord,Lambda_s , distortion] = PDMEmbedding_Opt_MRG_v2(Xdr,epsilon,mu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Inputs:
%         Xdr - given dataset
%         epsilon - the gaussian radius
%         mu - the required accuracy of the diffusion distances
%
%Outputs:
%         A,B are the relevant subblocks of the kernel matrix
%          FCoor - is the approximated diffusion maps
%         DicI - is the dictionary indecs
%         Iord - is the order of the datapoints relative to input
%         Lambda_s - are the approximated eigenvalues
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


N_In         = size(Xdr, 1);
dists          = pdist2(Xdr,Xdr);
W             = exp(-dists.^2/epsilon);
Dr            = sum(W,2);
invsqDr    = diag(1./sqrt(Dr));
invsqDrVec = diag(invsqDr);
Wn           = invsqDr*W*invsqDr;

N_start      = 2;
D_iter        = N_start;
%conpute the degree


%do the init embedding
Adists     = pdist2(Xdr(1:N_start,:),Xdr(1:N_start,:));
Bdists     = pdist2(Xdr(1:N_start,:),Xdr(N_start+1:end,:));




At         = exp(-Adists.^2/epsilon);
Bt         = exp(-Bdists.^2/epsilon).';


% Q^-0.5
Da         = invsqDr(1:N_start,1:N_start);
Db         = invsqDr(N_start+1:end,N_start+1:end);
%a(S , S)
A          = Da*At*Da;
% b = a(S , S^)
B          = Db'*Bt*Da;

Bru      = B'*B;

%C from section 4.1
% should be A and not A' , but this matrices is exactly same
S          = A'+A^-0.5*Bru*A^-0.5;

[U_s,Lambda_s,V_s] = svd(S);

% the ONM - dont clear
% this is definition of ONM with osy_hat from eq. 4.5
% U_s is psy
DicCoor            = Da*A^0.5*U_s*Lambda_s^0.5;
RestCoor           = Db*B*A^-0.5*U_s*Lambda_s^0.5;

I_rest             = 1:N_In;
I_rest             = setdiff(I_rest,1:N_start);

%%%%%
%mu                 = 0.01;
B_ind              = 1;

for ij=N_start+1:N_In
    % find the coordination of the new point using extension
    %     for ik=1:D_iter
    %         %estimated diffusion distance
    %         d_estimated(ik) = norm(RestCoor(B_ind,:)-DicCoor(ik))^2;
    %     end
    %actual diffusion distance
    
    Atmp             = [A B(B_ind,:)';B(B_ind,:),invsqDr(ij,ij)^2] + 10 ^ -12;
    NB               = 1:size(B,1);
    I                   =  setdiff(NB,B_ind);
    I_rest_tmp    = setdiff(I_rest,ij);
    wti                = pdist2(Xdr(ij,:),Xdr(I_rest_tmp,:));
    wti                = exp(-wti.^2/epsilon);
    wtivec           = invsqDrVec(ij)*wti.*invsqDrVec(I_rest_tmp)';
    Btmp             = [B(I,:),wtivec'];
    
    %%%%
    Bru                            = Btmp'*Btmp; %ns^2
    Atmp_m5                   = Atmp^-0.5 ;
    % again - should be Atmp?
    S                                = Atmp'+Atmp_m5*Bru*Atmp_m5;

    positivedefinite = all( eig(S) > 0 );
    
    [U_s,Lambda_st,V_s] = svd(S); %s^3
    
    Dtmp        = diag(invsqDr);
    Dtmp        = diag(Dtmp([I_rest_tmp]));
    % the other ONM
    RestCoort = Dtmp*Btmp*Atmp_m5*U_s*Lambda_st^0.5; %n s^2 + s^3
    
    Dtmp        = diag(invsqDr);
    Dtmp        = diag(Dtmp([setdiff(1:N_In,I_rest),ij]));
    % new ONM
    gCoor       = Dtmp*Atmp^0.5*U_s*Lambda_st^0.5;
    
    % phi tag in the article
    candCoor          = gCoor(end,1:end);
    DRealCoor       = gCoor(1:end-1,1:end);
    
    % the equation of MTM here:
    % phi * T = phi_tag
    % so T = pinv(phi) * phi_tag
    
    %DicCoor,  T = pinv(DicCoor)*DRealCoor
    T                          = pinv(DicCoor)*DRealCoor;
    % RestCoor(B_ind,:) = phi in the article
    candCoorChange = RestCoor(B_ind,:)*T;
    
    
    d_i(ij) = norm(candCoor - candCoorChange  );
%     [d_i(ij),D_iter,ij]
    
    if(d_i(ij)>mu)
        %add to dic
        
        %update A,B,S, SVD
        A            = Atmp;% [A B(B_ind,:)';B(B_ind,:),invsqDr(ij,ij)^2];
        I_rest      = I_rest_tmp;% setdiff(I_rest,ij);
        B                               = Btmp;%[B(I,:),wtivec'];
        %         Bru                            = B'*B;
        %         S                                = A'+A^-0.5*Bru*A^-0.5;
        %         [U_s,Lambda_s,V_s] = svd(S);
        %
        %         Da         = [Da,Da(:,1)*0;Da(1,:)*0, Db(B_ind,B_ind)];
        %         Dbt        = diag(Db);
        %         Db         = diag(Dbt(I));
        Lambda_s = Lambda_st;
        DicCoor     = gCoor;%Da*A^0.5*U_s*Lambda_s^0.5;
        RestCoor    = RestCoort;%;Db*B*A^-0.5*U_s*Lambda_s^0.5; %n s^2 + s^3
        
        D_iter = D_iter+1;
        B_ind  = B_ind-1;
       
    end
    
    B_ind = B_ind+1;
end
DicI = setdiff(1:N_In,I_rest);
Iord = [DicI,I_rest];
Coor = [DicCoor;RestCoor];
%FCoor = Coor;
FCoor(Iord,:) = Coor;

distortion = max2( abs( pdist2(FCoor , FCoor) - pdist2( Wn , Wn ) ) );

tmp=1;


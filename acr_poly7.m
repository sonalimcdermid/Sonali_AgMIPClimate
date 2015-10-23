%			acr_poly7
%
%       This routine allows a least square fit of any 7-variate function 
%       containing polynomial terms.  When a model vector 
%       in the proper format is passed in, the function returns the 
%       amplitude of each component as well as the 
%       reconstructed time series.
%
%       where:
%       tseries = series to be fitted (vector of length M)
%       tt1     = corresponding values (vector of length M) of first variable
%       tt2     = corresponding values (vector of length M) of second variable
%       tt3     = corresponding values (vector of length M) of third variable
%       tt4     = corresponding values (vector of length M) of fourth variable
%       tt5     = corresponding values (vector of length M) of fifth variable
%       tt6     = corresponding values (vector of length M) of sixth variable
%       tt7     = corresponding values (vector of length M) of sixth variable
%       model1  = model containing fit parameters (vector) for first variable
%       model2  = model containing fit parameters (vector) for second variable
%       model3  = model containing fit parameters (vector) for third variable
%       model4  = model containing fit parameters (vector) for fourth variable
%       model5  = model containing fit parameters (vector) for fifth variable
%       model6  = model containing fit parameters (vector) for sixth variable
%       model7  = model containing fit parameters (vector) for sixth variable
%
%       returns:
%       construct = reconstruction of the model from fitted data
%       const     = constant (0th order polynomial amplitude -- not necessarily mean)
%       amp      = amplitude of each polynomial term
%
%
%				author: Alex Ruane
%                                       alexander.c.ruane@nasa.gov
%				date:   10/01/12
   function [construct,const,amp] = acr_poly7(tseries,tt1,tt2,tt3,tt4,tt5,tt6,tt7,model1,model2,model3,model4,model5,model6,model7);

%% begin debug
%tseries = (mean(yield,2)');
%tt1 = [hyper(:,1);0];
%tt2 = [hyper(:,3);1];
%tt3 = [hyper(:,4);360];
%tt4 = tt1.*tt2;
%tt5 = tt1.*tt3;
%tt6 = tt2.*tt3;
%tt7 = tt1.*tt2.*tt3;
%model1 = [1 2];
%model2 = [1 2];
%model3 = [1 2];
%model4 = [1];
%model5 = [1];
%model6 = [1];
%model7 = [1];
%% end debug

% general parameters
nmod1 = length(model1);
nmod2 = length(model2);
nmod3 = length(model3);
nmod4 = length(model4);
nmod5 = length(model5);
nmod6 = length(model6);
nmod7 = length(model7);
ntt = length(tt1);

% construct G
G = ones(ntt,1+nmod1+nmod2+nmod3+nmod4+nmod5+nmod6+nmod7);

index = 1;
for ii=1:nmod1,
    G(:,1+index) = (tt1.^real(model1(ii)))';
    index = index+1;
end;
for ii=1:nmod2,
    G(:,1+index) = (tt2.^real(model2(ii)))';
    index = index+1;
end;
for ii=1:nmod3,
    G(:,1+index) = (tt3.^real(model3(ii)))';
    index = index+1;
end;
for ii=1:nmod4,
    G(:,1+index) = (tt4.^real(model4(ii)))';
    index = index+1;
end;
for ii=1:nmod5,
    G(:,1+index) = (tt5.^real(model5(ii)))';
    index = index+1;
end;
for ii=1:nmod6,
    G(:,1+index) = (tt6.^real(model6(ii)))';
    index = index+1;
end;
for ii=1:nmod6,
    G(:,1+index) = (tt7.^real(model7(ii)))';
    index = index+1;
end;


% solve as overdetermined least squares
mm = inv(G'*G)*G'*tseries';

% pull out constant
const = mm(1);

% get amplitudes

index = 1;
for ii=1:(nmod1),
  amp(ii) = mm(1+index);
  index = index+1;
end;
for ii=1:(nmod2),
  amp(ii+nmod1) = mm(1+index); 
  index = index+1;
end;
for ii=1:(nmod3),
  amp(ii+nmod1+nmod2) = mm(1+index);
  index = index+1;
end;
for ii=1:(nmod4),
  amp(ii+nmod1+nmod2+nmod3) = mm(1+index);
  index = index+1;
end;
for ii=1:(nmod5),
  amp(ii+nmod1+nmod2+nmod3+nmod4) = mm(1+index);
  index = index+1;
end;
for ii=1:(nmod6),
  amp(ii+nmod1+nmod2+nmod3+nmod4+nmod5) = mm(1+index);
  index = index+1;
end;
for ii=1:(nmod7),
  amp(ii+nmod1+nmod2+nmod3+nmod4+nmod5+nmod6) = mm(1+index);
  index = index+1;
end;

% reconstruct time series -- sometimes the tt1 in quadratics should be tt1'
construct = ones(ntt,1)*const;
for ii=1:nmod1,
  construct = construct + squeeze(amp(ii)*(tt1.^real(model1(ii))));
end;
for ii=1:nmod2,
  construct = construct + squeeze(amp(ii+nmod1)*(tt2.^real(model2(ii))));
end;
for ii=1:nmod3,
  construct = construct + squeeze(amp(ii+nmod1+nmod2)*(tt3.^real(model3(ii))));
end;
for ii=1:nmod4,
  construct = construct + squeeze(amp(ii+nmod1+nmod2+nmod3)*(tt4.^real(model4(ii))));
end;
for ii=1:nmod5,
  construct = construct + squeeze(amp(ii+nmod1+nmod2+nmod3+nmod4)*(tt5.^real(model5(ii))));
end;
for ii=1:nmod6,
  construct = construct + squeeze(amp(ii+nmod1+nmod2+nmod3+nmod4+nmod5)*(tt6.^real(model6(ii))));
end;
for ii=1:nmod7,
  construct = construct + squeeze(amp(ii+nmod1+nmod2+nmod3+nmod4+nmod5+nmod6)*(tt7.^real(model7(ii))));
end;

% make sure everything aligns appropriately
amp = amp;
construct = construct';



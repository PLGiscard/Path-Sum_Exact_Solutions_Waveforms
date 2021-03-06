%% M. Foroozandeh, P.-L. Giscard, 04/2022
% Run test_compare to compute the one-spin system [in SU(2) representation]
% solution by all methods available.

%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all


% para = paragen(Omega,alpha,DeltaF,taup,Phi0,deltat,deltaf,n);
para = paragen(2*pi*1000,180,100000,0.001,0,0.0005,0,30);
TMAX = 0.001; % Max simulation time, in s

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ODE45 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NT_PCPA = 500; % Set the number of points to be used for the ode45 
               % reference solution and for PCPA (piecewise-constant propagator approximation)
tol = 1e-13;   % Relative and absolute tolerance for reference solution by ode45

figure;
sgtitle('Propagation via ODE45')

% One additional time point must be added to PCPA and ode45 methods 
% to run comparisons at identical time points with PS Trap and PS Simp
[rho_ODE,elapsedTime_ODE] = one_spin_ODE(para,TMAX,NT_PCPA+1,tol);
fprintf('\n %s Finished in %5.3f seconds, Tolerance  = %e\n', 'ODE45', elapsedTime_ODE, tol);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PCPA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
sgtitle('Propagation via PCPA')

[rho_PCPA,elapsedTime_PCPA] = one_spin_PCPA(para,TMAX,NT_PCPA+1);
fprintf('\n %s Finished in %5.3f seconds, NT = %i', 'PCPA', elapsedTime_PCPA, NT_PCPA);

% Compute the relative error on the Frobenius scalar product between
% density matrices
f=plotfrob(rho_PCPA,rho_ODE);
fprintf('\n Average Frobenius accuracy of %s : %e\n\n', 'PCPA', sum(f)./length(f))
figure
sgtitle('Frobenius accuracy of PCPA')
plot(1:length(f),real(f),'k')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PATH-SUMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NPrec = 500; % Number of points per path-sum interval
NInt = 1; % Number of time sub-intervals

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIMPSON QUADRATURE %%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
sgtitle('Propagation via Path-Sum Simpson')

[rho_PS_SIMP,TimeTot,elapsedTime_PS]=one_spin_PS_SIMP(para,TMAX*1000,NPrec,NInt);
fprintf('\n %s Finished in %5.3f seconds, NPrec = %i, NInt = %i', 'Path Sum Simpson', elapsedTime_PS, NPrec, NInt);

% Compute the relative error on the Frobenius scalar product between
% density matrices
if NT_PCPA==NInt*NPrec
    f=plotfrob(rho_PS_SIMP,rho_ODE);
    fprintf('\n Average Frobenius accuracy of %s : %e\n\n', 'Path Sum Simpson', sum(f)./length(f))
    figure
    sgtitle('Frobenius accuracy of PS Simpson')
    plot(1:length(f),real(f),'b')
else
    display('WARNING Number of points for ode45 must be equal to NInt*NPrec for CORRECT accuracy evaluation')
end

%%%%%%%%%%%%%%%%%%%%%%%%%% TRAPEZOIDAL QUADRATURE %%%%%%%%%%%%%%%%%%%%%%%%%
figure;
sgtitle('Propagation via Path-Sum Trapezoidal')

[rho_PS_TRAP,~,elapsedTime_PS]=one_spin_PS_TRAP(para,TMAX*1000,NPrec,NInt);
fprintf('\n %s Finished in %5.3f seconds, NPrec = %i, NInt = %i', 'Path Sum Trapezoidal', elapsedTime_PS, NPrec, NInt);

% Compute the relative error on the Frobenius scalar product between
% density matrices
if NT_PCPA==NInt*NPrec
    f=plotfrob(rho_PS_TRAP,rho_ODE);
    fprintf('\n Average Frobenius accuracy of %s : %e\n\n', 'Path Sum Trapezoidal', sum(f)./length(f))
    figure
    sgtitle('Frobenius accuracy of PS Trapezoidal')
    plot(1:length(f),real(f),'r')
else
    display('WARNING Number of points for ode45 must be equal to NInt*NPrec for CORRECT accuracy evaluation')
end



function f=frob(A,B)
f=trace(A'*B); % Frobenius scalar product between matrices A and B
end

function E=plotfrob(a,b)
%E is the 1 minus the normalised Frobenius scalar product between matrices
%  A = a(i) and B = b(i) for i running on all time points.
ll=size(a);ll=ll(3);
E=zeros(1,ll);

for i=1:ll
    A = a(:,:,i);
    B = b(:,:,i);
    E(i) = frob(A,B)/sqrt(frob(A,A)*frob(B,B));
end
E=1-E;

end
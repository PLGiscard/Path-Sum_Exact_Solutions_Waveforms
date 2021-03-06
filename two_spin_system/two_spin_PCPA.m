function [rho,t_array,elapsedTime] = two_spin_PCPA(para,TMAX,NT)
%% M. Foroozandeh, P.-L. Giscard, 04/2022
% para : parameters as generated by paragen
% TMAX : en ms, maximum evolution time
% NT : number of numerical evalutation points 

% Time evolution of the elements of density matrix for a single spin-1/2
% propagation with PCPA expansion

t_array = linspace(0,TMAX,NT);
tres = t_array(2);

smfactor = para.n;
offs_f = para.deltaf;
bandwidth = para.DeltaF;
phi0 = para.Phi0;
tau_p = para.taup;
Omega = para.Omega;
J = para.J;
omega1 = para.omega1;
offs_t = para.deltat;


tic;

%pauli matrices

Sigmax = 0.5*[0,1;1,0];Sigmay = 0.5*[0,-1i;1i,0];Sigmaz = 0.5*[1,0;0,-1];Unity_mat = [1,0;0,1];

% building multi-state operators for both spins
Lx = kron(Sigmax,Unity_mat);
Ly = kron(Sigmay,Unity_mat);
Lz = kron(Sigmaz,Unity_mat);

Sx = kron(Unity_mat,Sigmax);
Sy = kron(Unity_mat,Sigmay);
Sz = kron(Unity_mat,Sigmaz);

% J coupling and offsets
J_LS = 2*pi*J;

Omega_L = Omega(1);
Omega_S = Omega(2);

waveform=chirp_fun(tau_p,bandwidth,phi0,omega1,offs_t,offs_f,smfactor,t_array);

rho_0 = (Lz+Sz)/norm(Lz+Sz); % initial state

% This takes the offset and pulse information and run the numerical
% simulation and then plot the time evolution of the elements of the final density matrix

for i=1:length(waveform)
    
    H{i} = Omega_L*Lz + Omega_S*Sz ...
        + real(waveform(i))*(Lx+Sx)+imag(waveform(i))*(Ly+Sy)...
        + J_LS*(Lx*Sx+Ly*Sy+Lz*Sz);
    
    rho_tau_p{i} = expm(-1i*tres*H{i})*rho_0*expm(1i*tres*H{i});
    rho(:,:,i)=rho_tau_p{i};
    
    rho_0=rho_tau_p{i};
    
    rho_tau_p{i}=(rho_tau_p{i}).';
    rho_tau_p{i}=rho_tau_p{i}(:);
    
end

elapsedTime = toc;

end

function pulse=chirp_fun(tau_p,bandwidth,phi0,omega1,offs_t,offs_f,smfactor,t_array)

Cx = (exp(-(2^(smfactor+2))*((t_array-offs_t)/tau_p).^smfactor)).*(omega1*cos(phi0+(pi*bandwidth*((t_array-offs_t).^2)/tau_p)-2*pi*offs_f*(t_array-offs_t)));
Cy = (exp(-(2^(smfactor+2))*((t_array-offs_t)/tau_p).^smfactor)).*(omega1*sin(phi0+(pi*bandwidth*((t_array-offs_t).^2)/tau_p)-2*pi*offs_f*(t_array-offs_t)));

pulse = complex(Cx,Cy);

end

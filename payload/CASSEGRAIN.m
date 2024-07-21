%% Cassagrainian Telescope
close all
clear variables

F = 2.4;
f1 = 0.6:0.01:1.0;
M = F./f1;
D1 = 0.35;
% e = 0.05;
d = 0.55;
p = f1-d;
e = p.*(M+1)-f1;
% p = (f1+e)/(M+1);
D2 = (D1.*p)./f1;
R2 = (2.*p.*M)/(M-1);
q = M.*p;
d = q-e;
dqdp = R2.^2./(4.*p.^2-4.*p.*R2+R2.^2);
dqdR2 = (p./(R2-2.*p)) - R2.*p./(R2-2.*p).^2;

lambda = 700e-9;
pix_rad = 4.86e-6;
theta_r = 1.22*lambda/(D1);
d_prime = 2*theta_r;
Q = pix_rad/d_prime;

% disp("-----------------------------------------------------------------------------------------------------------------------");
% disp(append("F=",string(F)," | D1=",string(D1)," | f1=",string(f1)," | d=",string(d)," | D2=",string(D2)," | f2=",string(q)," | e=",string(e)," | dq/dp=",string(dqdp)," | dq/dR2=",string(dqdR2)))
% disp("-----------------------------------------------------------------------------------------------------------------------");
figure("Name",append("d = ",string(d(1))),'NumberTitle','off')
plot(f1,D2,"b",f1,q,"r",f1,-e,"m")
legend("D2","f2","e")
grid on
xlabel("$f1[m]$",'Interpreter','latex')

figure
plot(f1,dqdp,"g",f1,dqdR2,"k")
grid on
legend("dq/dp","dq/dR2")
% ylabel("dq/dp",'Interpreter','latex')
xlabel("$f1[m]$",'Interpreter','latex')

disp("-----------------------------------------------------------------------------------------------------------------------");
disp(append("F=",string(F)," | D1=",string(D1)," | d=",string(d(1))," | Q=",string(Q)))
disp("-----------------------------------------------------------------------------------------------------------------------");

function [ys,z_final,z_locked,z_wingtip,mom_error,locked_mom,ffwt_scaleFactor] = get_lift_dist(Span,FusDiam,HingeEta,MTO,M_ffwt,CoM_ffwt,g)
%GET_LIFT_DIST creates lift distribution for wing with fuselages + FFWTs
r_fus = FusDiam/2;

%generate grid
ys = linspace(0,Span,50001)-Span/2;

%function for lift distribution minus wingtips
z_w = @(x)sqrt(1-(2*x/Span).^2)./(pi*Span/2/2);
z_f = @(x)z_w(0)*exp(-1/2*(2*x/r_fus).^2)/2;
z = @(x)(z_w(x)-z_f(x))/(1-z_w(0)/2*(r_fus/2*sqrt(2*pi))); % make sure it has an area of 1

z_locked = z(ys);
if HingeEta==1
    z_final = z_locked;
    z_wingtip = z_locked*0;
    mom_error = 0;
    return
end


%create wingtip Lift distribution with an area of zero
offset = fminsearch(@(x)wt_cost(x,ys./(Span/2),HingeEta),0);
etas = ys./(Span/2);
idx = etas>=HingeEta;
[zs,~,~] = wt_lift_dist(etas,HingeEta,offset);

%set zs to have Normalised moment of one about the hinge
Mom_hinge =  trapz(etas(idx),zs(idx).*(etas(idx)-HingeEta));
zs = zs./Mom_hinge;

%calc current moment about hinge (from elliptic lift distribtion)
locked_mom = trapz(ys(idx),z_locked(idx).*MTO*g.*(ys(idx)-HingeEta*Span/2));

%calc required moment about the hinge
req = M_ffwt*g*abs(CoM_ffwt);

%adjust lift distrubtion to get correct moment
delta = req-locked_mom;
ffwt_scaleFactor = delta/((Span/2)^2*MTO*g);
z_wingtip = zs.*ffwt_scaleFactor;
z_final = z_locked+z_wingtip;
m_dist = trapz(ys(idx),z_final(idx).*MTO*g.*(etas(idx)-HingeEta)*Span/2);
mom_error = m_dist-req;
end



function [zs,A,A_wt] = wt_lift_dist(eta,hingeEta,offset)
l_wt = (1-hingeEta);
xs = abs(eta);
zs = ones(size(eta));
m_t = l_wt;
zs(xs>=hingeEta) = sqrt(1-(2*(xs(xs>=hingeEta)-hingeEta)/(l_wt*2)).^2);
zs = zs.*((1/2*((tanh((eta-hingeEta)*6/m_t)-tanh((eta+hingeEta)*6/m_t)))+1)*(1+offset)-offset);
A = trapz(eta,zs);
A_wt = abs(trapz(eta(xs<=hingeEta),zs(xs<=hingeEta)));
end

function val = wt_cost(offset,eta,hingeEta)
    [~,A] = wt_lift_dist(eta,hingeEta,offset);
    val = A^2;
end


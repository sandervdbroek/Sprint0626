function baffItm = addMass(obj, baffItm, mass, eta, offset, id)

for m_idx = 1:length(mass)
    massOb = baff.Mass(mass(m_idx),"eta",eta(m_idx),"Name",id{m_idx});
    massOb.Offset = [0; offset(m_idx); 0];
    baffItm.add(massOb);
    clear massOb
end
end
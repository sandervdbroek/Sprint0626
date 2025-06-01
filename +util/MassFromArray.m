function massOb = MassFromArray(masses,etas,offsets,names)
arguments
    masses double
    etas double
    offsets double
    names
end
massOb = baff.Mass.empty;
for m_idx = 1:length(masses)
    massOb(m_idx) = baff.Mass(masses(m_idx),"eta",etas(m_idx),"Name",names{m_idx});
    massOb(m_idx).Offset = [0; offsets(m_idx); 0];
end
end


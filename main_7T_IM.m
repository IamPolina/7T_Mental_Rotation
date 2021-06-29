function main_7T_IM
% This script runs main analysis for the publication: 
% Iamshchinina et al., 2021 ('Perceived and mentally rotated contents
% are represented at the differential cortical depth')
% For running the scripts below the following toolboxes are necessary: 

V = 'V1'; 
% Sort values from raw data by trials, time points and cortical depth
%sort_brain_by_conditions(V);
% in every depth bin and time point decode presented, rotated and not shown
% gratings 
[P,R,N]=decoding_raw;
% plot main result
plot_main_7T_IM(P,R,N,V) ; 
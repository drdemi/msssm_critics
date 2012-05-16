%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sandpile simulation
%
%

f = critical_field(200,200,3,true);

[s,nc,ts,f] = sandpile(f, [-1 +1 0 0; 0 0 -1 +1], 3, 1, 5000, 2, false, true, 0.2);

[a,b,c,d] = avalanche_distribution_analysis(s,ts)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% to do: continuous grain placing (0...1) à la grain size
%
% 

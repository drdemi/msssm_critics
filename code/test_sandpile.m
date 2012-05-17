%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sandpile simulation
%
%

f = critical_field(20,20,3,true);

[s,nc,ts,f] = sandpile(f, [-1 +1 0 0; 0 0 -1 +1], 3, 1, 50, 2, true, false, 0.2, false);

[a,b,c,d] = avalanche_distribution_analysis(s,ts)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% to do: continuous grain placing (0...1) à la grain size
%
%        h parameter

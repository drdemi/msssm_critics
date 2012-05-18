%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sandpile simulation environment
%
%

f = critical_field(200,200,3,false);

[s,nc,ts,f] = sandpile(f, [-1 +1 0 0; 0 0 -1 +1], 3, 1, 500, 3, false, false, 0.2, false);

[a,b,c,d] = avalanche_distribution_analysis(s,ts)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% not yet implemented: 
%	- continuous grain placing with grain size (0...1)
%	- h parameter

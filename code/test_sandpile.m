%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sandpile simulation environment
%
%

%f = critical_field(50,50,3,false);
%f = 3*ones(50,50);
f = zeros(30,30);

%f, neighbour, critical_state, ...
%	collapse_per_neighbour, timesteps, boundary_type, make_pictures, ...
%	silent, driving_plane_reduction, var_grain, same_place
[s,nc,ts,f,energy] = sandpile(f, [-1 +1 0 0; 0 0 -1 +1], 3, ...
			1, 5000, 3, 0, ...
			true, 0, false, true);

[a,b,c,d] = avalanche_distribution_analysis(s,ts)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% not yet implemented: 
%	- continuous grain placing with grain size (0...1)
%	- h parameter

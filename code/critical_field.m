function f = critical_field(width,height,critical_state,uniform)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% generates a random field/lattice for sandpile simulation
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PARAMETERS:
%	width, height = size of lattice/field to be created
%	critical_state = maximum/critical state of a site, usually = 3
%	uniform = true will generate a field of e.g. 0's and 3's only
%	uniform = false will generate a field e.g. with numbers 0 to 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% define field using uniform distribution
	if (uniform)
		f = floor(unifrnd(0,2,height,width))*critical_state;
	else
		f = floor(unifrnd(0,critical_state+1,height,width));
	end
end

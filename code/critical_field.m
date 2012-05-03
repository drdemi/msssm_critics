function f = critical_field(width,height,critical_state)
	% define field
	f = floor(unifrnd(1,critical_state,height,width)); % this uses uniform distribution of random numbers
end

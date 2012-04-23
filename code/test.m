%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sandpile simulation
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parameters
width = 5;		% field size
height = 5;
neighbours = 4;		% neighbours to collapse to
neighbour_offset_x = [-1 +1 0 0];
neighbour_offset_y = [0 0 -1 +1];
critical_state = 3;	% critical/max. number of grains before collapse
collapse = 1;		% number of grains to collapse PER NEIGHBOUR
timesteps = 100;	% simulation duration in steps (excl. avalanches)
boundary = 1;		% 1 - infinite, no boundaries
			% 2 - to be implemented...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define field
f = zeros(height,width);

% define stack for avalanches
stack_x = 0;
stack_y = 0;
stack_n = 0;

% temporary neighbour matrix
%neighbour = zeros(1,neighbours+1);	% index = same as neighbour offsets, last neighbour value = current field

for t=1:timesteps
	disp(['time: ' num2str(t) ' / ' num2str(timesteps)]);

	% choose random site
	y=floor(unifrnd(1,height));
	x=floor(unifrnd(1,width));	% this uses uniform distribution of random numbers

	% place grain
	f(y,x) = f(y,x) + 1;

	% save picture
	draw_field(f,2);
	print(['field' num2str(t) '.png'],'-dpng');

	% push site to stack
	stack_n = 1;
	stack_x(1) = x;
	stack_y(1) = y;

	% avalanche - work through stack
	while (stack_n > 0)

		% pop from stack
		x = stack_x(stack_n);
		y = stack_y(stack_n);
		stack_n = stack_n - 1;

		disp(['x ' num2str(x) '; y ' num2str(y)]);

		% check if overcritical
		if (f(y,x) > critical_state)

			disp('collapse!');

			% collapse
			f(y,x) = f(y,x) - neighbours * collapse;

			% check each neighbour
			for n=1:neighbours

				%disp('checking...');
				disp(['n ' num2str(n)]);

				% check boundary -> modify neighbour offsets
				if (boundary == 1)				% no-boundary conditions (pack-man style)
					if (y+neighbour_offset_y(n) < 1)
						neighbour_offset_y(n) = neighbour_offset_y(n) + height;
					end
					if (y+neighbour_offset_y(n) > height)
						neighbour_offset_y(n) = neighbour_offset_y(n) - height;
					end
					if (x+neighbour_offset_x(n) < 1)
						neighbour_offset_x(n) = neighbour_offset_x(n) + width;
					end
					if (x+neighbour_offset_x(n) > width)
						neighbour_offset_x(n) = neighbour_offset_x(n) - width;
					end	
				end
				%disp(['x ' num2str(x+neighbour_offset_x(n)) '; y ' num2str(y+neighbour_offset_y(n))]);

				% save neighbour value
				%neighbour(n) = f(y+neighbour_offset_y(n),x+neighbour_offset_x(n));

				% add/transport grain to neighbour
				f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) = f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) + collapse;

				% push neighbour's neighbours to stack
				stack_n = stack_n + 1;
				stack_x(stack_n) = x + neighbour_offset_x(n);
				stack_y(stack_n) = y + neighbour_offset_y(n);
%				for nn=1:neighbours
%					stack_x(stack_n+nn) = x + neighbour_offset_x(n) + neighbour_offset_x(nn);
%					stack_y(stack_n+nn) = y + neighbour_offset_y(n) + neighbour_offset_y(nn);
%				end
			end
        end
    end

	disp(f);
	disp('');
end

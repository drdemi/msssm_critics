function [as,nc,at,final] = sandpile(f, neighbour, critical_state, collapse_per_neighbour,
				timesteps, boundary_type, make_pictures, silent)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sandpile simulation using stack algorithm for avalanche generation
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUTS
%	f 			 field matrix
%	neighbour 		 2xN matrix with x & y offsets of neighbours
%	critical_state 		 critical/max. number of grains before collapse
%	collapse_per_neighbour 	 number of grains to collapse
%	timesteps 		 simulation duration in steps (excl. avalanches)
%	boundary_type 		 type of boundary condition
%					 1 - infinite/continuous, like pac-man
%					 2 - energy loss at boundaries, table-like
%					 3 - ...
%	make_pictures 		 draw and export all frames or not
%	silent 			 produces no output (except time progress) if true

% OUTPUTS
%	as			avalanche sizes (topplings count) for each timestep (statistics)
%	nc			size at avalanche-starting-site for eacg t
%	at			avalanche lifetime for each t
%	final			final field

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% translate parameters

	width = size(f,2);
	height = size(f,1);
	neighbours = size(neighbour,2);		% number ofneighbours to collapse to
	neighbour_offset_x = neighbour(1,:);	
	neighbour_offset_y = neighbour(2,:);
	collapse = collapse_per_neighbour;
	boundary = boundary_type;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% define stack for avalanches
	stack_x = 0;
	stack_y = 0;
	stack_n = 0;

	% avalanche statistics
	avalanche_sizes = zeros(1, timesteps);
	av_begin_t = zeros(1,timesteps);
	avalanche_lifetime = zeros(1,timesteps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	for t=1:timesteps
		% display time progress
		disp(['time: ' num2str(t) ' / ' num2str(timesteps)]);

		% choose random site
		y=floor(unifrnd(1,height));
		x=floor(unifrnd(1,width));	% uniform distribution rnd

		% place grain
		f(y,x) = f(y,x) + 1;

		% save picture of field before collapsing (with active field)
		if (make_pictures)
			draw_field(f,2);
			print(['field' num2str(t) '.png'],'-dpng');
		end

		% push site to stack
		stack_n = 1;
		stack_x(1) = x;
		stack_y(1) = y;

		% save avalanche starting site
		av_begin_x = x;
		av_begin_y = y;
		av_begin_t(t) = 0; % # topplings at avalanche starting site

		% avalanche - work through stack
		while (stack_n > 0)

			% pop from stack
			x = stack_x(stack_n);
			y = stack_y(stack_n);
			stack_n = stack_n - 1;

			% display current site
			if (silent==false) 
				disp(['current site: x ' num2str(x) '; y ' num2str(y)]);
			end

			% check if overcritical/active
			if (f(y,x) > critical_state)

				% communicate collapsing
				if (silent==false)
					disp('collapse!');
				end

				% save avalanche size for statistics
				avalanche_sizes(t) = avalanche_sizes(t) + 1;
				if ((x==av_begin_x) & (y==av_begin_y))
					% save # topplings at av starting site
					av_begin_t(t) = av_begin_t(t) + 1;
				end

				% collapse/topple
				f(y,x) = f(y,x) - neighbours * collapse;

				% check each neighbour
				for n=1:neighbours

					% communicate
					if (silent==false)
						disp(['neighbour ' num2str(n)]);
					end

					%%%%%% check boundary %%%%%%

						% 1) no-boundary conditions (continuous field, pack-man style)
						if (boundary == 1)

							% modify neighbour offsets
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

							% add/transport grain to neighbour
							f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) = f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) + collapse;

							% push neighbour's neighbours to stack
							stack_n = stack_n + 1;
							stack_x(stack_n) = x + neighbour_offset_x(n);
							stack_y(stack_n) = y + neighbour_offset_y(n);

						% 2) energy loss at boundary (table style)
						elseif (boundary == 2)

							% keep offsets, but check if outside of boundary
							if ((y+neighbour_offset_y(n) < 1) |
								(y+neighbour_offset_y(n) > height) |
								(x+neighbour_offset_x(n) < 1) | 
								(x+neighbour_offset_x(n) > width))
								% outside of boundary...do nothing =)
							else
								% add/transport grain to neighbour
								f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) = f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) + collapse;

								% push neighbour's neighbours to stack
								stack_n = stack_n + 1;
								stack_x(stack_n) = x + neighbour_offset_x(n);
								stack_y(stack_n) = y + neighbour_offset_y(n);
							end
						end

					%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				end
		end
	    end

		% display field after collapsing
		if (silent==false)
			disp(f);
			disp('');
		end
	end

	% return avalanche sizes
	as = avalanche_sizes;

	% return number of topplings at avalanche starting site
	nc = av_begin_t;

	% return final state
	final = f;
end

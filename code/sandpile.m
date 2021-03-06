function [as,nc,at,final,energy] = sandpile(f, neighbour, critical_state, ...
	collapse_per_neighbour, timesteps, boundary_type, make_pictures, ...
	silent, driving_plane_reduction, var_grain, same_place) 
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
%					 3 - mixed. continuous in x-direction and 
%						energy loss in y-direction
%	make_pictures 		 draw and export all frames or not
%				 >0 means save a pic for each t,
%				 >1 means avalanches too
%	silent 			 produces no output (except time progress) if true
%	driving_plane_reduction	 percentage of field close to the boundary
%				 not to be affected by driving (putting grains)
%				 = 0   => use whole field (default)
%				 = 0.2 => put grains at least 0.2*width
%				          and 0.2*height far away from boundary
%				 > 0.5 => invalid [!]
%	var_grain		true/false - use random grain size [0...1]

% OUTPUTS
%	as			avalanche sizes (topplings count) for each timestep
%	nc			size at avalanche-starting-site for eacg t
%	at			avalanche lifetime for each t
%	final			final field
%	energy			array of energy states for each timestep

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% translate parameters

	width = size(f,2);
	height = size(f,1);
	neighbours = size(neighbour,2);		% number of neighbours to collapse to
	neighbour_offset_x = neighbour(1,:);	
	neighbour_offset_y = neighbour(2,:);
	collapse = collapse_per_neighbour;
	boundary = boundary_type;

	picture_counter = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% define stack for avalanches
	stack_x = 0;
	stack_y = 0;
	stack_n = 0;

	% avalanche statistics
	avalanche_sizes = zeros(1, timesteps);
	av_begin_t = zeros(1,timesteps);
	avalanche_add = zeros(1,timesteps);	% = av_size - av_ltime

	% energy
	ee = zeros(1,timesteps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% show starting field
	if (silent==false) 
		disp('starting from this field:');
		disp(f);
	end

	for t=1:timesteps
		% display time progress
		disp(['time: ' num2str(t) ' / ' num2str(timesteps)]);

		% choose random site
		if (same_place)
			x=floor(width/2);
			y=floor(height/2);
		else
			y=floor(unifrnd(1,height*(1-2*driving_plane_reduction)) + ...
				height*driving_plane_reduction);
			x=floor(unifrnd(1,width*(1-2*driving_plane_reduction)) + ...
				width*driving_plane_reduction);	% uniform distribution rnd
		end

		% place grain
		f(y,x) = f(y,x) + 1;

		% communicate
		if (silent==false) 
			disp(['new grain on x' num2str(x) ',y' num2str(y)]);
		end

		% save picture of field before collapsing (incl. active field)
		if (make_pictures>0)
			draw_field(f,2);
			title(['random grain on x' num2str(x) ',y' num2str(y)]);
			picture_counter=picture_counter+1;
			print(['field' sprintf('%04.0f', picture_counter) '.png'],'-dpng');
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
				if ((x==av_begin_x) && (y==av_begin_y))
					% save # topplings at av starting site
					av_begin_t(t) = av_begin_t(t) + 1;
				end

				% collapse/topple
				f(y,x) = f(y,x) - neighbours * collapse;

				% count future topplings to be caused by this toppling
				future_topplings = 0;

				% look at every neighbour
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
							f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) = ...
								f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) + collapse;

							% push neighbour to stack
							stack_n = stack_n + 1;
							stack_x(stack_n) = x + neighbour_offset_x(n);
							stack_y(stack_n) = y + neighbour_offset_y(n);

							% count future topplings to be caused by this toppling
							if (f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) == (critical_state+1))
								future_topplings = future_topplings + 1;
							end

						% 2) energy loss at boundary (table style)
						elseif (boundary == 2)

							% keep offsets, but check if outside of boundary
							if ((y+neighbour_offset_y(n) < 1) || ...
							   (y+neighbour_offset_y(n) > height) || ...
							   (x+neighbour_offset_x(n) < 1) || ...
							   (x+neighbour_offset_x(n) > width))
								% outside of boundary...do nothing =)
							else
								% add/transport grain to neighbour
								f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) = ...
									f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) + collapse;

								% push neighbour's neighbours to stack
								stack_n = stack_n + 1;
								stack_x(stack_n) = x + neighbour_offset_x(n);
								stack_y(stack_n) = y + neighbour_offset_y(n);

								% count future topplings to be caused by this toppling
								if (f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) == (critical_state+1))
									future_topplings = future_topplings + 1;
								end
							end
						% 3) mixed (1 for x and 2 for y)
						elseif (boundary == 3)

							% for x-direction -> continuous boundary
							if (neighbour_offset_y(n)==0)

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
								f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) = ...
									f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) + collapse;

								% push neighbour to stack
								stack_n = stack_n + 1;
								stack_x(stack_n) = x + neighbour_offset_x(n);
								stack_y(stack_n) = y + neighbour_offset_y(n);

								% count future topplings to be caused by this toppling
								if (f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) == (critical_state+1))
									future_topplings = future_topplings + 1;
								end

							% for y-direction -> open boundary
							else

								% keep offsets, but check if outside of boundary
								if ((y+neighbour_offset_y(n) < 1) || ...
								   (y+neighbour_offset_y(n) > height) || ...
								   (x+neighbour_offset_x(n) < 1) || ...
								   (x+neighbour_offset_x(n) > width))
									% outside of boundary...do nothing =)
								else
									% add/transport grain to neighbour
									f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) = ...
										f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) + collapse;

									% push neighbour's neighbours to stack
									stack_n = stack_n + 1;
									stack_x(stack_n) = x + neighbour_offset_x(n);
									stack_y(stack_n) = y + neighbour_offset_y(n);

									% count future topplings to be caused by this toppling
									if (f(y+neighbour_offset_y(n),x+neighbour_offset_x(n)) == (critical_state+1))
										future_topplings = future_topplings + 1;
									end
								end
							end
						end

					%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				end

				% calculate additional topplings caused
				if (future_topplings > 0)
					avalanche_add(t) = avalanche_add(t) + future_topplings - 1;

					% communicate additional topplings to come
					if (silent==false)
						disp(['this collapse generates ' ...
							num2str(future_topplings - 1) ...
							' additional toppling(s)']);
					end
				else
					% communicate additional topplings to come
					if (silent==false)
						disp(['this collapse generates no additional topplings']);
					end
				end

				% save picture of avalanche timestep
				if (make_pictures>1)
					draw_field(f,2);
					title(['avalanche...']);
					picture_counter=picture_counter+1;
					print(['field' sprintf('%04.0f', picture_counter) '.png'],'-dpng');
				end
		end
	    end

		% display field after collapsing
		if (silent==false)
			disp(f);
			disp('');
		end

		% calculate energy
%		for fx=1:width
%			for fy=1:height
%				ee(t)=ee(t)+f(fy,fx)^2;
%			end
%		end
		ee(t) = sum(sum(f.^2));
	end

	% return avalanche sizes
	as = avalanche_sizes;

	% return number of topplings at avalanche starting site
	nc = av_begin_t;

	% return final state
	final = f;

	% return avalanche lifetimes
	at = avalanche_sizes - avalanche_add;

	% return energy
	energy = ee;
end

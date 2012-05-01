%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sandpile simulation
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parameters
width = 200;		% field size
height = 200;
neighbours = 4;		% neighbours to collapse to
neighbour_offset_x = [-1 +1 0 0];
neighbour_offset_y = [0 0 -1 +1];
critical_state = 3;	% critical/max. number of grains before collapse
collapse = 1;		% number of grains to collapse PER NEIGHBOUR
timesteps = 20000;	% simulation duration in steps (excl. avalanches)
boundary = 2;		% 1 - infinite/continuous, no boundaries, like pac-man
			% 2 - finite field, energy loss at boundaries, like a table
			% 3 - ...

make_pictures = false;	% draw and export all frames or not
silent = true;		% produce no output (except time progress)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define field
f = floor(unifrnd(1,critical_state,height,width)); % this uses uniform distribution of random numbers

% define stack for avalanches
stack_x = 0;
stack_y = 0;
stack_n = 0;

% statistics
avalanche_sizes = zeros(1, timesteps);

for t=1:timesteps
	disp(['time: ' num2str(t) ' / ' num2str(timesteps)]);

	% choose random site
	y=floor(unifrnd(1,height));
	x=floor(unifrnd(1,width));	% this uses uniform distribution of random numbers

	% place grain
	f(y,x) = f(y,x) + 1;

	% save picture
	if (make_pictures)
		draw_field(f,2);
		print(['field' num2str(t) '.png'],'-dpng');
	end

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

		if (silent==false) 
			disp(['x ' num2str(x) '; y ' num2str(y)]);
		end

		% check if overcritical
		if (f(y,x) > critical_state)

			if (silent==false)
				disp('collapse!');
			end
			avalanche_sizes(t) = avalanche_sizes(t) + 1;

			% collapse
			f(y,x) = f(y,x) - neighbours * collapse;

			% check each neighbour
			for n=1:neighbours

				if (silent==false)
					disp(['n ' num2str(n)]);
				end

				% check boundary
				if (boundary == 1)				% no-boundary conditions (pack-man style)
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
				elseif (boundary == 2)				% energy loss at boundary (table style)
					% keep offsets, but check if outside of boundary
					if ((y+neighbour_offset_y(n) < 1) | (y+neighbour_offset_y(n) > height) | (x+neighbour_offset_x(n) < 1) | (x+neighbour_offset_x(n) > width))
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
			end
        end
    end

	if (silent==false)
		disp(f);
		disp('');
	end
end

% analyse avalanche sizes distribution
avalanche_count=zeros(1,max(avalanche_sizes));
for s=1:max(avalanche_sizes)
 avalanche_count(s)=size(avalanche_sizes(avalanche_sizes==s),2)
end
avalanche_sizes
avalanche_count

% plot avalanche count vs size
plot([1:max(avalanche_sizes)],avalanche_count,'marker','s')

% fit the curve into power law distribution (f = c1*x^c2)
xx=[1:max(avalanche_sizes)];
yy=avalanche_count(1:end);
[c,fval,info,output]=fsolve(@(c)((c(1).*xx.^c(2))-yy),[100,1])
hold on;
plot(xx,c(1).*xx.^c(2),'r');




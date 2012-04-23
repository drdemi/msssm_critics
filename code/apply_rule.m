function f = apply_rule (a,c)
% 
% function:	edit field according to a defined rule.
%
% usage:	new_field = apply_rule ( old_field, rule index )
%
% rules:	1 - modulo 2, 4 neighbours, including current field
%		2 - classical sandpile, 4 neighbours with 1 grain each
%


	% get dimensions of field a(width,height)
	width = size(a,2);
	height = size(a,1);

	%copy field
	b = a;

	for x = 2:width-1
		for y = 2:height-1
			if (c==1)
				% count neighbours
				num_neighbours = a(x-1,y)+a(x+1,y)+a(x,y-1)+a(x,y+1)+a(x,y);

				% new value for the cell (mod2 rule)
				b(x,y) = mod(num_neighbours,2);
			elseif (c==2)
				% sandpile rules applied here...
				% ...
			endif
		end
	end

	% return new field
	f = b;
endfunction

function f = draw_field(a,b)
% 
% function:	draw field 
%
% usage:	draw_field ( field, method )
%
% draw methods:	1 - text output
%		2 - circle plot
%

	% copy field
	A = a;

	if (b==1)
		% output using text
		for i=1:size(a,1)
			for j=1:size(a,2)
				if (a(i,j)==0)
					A(i,j)='.'; % empty (zero)
					A(i,j)=48+a(i,j); % numbers 1...9
                end
			end
		end
		clc;
		disp(char(A));

	elseif (b==2)
		% output using circle plot

		% define colors
		clr = ['k' 'r' 'g' 'b'];

		figure;
		hold on;
		h=size(a,1);
		for i=1:size(a,1)
			for j=1:size(a,2)
				if (a(i,j)~=0)
					plot(j,h-i,'color',clr(a(i,j)),'linestyle','none','marker','s','markersize',10)
                end
			end
		end
		hold off;
    end


end

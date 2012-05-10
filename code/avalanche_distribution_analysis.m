function [a,b,a2,b2] = avalanche_distribution_analysis(avalanche_sizes,avalanche_lifetimes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% analysis avalanche distribution and fits it to a power-law
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUTS
%	avalanche_sizes		array of avalanche size for each timestep
%	avalanche_lifetimes	same for av. lifetime

% OUTPUTS
%	a,b			coefficients of power law P(s) = a*s^b
%	a2,b2			coefficients of power law P(t) = a2*t^b2


	% count avalanche sizes/lifetimes
	avalanche_count = zeros(1,max(avalanche_sizes)); % init
	for s=1:max(avalanche_sizes)
		avalanche_count(s) = size(avalanche_sizes(avalanche_sizes==s),2);
	end
	avalanche_count2 = zeros(1,max(avalanche_lifetimes)); % init
	for t=1:max(avalanche_lifetimes)
		avalanche_count2(t) = size(avalanche_lifetimes(avalanche_lifetimes==t),2);
	end

	% non-zero filter
	xx = [1:max(avalanche_sizes)];
	yy = avalanche_count(1:end);
	xx = xx(yy>0);
	yy = yy(yy>0);

	xx2 = [1:max(avalanche_lifetimes)];
	yy2 = avalanche_count2(1:end);
	xx2 = xx2(yy2>0);
	yy2 = yy2(yy2>0);

	% plot avalanche count vs size
	figure;
	subplot(2,2,1);
	plot(xx,yy,'marker','s');

	% fit the curve into power law distribution (f = c1*x^c2)
	[c,fval,info,output]=fsolve(@(c)((c(1).*xx.^c(2))-yy),[100,1]);
	hold on;
	plot(xx,c(1).*xx.^c(2),'r');
	xlabel('avalanche size s');
	ylabel('avalanche count P(s)');
	title(['avalanche distribution and power-law-fit P(s)='	num2str(c(1)) '*s^ ' num2str(c(2))]);

	% same on a log-log-scale plot
	subplot(2,2,2);
	loglog(xx,yy,'marker','s');
	hold on;
	loglog(xx,c(1).*xx.^c(2),'r');
	xlabel('avalanche size s');
	ylabel('avalanche count P(s)');
	title(['avalanche distribution and power-law-fit P(s)='	num2str(c(1)) '*s^ ' num2str(c(2))]);

	% return coefficients
	a = c(1);
	b = c(2);

	% plot avalanche count vs lifetime
	subplot(2,2,3);
	plot(xx2,yy2,'marker','s');

	% fit the curve into power law distribution (f = c1*x^c2)
	[c,fval,info,output]=fsolve(@(c)((c(1).*xx2.^c(2))-yy2),[100,1]);
	hold on;
	plot(xx2,c(1).*xx2.^c(2),'r');
	xlabel('avalanche lifetime t');
	ylabel('avalanche count P(t)');
	title(['avalanche distribution and power-law-fit P(t)='	num2str(c(1)) '*t^ ' num2str(c(2))]);

	% same on a log-log-scale plot
	subplot(2,2,4);
	loglog(xx2,yy2,'marker','s');
	hold on;
	loglog(xx2,c(1).*xx2.^c(2),'r');
	xlabel('avalanche lifetime t');
	ylabel('avalanche count P(s)');
	title(['avalanche distribution and power-law-fit P(t)='	num2str(c(1)) '*t^ ' num2str(c(2))]);

	% return coefficients
	a2 = c(1);
	b2 = c(2);
end

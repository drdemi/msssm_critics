function [a,b] = avalanche_distribution_analysis(avalanche_sizes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% analysis avalanche distribution and fits it to a power-law
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUTS
%	avalanche_sizes		array of avalanche size for each timestep

% OUTPUTS
%	a,b			coefficients of power law P(s) = a*s^b
%


	% count avalanche sizes
	avalanche_count = zeros(1,max(avalanche_sizes)); % init
	for s=1:max(avalanche_sizes)
		avalanche_count(s) = size(avalanche_sizes(avalanche_sizes==s),2);
	end

	% plot avalanche count vs size
	figure;
	subplot(1,2,1);
	plot([1:max(avalanche_sizes)],avalanche_count,'marker','s');

	% fit the curve into power law distribution (f = c1*x^c2)
	xx = [1:max(avalanche_sizes)];
	yy = avalanche_count(1:end);
	[c,fval,info,output]=fsolve(@(c)((c(1).*xx.^c(2))-yy),[100,1]);
	hold on;
	plot(xx,c(1).*xx.^c(2),'r');
	xlabel('avalanche size s');
	ylabel('avalanche count P(s)');
	title(['avalanche distribution and power-law-fit P(s)=' num2str(c(1)) '*s^ ' num2str(c(2))]);

	% same on a log-log-scale plot
	subplot(1,2,2);
	loglog([1:max(avalanche_sizes)],avalanche_count,'marker','s');
	hold on;
	loglog(xx,c(1).*xx.^c(2),'r');
	xlabel('avalanche size s');
	ylabel('avalanche count P(s)');
	title(['avalanche distribution and power-law-fit P(s)=' num2str(c(1)) '*s^ ' num2str(c(2))]);

	% return coefficients
	a = c(1);
	b = c(2);
end

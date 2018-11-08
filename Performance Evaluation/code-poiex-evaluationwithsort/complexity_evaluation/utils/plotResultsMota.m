function plotResultsMota(eval, seqs)
%
% e.g. seqs = [1 2 4 7 9]
%
%

if nargin < 2
    seqs = 1:numel(eval);
end

for i = seqs
    figure(i)
    
    for j = 1:numel(eval(i).MODAK)
    subplot() 
    
    plot()
end


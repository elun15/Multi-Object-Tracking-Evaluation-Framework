function printFrameLevelMetrics(display_string,metrics, metricsInfo, dispHeader,dispMetrics,padChar)
% print metrics
% 
% ...
%

disp(display_string);

% default names
if nargin==2
    metricsInfo.names.long = {'Recall','Precision','GT states','Detections', ...
        'True Positives', 'False Positives', 'False Negatives'};

    metricsInfo.names.short = {'Rcll','Prcn','GT', 'N','TP','FP','FN'};

    metricsInfo.widths.long = [6 9 16 9 14 17 11];
    metricsInfo.widths.short = [5 5 5 5 5 5 5];
    
    metricsInfo.format.long = {'.2f','.2f','i','i','i','i','i'};
    metricsInfo.format.short=metricsInfo.format.long;    
end

namesToDisplay=metricsInfo.names.long;
widthsToDisplay=metricsInfo.widths.long;
formatToDisplay=metricsInfo.format.long;

namesToDisplay=metricsInfo.names.short;
widthsToDisplay=metricsInfo.widths.short;
formatToDisplay=metricsInfo.format.short;

if nargin<4, dispHeader=1; end
if nargin<5
    dispMetrics=1:length(metrics);
end
if nargin<6
    padChar={' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '};
end

if dispHeader
    for m=dispMetrics
        printString=sprintf('fprintf(''%%%is%s'',char(namesToDisplay(m)))',widthsToDisplay(m),char(padChar(m)));
        eval(printString)
    end
    fprintf('\n');
end

for m=dispMetrics
    printString=sprintf('fprintf(''%%%i%s%s'',metrics(m))',widthsToDisplay(m),char(formatToDisplay(m)),char(padChar(m)));
    eval(printString)
end

% if standard, new line
if nargin<5
    fprintf('\n');
end
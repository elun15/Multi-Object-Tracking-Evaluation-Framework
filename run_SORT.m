function [output] = run_SORT(sequence,det)

command_gotodir = 'cd Trackers/SORT/';
command_conda =  'source /home/vpu/anaconda3/bin/activate prueba';
command_tracker = ['python sort.py --input_sequence ' sequence.path ' --detections ' det];


% [status,cmdout] = system(command_conda);
% if status ~= 0
%     setenv('PATH', [getenv('PATH') ':/home/vpu/anaconda3/bin']);
% end


fid=fopen('run_SORT.sh','w');
fprintf(fid, '#!/bin/bash\n');
fprintf(fid, '%s\n',command_gotodir);
fprintf(fid, '%s\n',command_conda);
fprintf(fid, '%s',command_tracker);
fclose(fid);

[status,cmdout] = system('chmod +x run_SORT.sh');
[status,cmdout] = system('bash ./run_SORT.sh');

eval(['output = importdata(fullfile([sequence.results_tracking_paths.' det '],[sequence.name ''.txt'']));']);

end


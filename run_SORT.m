function [output] = run_SORT(sequence,det)

command_gotodir = 'cd Trackers/SORT/';
command_conda =  'source /home/vpu/anaconda3/bin/activate prueba';
command_tracker = ['python sort.py --input_sequence ' sequence.path ' --detections ' det];

fid=fopen('run_SORT.sh','w');
fprintf(fid, '#!/bin/bash\n');
fprintf(fid, '%s\n',command_gotodir);
fprintf(fid, '%s\n',command_conda);
fprintf(fid, '%s',command_tracker);
fclose(fid);

[status,cmdout] = system('chmod +x run_SORT.sh');
[status,cmdout] = system('bash ./run_SORT.sh');

output = importdata(fullfile(sequence.results_tracking_paths,[sequence.name '.txt']));

end


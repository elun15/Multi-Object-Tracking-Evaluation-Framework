function [names,dirs] = get_folders(path)

% This routine get names of folders existing in a directory 
% removing '.'and '..' hidden directories

names_raw = dir(path);
names = {};


counter_aux=1;
for i=1:length(names_raw)
    foldername = names_raw(i).name;
    if ( strcmp(foldername, '.' ) == 0 && strcmp(foldername, '..' ) == 0 && ...
            strcmp(foldername, '.DS_Store' ) == 0 && strcmp(foldername(1), '.')== 0 )
        names{counter_aux} = foldername;
        dirs{counter_aux} =fullfile(path, foldername);
        counter_aux = counter_aux+1;
    end
    
end

end


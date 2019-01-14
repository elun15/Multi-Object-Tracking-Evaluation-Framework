function [names,dirs] = get_folders(path)


names_raw = dir(path);
names = {};
% Remove '.'and '..' hidden directories
counter_aux=1;
for i=1:length(names_raw)
    foldername = names_raw(i).name;
    if ( (strcmp(foldername, '.' ) == 0) && (strcmp(foldername, '..' ) == 0))
        names{counter_aux} = foldername;
        dirs{counter_aux} =fullfile(path, foldername);
        counter_aux = counter_aux+1;
    end
    
end

end


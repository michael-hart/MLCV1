function [ res_path ] = get_res_path()
%GET_RES_PATH Return path to resource folder

% Convert relative path to absolute path
current_path = mfilename('fullpath');
split_path = strsplit(current_path, filesep);
root_path = split_path(1:end-2)';
res_path = cat(1, root_path, 'res');
res_path = strjoin(res_path, filesep);

end
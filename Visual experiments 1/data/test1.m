clc; clear;

file_name = "Dynamic\1_1_dyn.csv";
result_file_name = "1_1_dyn_loaded_raw.mat";

loaded_table = readtable(file_name);

%%%%%%%%%%%%%%%%%%%%%%%%% displaying info about the data
disp('**************** loaded data: ****************')
% table1.Properties.VariableNames'

loaded_table(1:6, :)
%%%%%%%%%%%%%%%%%%%%%%%%%

Count = size(loaded_table, 1) - 4;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load time stamps

loaded_column = loaded_table.Var1;
loaded_key = 'Frame'; % thsi is only for safety check
if strcmp( loaded_column(4), loaded_key)
    ExpData.Index = str2double(loaded_column(5:end));
else
    error(['incorrect loading of data: ', loaded_key])
end


loaded_column = loaded_table.Type;
loaded_key = 'Time (Seconds)'; % thsi is only for safety check
if strcmp( loaded_column(4), loaded_key)
    ExpData.Time = str2double(loaded_column(5:end));
else
    error(['incorrect loading of data: ', loaded_key])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load quaternion of the weight

ExpData.RigidBody.quaternion = zeros(Count, 4); %it should only be done once!
    
loaded_column = loaded_table.RigidBody;
loaded_key1 = 'weight'; % thsi is only for safety check
loaded_key2 = 'Rotation'; % thsi is only for safety check
loaded_key3 = 'X'; % thsi is only for safety check
if strcmp( loaded_column(1), loaded_key1) && ...
   strcmp( loaded_column(3), loaded_key2) && ...   
   strcmp( loaded_column(4), loaded_key3) 
    ExpData.RigidBody.quaternion(:, 1) = str2double(loaded_column(5:end));
else
    error(['incorrect loading of data: ', loaded_key1, '; ', loaded_key2, '; ', loaded_key3])
end

loaded_column = loaded_table.RigidBody_1;
loaded_key1 = 'weight'; % thsi is only for safety check
loaded_key2 = 'Rotation'; % thsi is only for safety check
loaded_key3 = 'Y'; % thsi is only for safety check
if strcmp( loaded_column(1), loaded_key1) && ...
   strcmp( loaded_column(3), loaded_key2) && ...   
   strcmp( loaded_column(4), loaded_key3) 
    ExpData.RigidBody.quaternion(:, 2) = str2double(loaded_column(5:end));
else
    error(['incorrect loading of data: ', loaded_key1, '; ', loaded_key2, '; ', loaded_key3])
end

loaded_column = loaded_table.RigidBody_2;
loaded_key1 = 'weight'; % thsi is only for safety check
loaded_key2 = 'Rotation'; % thsi is only for safety check
loaded_key3 = 'Z'; % thsi is only for safety check
if strcmp( loaded_column(1), loaded_key1) && ...
   strcmp( loaded_column(3), loaded_key2) && ...   
   strcmp( loaded_column(4), loaded_key3) 
    ExpData.RigidBody.quaternion(:, 3) = str2double(loaded_column(5:end));
else
    error(['incorrect loading of data: ', loaded_key1, '; ', loaded_key2, '; ', loaded_key3])
end

loaded_column = loaded_table.RigidBody_3;
loaded_key1 = 'weight'; % thsi is only for safety check
loaded_key2 = 'Rotation'; % thsi is only for safety check
loaded_key3 = 'W'; % thsi is only for safety check
if strcmp( loaded_column(1), loaded_key1) && ...
   strcmp( loaded_column(3), loaded_key2) && ...   
   strcmp( loaded_column(4), loaded_key3) 
    ExpData.RigidBody.quaternion(:, 4) = str2double(loaded_column(5:end));
else
    error(['incorrect loading of data: ', loaded_key1, '; ', loaded_key2, '; ', loaded_key3])
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load position of the weight
ExpData.RigidBody.Position = zeros(Count, 3); %it should only be done once!

loaded_column = loaded_table.RigidBody_4;
loaded_key1 = 'weight'; % thsi is only for safety check
loaded_key2 = 'Position'; % thsi is only for safety check
loaded_key3 = 'X'; % thsi is only for safety check
if strcmp( loaded_column(1), loaded_key1) && ...
   strcmp( loaded_column(3), loaded_key2) && ...   
   strcmp( loaded_column(4), loaded_key3) 
    ExpData.RigidBody.Position(:, 1) = str2double(loaded_column(5:end));
else
    error(['incorrect loading of data: ', loaded_key1, '; ', loaded_key2, '; ', loaded_key3])
end

loaded_column = loaded_table.RigidBody_5;
loaded_key1 = 'weight'; % thsi is only for safety check
loaded_key2 = 'Position'; % thsi is only for safety check
loaded_key3 = 'Y'; % thsi is only for safety check
if strcmp( loaded_column(1), loaded_key1) && ...
   strcmp( loaded_column(3), loaded_key2) && ...   
   strcmp( loaded_column(4), loaded_key3) 
    ExpData.RigidBody.Position(:, 2) = str2double(loaded_column(5:end));
else
    error(['incorrect loading of data: ', loaded_key1, '; ', loaded_key2, '; ', loaded_key3])
end

loaded_column = loaded_table.RigidBody_6;
loaded_key1 = 'weight'; % thsi is only for safety check
loaded_key2 = 'Position'; % thsi is only for safety check
loaded_key3 = 'Z'; % thsi is only for safety check
if strcmp( loaded_column(1), loaded_key1) && ...
   strcmp( loaded_column(3), loaded_key2) && ...   
   strcmp( loaded_column(4), loaded_key3) 
    ExpData.RigidBody.Position(:, 3) = str2double(loaded_column(5:end));
else
    error(['incorrect loading of data: ', loaded_key1, '; ', loaded_key2, '; ', loaded_key3])
end


loaded_table(1:6, 9:end)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load position of markers -  columns 10:end

% MakerNameTemplate = 'Unlabeled';
MakerNameIndex_First = 6;
MakerNameIndex_Last = 19;

loaded_columns = loaded_table(:, 10:51);

for i = MakerNameIndex_First:MakerNameIndex_Last
    loaded_key1 = ['Unlabeled ', num2str(1000 + i)]; % this is only for safety check
    loaded_key2 = 'Position'; % this is only for safety check
    
    marker_cell_index = i - MakerNameIndex_First + 1;
    Maker{marker_cell_index}.val = zeros(Count, 3);
    
    for j = 1:3
        switch j % this is only for safety check
            case 1
                loaded_key3 = 'X';
            case 2
                loaded_key3 = 'Y';
            case 3
                loaded_key3 = 'Z';
            otherwise
                error('switch-case error')
        end
        
        index_local = (i-MakerNameIndex_First)*3 + j;
        index_global = index_local + 10 - 1;
        
        disp(['loading marker: ', loaded_key1, '; ', loaded_key2, '; ', loaded_key3, ...
            '; index_local: ', num2str(index_local), '; index_global: ', num2str(index_global)]);
        %             'table data: ', loaded_columns(1, index_global), ...
        %             ' ', loaded_columns(3, index_global), ...
        %             ' ', loaded_columns(4, index_global), ' ']);
        if strcmp( loaded_columns{1, index_local}, loaded_key1) && ...
                strcmp( loaded_columns{3, index_local}, loaded_key2) && ...
                strcmp( loaded_columns{4, index_local}, loaded_key3)
            
            Maker{marker_cell_index}.val(:, j) = str2double(loaded_columns{5:end, index_local});
         
        else
            error(['incorrect loading of data: ', loaded_key1, '; ', loaded_key2, '; ', loaded_key3])
        end
    end
    
end

ExpData.Maker = Maker;

save(result_file_name, 'ExpData')



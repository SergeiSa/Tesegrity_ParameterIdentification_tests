%close all;

mat_file_name = "Experiment 1\Dynamic\1_1_dyn_loaded_raw.mat";

Data = load(mat_file_name);

N = length(Data.ExpData.Maker);

figure('Color', 'w');

index = 1;
for i = 1:N
    P = Data.ExpData.Maker{i}.val(index, :)';
    
    plot3(P(1), P(2), P(3), 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b', 'MarkerSize', 5); hold on;
    
    text(P(1), P(2), P(3), num2str(i) ,'HorizontalAlignment','left','FontSize',16);
end

grid on; grid minor;
ax = gca;
ax.GridAlpha = 0.6;
ax.LineWidth = 0.5;
ax.MinorGridLineStyle = '-';
ax.MinorGridAlpha = 0.2;
ax.FontName = 'Times New Roman';
ax.FontSize = 14;
xlabel_handle = xlabel('$$x$$, m', 'Interpreter', 'latex');
ylabel_handle = ylabel('$$y$$, m', 'Interpreter', 'latex');
zlabel_handle = zlabel('$$z$$, m', 'Interpreter', 'latex');

axis equal;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%this is written down after looking at the graphical output;
Rods = [3, 5; 9, 10; 1, 12; 2, 13; 6, 14; 7, 8];

for i = 1:size(Rods, 1)
    P1 = Data.ExpData.Maker{Rods(i, 1)}.val(index, :)';
    P2 = Data.ExpData.Maker{Rods(i, 2)}.val(index, :)';
    
    plot3([P1(1), P2(1)], [P1(2), P2(2)], [P1(3), P2(3)], ...
        'LineWidth', 3, 'Color', [0 0.3 0]); hold on;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%this is written down after looking at the graphical output;

%column #1 - node in the regressor; 
%column #2 - node in the data; 
NodeMap = [1, 3; 
           2, 5; 
           3, 9; 
           4, 10; 
           5, 7; 
           6, 8; 
           7, 6; 
           8, 14; 
           9, 1; 
           10, 12; 
           11, 2; 
           12, 13];


ExpData = Data.ExpData;
ExpData.Rods = Rods;
ExpData.NodeMap = NodeMap;

save(mat_file_name, 'ExpData');


mat_file_name = "Regressor\1_1_dyn_loaded_raw.mat";
save(mat_file_name, 'ExpData');



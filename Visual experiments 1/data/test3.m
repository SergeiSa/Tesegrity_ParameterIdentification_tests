close all;

mat_file_name = "Experiment 1\Dynamic\1_1_dyn_loaded_raw.mat";

Data = load(mat_file_name);

N = length(Data.ExpData.Maker);
M = size(Data.ExpData.Rods, 1);
Count = length(Data.ExpData.Time);

figure('Color', 'w');
hP = cell(N, 1); hT = cell(N, 1); hR = cell(M, 1);
init = false;

for index = 1:100:Count
    
%     delete(hP);
%     delete(hR);
%     delete(hT);
    
    for i = 1:N
        P = Data.ExpData.Maker{i}.val(index, :)';
        
        if isempty(hP{i})
            hP{i} = plot3(P(1), P(2), P(3), 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b', 'MarkerSize', 5); hold on;
        else
            hP{i}.XData = P(1);
            hP{i}.YData = P(2);
            hP{i}.ZData = P(3);
        end
        
        if isempty(hT{i})
            hT{i} = text(P(1), P(2), P(3), num2str(i) ,'HorizontalAlignment','left','FontSize',16);
        else
            hT{i}.Position = P;
        end
            
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for i = 1:size(Rods, 1)
        P1 = Data.ExpData.Maker{Data.ExpData.Rods(i, 1)}.val(index, :)';
        P2 = Data.ExpData.Maker{Data.ExpData.Rods(i, 2)}.val(index, :)';
        
        if isempty(hR{i})
            hR{i} = plot3([P1(1), P2(1)], [P1(2), P2(2)], [P1(3), P2(3)], ...
                'LineWidth', 3, 'Color', [0 0.3 0]); hold on;
        else
            hP{i}.XData = [P1(1), P2(1)];
            hP{i}.YData = [P1(2), P2(2)];
            hP{i}.ZData = [P1(3), P2(3)];
        end
    end
    
    if ~init
        grid on;
        %grid minor;
        ax = gca;
        ax.GridAlpha = 0.6;
        ax.LineWidth = 0.5;
        ax.MinorGridLineStyle = '-';
        ax.MinorGridAlpha = 0.2;
        ax.FontName = 'Times New Roman';
        ax.FontSize = 14;
        init = true;
        axis equal;
    end
    
    drawnow;
end

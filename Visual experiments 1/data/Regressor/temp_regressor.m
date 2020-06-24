clc; close all; clear;

robot.RobotName = 'SixBar';

k = 12;

Cables = zeros(k, k);


Cables(1, 5) = 1;
Cables(1, 6) = 1;
Cables(1, 9) = 1;
Cables(1, 11) = 1;

Cables(3, 5) = 1;
Cables(3, 6) = 1;
Cables(3, 10) = 1;
Cables(3, 12) = 1;


Cables(2, 7) = 1;
Cables(2, 8) = 1;
Cables(2, 9) = 1;
Cables(2, 11) = 1;

Cables(4, 7) = 1;
Cables(4, 8) = 1;
Cables(4, 10) = 1;
Cables(4, 12) = 1;


Cables(7, 9) = 1;
Cables(7, 10) = 1;

Cables(5, 9) = 1;
Cables(5, 10) = 1;

Cables(8, 11) = 1;
Cables(8, 12) = 1;

Cables(6, 11) = 1;
Cables(6, 12) = 1;




Cables = Cables + Cables';
if max(Cables(:)) > 1
    error('Something went wrong!')
end


Rods = zeros(k, k);
Rods(1, 2) = 1;
Rods(3, 4) = 1;
Rods(5, 6) = 1;
Rods(7, 8) = 1;
Rods(9, 10) = 1;
Rods(11, 12) = 1;


Rods = Rods + Rods';
if max(Rods(:)) > 1
    error('Something went wrong!')
end


robot.Connectivity = Cables + Rods;
robot.Cables = Cables;
robot.Rods = Rods;

robot.active_nodes = [1:k]';


L_cables = Cables * 0.25;
L_rods = Rods * 0.5;
robot.rest_lengths = L_cables + L_rods;

mu_cables = Cables * 10;
mu_rods = Rods * 100;
% mu_cables = Cables * 500;
% mu_rods = Rods * 2000;
robot.stiffness_coef = mu_cables + mu_rods;


nodes_position1 = [-0.5 -0.5  0.5 0.5;
                    0  0  0  0;
                    -1 1 -1  1];
                
nodes_position2 = [ 0  0  0  0;
                   -1 1 -1  1;
                   -0.5 -0.5  0.5 0.5];
                
nodes_position3 = [-1 1 -1  1;
                   -0.5 -0.5  0.5 0.5;
                    0  0  0  0];                
                
robot.nodes_position  = [nodes_position1, nodes_position2, nodes_position3]*0.5;               

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data = load('1_1_dyn_loaded_raw');

line_from_data_index = 1;
robot.nodes_position = ParameterEstimation_load_experimental_data(robot, data.ExpData, line_from_data_index);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
% find stable IC


% f_array = get_elastic_force_sums_nodes_wrapper1(robot)

% get_potential_energy_fnc_header = ...
%     get_potential_energy_fmincon_wrapper(robot.Connectivity, robot.nodes_position, ...
%                                          robot.stiffness_coef, robot.rest_lengths, robot.active_nodes);
% x = fminunc(get_potential_energy_fnc_header, robot.nodes_position(:, robot.active_nodes));
% 
% robot.nodes_position(:, robot.active_nodes) = x;

save(['data_robot_', robot.RobotName, '.mat'], 'robot')

% disp('finished finding stable position of the structure')


%%

data = load('1_1_dyn_loaded_raw');

RegressorStructure = [];
% RegressorStructure = ParameterEstimation_GenerateRegressor(robot);
if ~isempty(RegressorStructure)
    save('data_RegressorStructure', 'RegressorStructure')
end

if isempty(RegressorStructure)
    temp = load('data_RegressorStructure');
    RegressorStructure = temp.RegressorStructure;
end

disp('generated data experiments:')
ParameterEstimation_EvaluateRegressor(RegressorStructure);

disp('experimental data experiments:')
ParameterEstimation_EvaluateRegressor_experimental(RegressorStructure, data.ExpData)


%%

%%%%%%%%%%%%%%%%%%%
% get parameters
result_mu = optimization_generate_vector(robot.Connectivity, 'mu');
result_rho = optimization_generate_vector(robot.Connectivity, 'rho');

%%%%%%%%%%%%%%%%%%%
% get variables
r = sym('r', [3, 6]);
assume(r, 'real');

f_array = get_elastic_force_sums_nodes(robot.Connectivity, r, ...
                                         robot.stiffness_coef, robot.rest_lengths);
f_array = f_array(:, robot.active_nodes);
f_array = f_array(:);
f_array = simplify(f_array);                                     
matlabFunction(f_array, 'File', 'g_regressor__f_array_true_parameters', 'Vars', {r});
disp('finished generating g_regressor__f_array_true_parameters')
                                     
f_array = get_elastic_force_sums_nodes(robot.Connectivity, r, ...
                                         result_mu.C, result_rho.C);                                     
                                     
f_array = f_array(:, robot.active_nodes);
f_array = f_array(:);
f_array = simplify(f_array);                                     

M = [];
for i = 1:length(f_array)
    [coef_bilinear_mu_rho, coef_linear_mu] = get_regressor_coefficients(f_array(i), result_mu.var, result_rho.var);
    
    M = [M; [coef_bilinear_mu_rho', coef_linear_mu']];
end

matlabFunction(M, 'File', 'g_regressor__regressor', 'Vars', {r});
disp('finished generating g_regressor__regressor')

p = result_mu.var .* result_rho.var;
p = [p; result_mu.var];
matlabFunction(p, 'File', 'g_regressor__true_p', 'Vars', {result_mu.var, result_rho.var});
disp('finished generating g_regressor__true_p')

rehash; 

%%
ind = sub2ind(size(robot.stiffness_coef),result_mu.map(:, 1),result_mu.map(:, 2));
value_mu = robot.stiffness_coef(ind);

ind = sub2ind(size(robot.rest_lengths),result_rho.map(:, 1),result_rho.map(:, 2));
value_rho = robot.rest_lengths(ind);

true_value_p = g_regressor__true_p(value_mu, value_rho);

Count = 100; n = length(robot.active_nodes)*3; 
compundM = zeros(n*Count, length(p)); 
compundLHS = zeros(n*Count, 1); 

for i = 1:Count
r = robot.nodes_position;
r(:, robot.active_nodes) = r(:, robot.active_nodes) + randn(size(robot.nodes_position, 1), length(robot.active_nodes)) * 0.1;

LHS = g_regressor__f_array_true_parameters(r);

M = g_regressor__regressor(r);

index = (i-1)*n+1;
compundM(index:(index+n-1), :) = M;
compundLHS(index:(index+n-1), :) = LHS;
end


estimated_p = pinv(compundM) * compundLHS;

disp(' ');
disp('norm(compundM*estimated_p - compundLHS)')
norm(compundM*estimated_p - compundLHS)

disp('size(compundM)')
size(compundM)

disp('rank(compundM)')
rank(compundM)



%%%%%%%%%%%%%%%%%%%%%%
%% drawing 

p = robot.nodes_position;

figure_handle = figure('Color', 'w');
vis_Draw(robot, robot.nodes_position, 'FaceAlpha', 0.30);

text_delta_x = 0.1;
text_delta_z = 0.1;

for i = 1:size(robot.nodes_position, 2)
    text(p(1, i) + text_delta_x, p(2, i), p(3, i) + text_delta_z, ...
        num2str(i), ...
        'FontName', 'Times New Roman', 'FontSize', 12, 'Color', 'k', 'FontWeight', 'bold');
end

axis equal;

function [coef_bilinear_mu_rho, coef_linear_mu] = get_regressor_coefficients(f, var_mu, var_rho)
J_mu = jacobian(f, var_mu);
Q = jacobian(J_mu, var_rho);
coef_bilinear_mu_rho = diag(Q);
coef_bilinear_mu_rho = simplify(coef_bilinear_mu_rho);

coef_linear_mu = J_mu' - Q*var_rho;
coef_linear_mu = simplify(coef_linear_mu);

% residual = f - ( (var_mu .* var_rho)' * coef_bilinear_mu_rho + coef_linear_mu' * var_mu);
% simplify(residual)
end

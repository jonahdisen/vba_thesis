%-----------------------------------------------------------------------
% validation.m
%
% Description: Report false positives for control subjects, false positives
%   and dice scores for discrete subjects
% Author: Jonah Isen
% Created: April 1st, 2020
% Last Modified: April 14th, 2020
%-----------------------------------------------------------------------

function validation(path, mods, max, threshold)

% Control validation
voxelCounts = zeros(size(mods, 2), 2);
buffer = 1;

for i = 1:max
    for j = 1:size(mods, 2)
        for k = 1:2
            tmap = 'non-existent file';
            if ~any(strcmp({'T1', 'B0'}, char(mods(j))))
                tmap = strcat(path, 'contrast_C', num2str(i, '%03.f'), '_', char(mods(j)), '/spmT_000', num2str(k), '.nii');
            elseif strcmp('T1', char(mods(j)))
                tmap = strcat(path, 'contrast_C', num2str(i, '%03.f'), '_GM/spmT_000', num2str(k), '.nii');
            end
            if exist(tmap, 'file') == 2
                current = niftiread(tmap);
                %Threshold t-maps
                indices = find(current<=threshold);
                current(indices) = 0;
                current = current ~= 0;
                %Summate voxels as false positive counts
                voxelCounts(j, k, buffer) = sum(current, 'all');
                buffer = buffer + 1;
            end
        end
    end
end

if ~exist(strcat(path, 'Threshold_', num2str(threshold), '_Results/Control'), 'dir')
    mkdir(strcat(path, 'Threshold_', num2str(threshold), '_Results/Control'))
end

%Report false positive means and standard deviations in csv files
meanVoxels = mean(voxelCounts, 3);
stdVoxels = std(voxelCounts, [], 3);
headers = {'Decreased T-map','Increased T-map'};
temp = [{' '}, mods];
temp2 = arrayfun(@num2str,meanVoxels,'UniformOutput',false);
temp3 = [headers;temp2].';
temp4 = [temp;temp3].';
writecell(temp4, strcat(path, 'Threshold_', num2str(threshold), '_Results/Control/fp_results_mean.csv'));

temp2 = arrayfun(@num2str,stdVoxels,'UniformOutput',false);
temp3 = [headers;temp2].';
temp4 = [temp;temp3].';
writecell(temp4, strcat(path, 'Threshold_', num2str(threshold), '_Results/Control/fp_results_stdev.csv'));


% Discrete validation

if ~exist(strcat(path, 'Threshold_', num2str(threshold), '_Results/Discrete'), 'dir')
    mkdir(strcat(path, 'Threshold_', num2str(threshold), '_Results/Discrete'))
end

buffer2 = 1;
allScores = [];
falsePositives = zeros(size(mods, 2) + 1, 2);

for i = 1:max
    dices = {};
    buffer = 1;
    makeFile = false;
    for j = 1:size(mods, 2)
        for k = 1:2
            tmap = 'non-existent file';
            if ~any(strcmp({'T1', 'B0'}, char(mods(j))))
                tmap = strcat(path, 'contrast_D', num2str(i, '%03.f'), '_', char(mods(j)), '/spmT_000', num2str(k), '.nii');
            elseif strcmp('T1', char(mods(j)))
                tmap = strcat(path, 'contrast_D', num2str(i, '%03.f'), '_GM/spmT_000', num2str(k), '.nii');
            end
            if exist(tmap, 'file') == 2
                lesion = strcat(path, 'wD', num2str(i, '%03.f'), '_Lesion.nii');
                if exist(lesion, 'file') == 2
                    current = niftiread(tmap);
                    indices = find(current<=threshold);
                    current(indices) = 0;
                    current = current ~= 0;
                
                    lesionMask = niftiread(lesion);
                    lesionMask = lesionMask ~= 0;
                    overlap = current.*lesionMask;
                    overlapCount = sum(overlap, 'all');
                    lesionCount = sum(lesionMask, 'all');
                    currentCount = sum(current, 'all');
                    
                    %Calculate dice score
                    dice = (2*overlapCount) / (lesionCount + currentCount);

                    if j < (size(mods, 2) + 1)
                        if k == 1
                            direction = '>';
                        else
                            direction = '<';
                        end
                        mod = strcat('Controls_', char(mods(j)), direction, 'Subject_', char(mods(j)));
                    else
                        mod = strcat('Controls_GM', direction, 'Subject_GM');
                    end
                    dices{1, buffer} = mod;
                    dices{2, buffer} = dice;
                    buffer = buffer + 1;
                    makeFile = true;
                    
                    %Calculate false positives
                    falsePositives(j, k, buffer2) = currentCount - overlapCount;
                end
            end
        end
    end
    if makeFile
        diceMods = dices(1, :);
        allScores(buffer2, :) = cell2mat(dices(2, :));
        buffer2 = buffer2 + 1;
        %Report per subject dice scores
        writecell(dices.', strcat(path, 'Threshold_', num2str(threshold), '_Results/Discrete/', 'D', num2str(i, '%03.f'), '_results.csv'));
    end
end

%Report mean and standard deviation of dice scores
meanDice = mean(allScores, 1);
stdevDice = std(allScores, 0, 1);

temp = arrayfun(@num2str,meanDice,'UniformOutput',false);
temp2 = [diceMods;temp].';
writecell(temp2, strcat(path, 'Threshold_', num2str(threshold), '_Results/Discrete/dice_results_mean.csv'));


temp = arrayfun(@num2str,stdevDice,'UniformOutput',false);
temp2 = [diceMods;temp].';
writecell(temp2, strcat(path, 'Threshold_', num2str(threshold), '_Results/Discrete/dice_results_stdev.csv'));

meanfp = mean(falsePositives, 3);
stdfp = std(falsePositives, [], 3);

temp = [{' '}, mods, {'GM'}];
temp2 = arrayfun(@num2str,meanfp,'UniformOutput',false);
temp3 = [headers;temp2].';
temp4 = [temp;temp3].';
writecell(temp4, strcat(path, 'Threshold_', num2str(threshold), '_Results/Discrete/fp_results_mean.csv'));

temp2 = arrayfun(@num2str,stdfp,'UniformOutput',false);
temp3 = [headers;temp2].';
temp4 = [temp;temp3].';
writecell(temp4, strcat(path, 'Threshold_', num2str(threshold), '_Results/Discrete/fp_results_stdev.csv'));

%Draw box plot of dice scores
figure
boxplot(allScores,'labels',diceMods)
title(strcat('Variuos Discrete Subject Modality Dice Scores with Threshold = ', num2str(threshold)))

end
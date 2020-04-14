%-----------------------------------------------------------------------
% analysis.m
%
% Description: Statistical analysis of pre-processed multimodal MRI data
% Author: Jonah Isen
% Created: March 24th, 2020
% Last Modified: April 14th, 2020
%-----------------------------------------------------------------------

function analysis(path, mods, max)

disp('Performing statistical analysis on discrete and negative subjects');

for group = ['D' 'N']
    for i = 1:max
        for j = 1:size(mods, 2)
            controls = {};
            buffer = 1;
            %Build array of paths to controls scans for a given modality 
            for k = 1:max
                if ~strcmp('T1', char(mods(j)))
                    control = strcat(path, 'swrC', num2str(k, '%03.f'), '_', char(mods(j)), '.nii');
                else
                    control = strcat(path, 'swc1C', num2str(k, '%03.f'), '_T1.nii');
                end
                if exist(control, 'file') == 2
                    controls{buffer} = control;
                    buffer = buffer + 1;
                end
            end
            if ~strcmp('T1', char(mods(j)))
                current = strcat(path, 'swr', group, num2str(i, '%03.f'), '_', char(mods(j)), '.nii');
            else
                current = strcat(path, 'swc1', group, num2str(i, '%03.f'), '_T1.nii');
            end
            %Perform t-test
            if exist(current, 'file') == 2 && ~strcmp(current, strcat(path, 'swr', group, num2str(i, '%03.f'), '_DTI_B0.nii'))
                mask = strcat(path, group, num2str(i, '%03.f'), '_mask.nii');
                if ~strcmp('T1', char(mods(j)))
                    matlabbatch{1}.spm.stats.factorial_design.dir = {strcat(path, 'contrast_', group, num2str(i, '%03.f'), '_', char(mods(j)))};
                else
                    matlabbatch{1}.spm.stats.factorial_design.dir = {strcat(path, 'contrast_', group, num2str(i, '%03.f'), '_GM')};
                end
                matlabbatch{1}.spm.stats.factorial_design.masking.em = {mask};
                matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = controls.';
                matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = {current};
                matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
                matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
                matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
                matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
                matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
                matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
                matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
                matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
                matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
                matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
                matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
                matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
                matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
                matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
                matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = strcat('control>', group, num2str(i, '%03.f'));
                matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
                matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
                matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = strcat('control<', group, num2str(i, '%03.f'));
                matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
                matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
                matlabbatch{3}.spm.stats.con.delete = 0;
                spm_jobman('run',matlabbatch);
            end
            
        end
    end
end


disp('Performing leave-one-out control analysis');

%Leave one out control analysis
for i = 1:size(mods, 2)
    controls = {};
    buffer = 1;
    %?Build array of control scans for a given modality
    for j = 1:max
        if ~strcmp('T1', char(mods(i)))
            control = strcat(path, 'swrC', num2str(j, '%03.f'), '_', char(mods(i)), '.nii');
        else
            control = strcat(path, 'swc1C', num2str(j, '%03.f'), '_T1.nii');
        end
        if exist(control, 'file') == 2
            controls{buffer} = control;
            buffer = buffer + 1;
        end
    end
    %Iterate through control subjects
    for k = 1:size(controls, 2)
        
        %Remove current subject from controls array
        temp = controls;
        current = temp{k};
        temp(k) = [];
        pathSize = size(path, 2);
        if ~strcmp('T1', char(mods(i)))
            subj = current(pathSize+4:pathSize+7);
        else
            subj = current(pathSize+5:pathSize+8);
        end
        %Perform t-test
        if exist(current, 'file') == 2 && ~strcmp(current, strcat(path, 'swr', subj, '_DTI_B0.nii'))
            mask = strcat(path, subj, '_mask.nii');
            if i < (size(mods, 2) + 1)
                matlabbatch{1}.spm.stats.factorial_design.dir = {strcat(path, 'contrast_', subj, '_', char(mods(i)))};
            else
                matlabbatch{1}.spm.stats.factorial_design.dir = {strcat(path, 'contrast_', subj, '_GM')};
            end
            matlabbatch{1}.spm.stats.factorial_design.masking.em = {mask};
            matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = temp.';
            matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = {current};
            matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
            matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
            matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
            matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
            matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
            matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
            matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
            matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
            matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
            matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
            matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = strcat('control>', subj);
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = strcat('control<', subj);
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
            matlabbatch{3}.spm.stats.con.delete = 0;
            spm_jobman('run',matlabbatch);
        end
    end
end

end

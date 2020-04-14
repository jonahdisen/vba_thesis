%-----------------------------------------------------------------------
% segment.m
%
% Description: Coregisters all modalities to that subjects T1
% Author: Jonah Isen
% Created: February 11th, 2020
% Last Modified: April 14th, 2020
%-----------------------------------------------------------------------

function coreg(path, mods, max)

disp('Coregistering other modalities to T1');

diffusion_mods = {'DTI_MD', 'DTI_FA', 'NODDI_ficvf', 'NODDI_odi'}; %Dont need to directly coregister these modalities, warps applied from B0 coregister

%Perform coregistering to T1 for each subject until max for each modality
batchBuffer = 0;
for group = ['C' 'D' 'N']
    for i = 1:max
        t1 = strcat(path, group, num2str(i, '%03.f'), '_T1.nii');
        b0 = strcat(path, group, num2str(i, '%03.f'), '_DTI_B0.nii');
        if exist(t1, 'file') == 2 && exist(b0, 'file') == 2
            batchBuffer = batchBuffer + 1;
            others = {};
            buffer = 1;
            for j = 1:size(mods, 2)
                temp = 'non-existent file';
                if ~any(strcmp({'T1', 'B0'}, char(mods(j))))
                    temp = strcat(path, group, num2str(i, '%03.f'), '_', char(mods(j)), '.nii');
                end
                if exist(temp, 'file') == 2
                    others{buffer} = temp;
                    buffer = buffer + 1;
                end
            end
            matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.ref = {t1};
            matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.source = {b0};
            matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.other = others.';
            matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
            matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
            matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
            matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.roptions.interp = 4;
            matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
            matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.roptions.mask = 0;
            matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
        end
    end
end

%Run coregistration
if batchBuffer > 0
    spm_jobman('run',matlabbatch);
end

end

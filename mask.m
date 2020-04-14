%-----------------------------------------------------------------------
% mask.m
%
% Description: Create a brain mask for each subject using normalized GM and
%   WM
% Author: Jonah Isen
% Created: March 5th, 2020
% Last Modified: April 14th, 2020
%-----------------------------------------------------------------------

function mask(path, max)

disp('Creating brain masks');

batchBuffer = 0;
for group = ['C' 'D' 'N']
    for i = 1:max
        %Use normalized GM and WM to make brain mask
        gm = strcat(path, 'swc1', group, num2str(i, '%03.f'), '_T1.nii');
        wm = strcat(path, 'swc2', group, num2str(i, '%03.f'), '_T1.nii');
        if exist(gm, 'file') == 2 && exist(wm, 'file') == 2
            batchBuffer = batchBuffer + 1;
            matlabbatch{batchBuffer}.spm.util.imcalc.input = {gm 
                                                    wm};
            matlabbatch{batchBuffer}.spm.util.imcalc.output = strcat(path, group, num2str(i, '%03.f'), '_mask.nii');
            matlabbatch{batchBuffer}.spm.util.imcalc.outdir = {path};
           
            %Filter out non-brain regions below 0.5
            matlabbatch{batchBuffer}.spm.util.imcalc.expression = '(i1+i2)>0.5';
            matlabbatch{batchBuffer}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{batchBuffer}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{batchBuffer}.spm.util.imcalc.options.mask = 0;
            matlabbatch{batchBuffer}.spm.util.imcalc.options.interp = 1;
            matlabbatch{batchBuffer}.spm.util.imcalc.options.dtype = 4;
        end
    end
end

spm_jobman('run',matlabbatch);

end
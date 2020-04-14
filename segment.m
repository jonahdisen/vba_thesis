%-----------------------------------------------------------------------
% segment.m
%
% Description: Segments T1 scans into grey matter and white matter
% Author: Jonah Isen
% Created: February 26th, 2020
% Last Modified: April 14th, 2020
%-----------------------------------------------------------------------

function segment(path, max)

disp('Segmenting T1 scans');

t1s = {};
buffer = 1;

%Create cell array of paths to T1 scans from C, D and N groups up until max
for group = ['C' 'D' 'N']
    for i = 1:max
        t1 = strcat(path, group, num2str(i, '%03.f'), '_T1.nii');
        if size(dir(t1),1) == 1
            t1s{buffer} = t1;
            buffer = buffer + 1;
        end
    end
end

%Perform SPM12's Segment
matlabbatch{1}.spm.spatial.preproc.channel.vols = cellstr(t1s.');
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'/Users/jonahisen1/Documents/MATLAB/spm12/tpm/TPM.nii,1'}; %Need to change path to TPM
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'/Users/jonahisen1/Documents/MATLAB/spm12/tpm/TPM.nii,2'}; %Need to change path to TPM
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'/Users/jonahisen1/Documents/MATLAB/spm12/tpm/TPM.nii,3'}; %Need to change path to TPM
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'/Users/jonahisen1/Documents/MATLAB/spm12/tpm/TPM.nii,4'}; %Need to change path to TPM
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'/Users/jonahisen1/Documents/MATLAB/spm12/tpm/TPM.nii,5'}; %Need to change path to TPM
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'/Users/jonahisen1/Documents/MATLAB/spm12/tpm/TPM.nii,6'}; %Need to change path to TPM
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];
spm_jobman('run', matlabbatch);

end
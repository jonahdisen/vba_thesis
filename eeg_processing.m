%-----------------------------------------------------------------------
% eeg_processing.m
%
% Description: Pre-process EEG gold standard data to MNI space
% Author: Jonah Isen
% Created: April 1st, 2020
% Last Modified: April 14th, 2020
%-----------------------------------------------------------------------

function eeg_processing(path, max)

disp('Pre-processing EEG data');

batchBuffer = 0;

%coregister EEG data to T1
for i = 1:max
    t1 = strcat(path, 'N', num2str(i, '%03.f'), '_icEEG_T1.nii');
    refT1 = strcat(path, 'N', num2str(i, '%03.f'), '_T1.nii');
    disp(t1)
    disp(refT1)
    %Coregister the EEG data that exists for each negative subjects
    if exist(t1, 'file') == 2 && exist(refT1, 'file') == 2
        batchBuffer = batchBuffer + 1;
        others = {};
        buffer = 1;
        ied = strcat(path, 'N', num2str(i, '%03.f'), '_icEEG_IED.nii');
        if exist(ied, 'file') == 2
            others{buffer} = ied;
            buffer = buffer + 1;
        end
        soz = strcat(path, 'N', num2str(i, '%03.f'), '_icEEG_SOZ.nii');
        if exist(soz, 'file') == 2
            others{buffer} = soz;
            buffer = buffer + 1;
        end
        spread = strcat(path, 'N', num2str(i, '%03.f'), '_icEEG_Spread.nii');
        if exist(spread, 'file') == 2
            others{buffer} = spread;
        end
        matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.ref = {refT1};
        matlabbatch{batchBuffer}.spm.spatial.coreg.estwrite.source = {t1};
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

spm_jobman('run',matlabbatch)
clear matlabbatch;

%Template generated from DARTEL normalization
final_template = strcat(path, 'Template_6.nii');

batchBuffer = 0;

%Normalize EEG data
for i = 1:max
    images = {};
    buffer = 1;
    t1 = strcat(path, 'rN', num2str(i, '%03.f'), '_icEEG_T1.nii');
    if exist(t1, 'file') == 2
        images{buffer} = {t1};
        buffer = buffer + 1;
        ied = strcat(path, 'rN', num2str(i, '%03.f'), '_icEEG_IED.nii');
        if exist(ied, 'file') == 2
            images{buffer} = {ied};
            buffer = buffer + 1;
        end
        soz = strcat(path, 'rN', num2str(i, '%03.f'), '_icEEG_SOZ.nii');
        if exist(soz, 'file') == 2
            images{buffer} = {soz};
            buffer = buffer + 1;
        end
        spread = strcat(path, 'rN', num2str(i, '%03.f'), '_icEEG_Spread.nii');
        if exist(spread, 'file') == 2
            images{buffer} = {spread};
        end
        flowfield = strcat(path, 'u_rc1N', num2str(i, '%03.f'), '_T1_Template.nii');
        if exist(flowfield, 'file') == 2
            batchBuffer = batchBuffer + 1;
            
            matlabbatch{batchBuffer}.spm.tools.dartel.mni_norm.template = {final_template};
            matlabbatch{batchBuffer}.spm.tools.dartel.mni_norm.data.subjs.flowfields = {flowfield};
            matlabbatch{batchBuffer}.spm.tools.dartel.mni_norm.data.subjs.images = images.';
            matlabbatch{batchBuffer}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
            matlabbatch{batchBuffer}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                                           NaN NaN NaN];
            matlabbatch{batchBuffer}.spm.tools.dartel.mni_norm.preserve = 0;
            matlabbatch{batchBuffer}.spm.tools.dartel.mni_norm.fwhm = [0 0 0];
        end
    end
end

if batchBuffer > 0
    spm_jobman('run',matlabbatch);
end

end


    
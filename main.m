%-----------------------------------------------------------------------
% main.m
%
% Description: main.m runs all data processing steps
% Author: Jonah Isen
% Created: February 11th, 2020
% Last Modified: April 14th, 2020
%-----------------------------------------------------------------------

path = '/Volumes/My Passport/data/'; %Path to multimodal MRI data
modalities = {'T1', 'DTI_BO', 'DTI_FA', 'DTI_MD', 'NODDI_ficvf', 'NODDI_odi'}; %Array of modalities used in analysis
maxSubjects = 70; %Performs analysis for subjects up until maxSubjects, can decrease for testing on subset of data

preProcessing = true; %Perform pre-processing steps
statisticalAnalysis = true; %Perform statistical analysis

if preProcessing
    segment(path, maxSubjects);
    coreg(path, modalities, maxSubjects);
    normalize(path, modalities, maxSubjects);
    mask(path, maxSubjects);
    eeg_processing(path, maxSubjects);
end

if statisticalAnalysis
    analysis(path, modalities, maxSubjects);
    for i = 4:12
        disp( sprintf( 'Calculating results with threshold = %1.1f', i*0.5 ) );
        validation(path, modalities, maxSubjects, i*0.5);
    end
end
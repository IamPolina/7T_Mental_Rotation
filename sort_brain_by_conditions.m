function sort_brain_by_conditions(V)
% This script organizes the functional data in a matrix with the following dimensions:
% Mtest{cortical layers(1:3)}(orientation(1:3), rotation(1:2),
% session(1:6), trial(1:6), values(=Nvox in ROI)) - this matrix comprises
% experimental runs, sorted by condition and trial time points.
% Mtrain{cortical layers(1:3)}(orientation(1:3), trials(1:15), values(=Nvox
% in ROI)) - this matrix comprises perceptual data

['1. set up directories']
% set path to the subjects folder
sdir = pwd; 
% set path to the analysis folder
adir = fullfile(pwd, 'decoding_script');
addpath(adir)

%% Parameters
Nori = 3; 
Ntpoints = 6;
Nlay = 3;
Ntrspertrial = 6;    
O = [15,75,135];
Dummytime = 1; % first scan is a dummy scan

for subn = [18]
  ['subject: '  num2str(subn)]
  tic    
  if exist(fullfile(sdir, ['sub' num2str(subn, '%02d') '.zip']))
       unzip(fullfile(sdir, ['sub' num2str(subn, '%02d') '.zip']))
  end
  subdir = fullfile(sdir, ['sub' num2str(subn, '%02d')]);


    ['2.  load ROI']
    for a = 1:numel({V})
        if ~exist(fullfile(sdir, ['sub' num2str(subn, '%02d')], 'anat', [V '_0_3.nii']))
                gunzip(fullfile(sdir, ['sub' num2str(subn, '%02d')], 'anat', [V '_0_3.nii.gz']))
        end 
        roi_name = fullfile(sdir, ['sub' num2str(subn, '%02d')], 'anat', [V '_0_3.nii']);
        rfile01 = spm_vol(roi_name); rfile02 = spm_read_vols(rfile01); rfile = rfile02(:);
        clear rfile01 rfile02
        % make a matrix out of depth bins (3)
        for l = 1:Nlay
             laymult(l, :) = (rfile==l);
        end


        ['3.  load timings from presentation logs']
        if exist(fullfile(subdir, 'beh', 'behavioral_log.mat.gz'))
                gunzip(fullfile(subdir, 'beh', 'behavioral_log.mat.gz'))
        end
        load(fullfile(subdir, 'beh', 'behavioral_log.mat'));
        
        if ~exist(fullfile(sdir, 'results', 'experiment', ['subn' num2str(subn, '%02d') '.mat']))
        for r = 1:numel(Presented)

            ['4. Run: ' num2str(r) '. prepare indices to load EPI data']
            % recode orientations in the behav file and expand by the
            % number of TRs per run
            Perorder = floor(sqrt(Presented{r}/O(1))); Perorder = (repmat(Perorder', 1, Ntrspertrial))';
            Rotorder = floor(sqrt(Rotated{r}/O(1))); Rotorder = (repmat(Rotorder', 1, Ntrspertrial))';
            Mcond = [ Perorder(:) Rotorder(:)]; % matrix with presented and rotated ori per run
            % all combinations of  rotated orientations in the trial when orientations
            % 1,2,3 were presented.
            all_combs = [{[2,3]}, {[1,3]}, {[1,2]}];
            for o = 1:Nori
                for c = 1:numel(all_combs{o})
                    % order trials by conditions: 
                    % (presented 1, rotated 2)
                    % (presented 1, rotated 3)
                    % (presented 2, rotated 1)
                    % (presented 2, rotated 3)
                    % (presented 3, rotated 1)
                    % (presented 3, rotated 2)
                    temp{c} = reshape(find(Mcond(:,1)==o & Mcond(:,2)==all_combs{o}(c)), [6,6]); %  time points by trials
                end
                % get indices for conditions
                R_ind{o} = cat(2, temp{:})';
                clear temp
            end
            clear Mcond


            ['5. Run: ' num2str(r) '. sort epi data by trials, time points and cortical depth']

            if exist(fullfile(subdir, 'func', [ 'sub' num2str(subn, '%02d') '_run' num2str(r, '%02d') '.nii.gz']))
                    gunzip(fullfile(subdir, 'func', [ 'sub' num2str(subn, '%02d') '_run' num2str(r, '%02d') '.nii.gz']))
            end
            niftidir = fullfile(subdir, 'func', [ 'sub' num2str(subn, '%02d') '_run' num2str(r, '%02d') '.nii']);
            Mepifolder = spm_select('expand', (niftidir));
            for f = 1:size(Mepifolder,1)
                Mepistr = spm_vol(Mepifolder(f,:));
                Mepi(f,:,:,:) = spm_read_vols(Mepistr);
            end
            for  l =1:Nlay
                for o = (1:Nori) 
                     for trial = 1:size(R_ind{o},1) % trials per condition = 6
                          for tp = 1:Ntpoints
                                  vols =  Mepi(R_ind{o}(trial, tp)+Dummytime,:,:,:); % start from the second TR, the first is a dummy scan
                                  vols = vols(:,laymult(l,:)); % voxels at the specified  cortical depth                      
                                  %Dimension of lbfiles matrix: 
                                  % {ROI, depth}(3 stimuli, 6 runs, 12 trials, 6 tpoints, voxels)
                                  lbfiles{a,l}(o,r,trial,tp,:) =  vols; 
                                  clear vols
                          end
                      end
                  end 
                end
            clear R_ind clear 
          end
          clear Mepi

            ['6. save sorted experiment data']
            resdir = fullfile(sdir, 'sorted_data', 'experiment');
            if ~exist(resdir)
                mkdir(resdir)
            end
            save(fullfile(resdir, ['subn' num2str(subn, '%02d') '.mat']), 'lbfiles')
            clear lbfiles niftidir
        else
            ['skip loading and sorting experiment data']
        end


%         Localizer = Localizer{:}; Localizer = reshape(repmat(Localizer, 1,6)', [3,6,15]);
%         Localizer = [Localizer zeros(15, 7)];
%         Localizer = Localizer(:);
%         Mcond = floor(sqrt(Localizer/O(1))); 
        ['7. prepare trial and time point indices for localizer data']
        %% Parameters
        Ntrials = 15; 
        Oriprestime = 12; % 12 seconds for the flicker of every grating
        Trialtime = 51; % 12*3 + 15 seconds of blank screen after the flicker of three gratings
        
        if subn==24
            runstart = round(((1+Dummytime):Trialtime:Trialtime*(Ntrials-3))/2);
        else
            runstart = round(((1+Dummytime):Trialtime:Trialtime*Ntrials)/2);
        end
        % prepare for loading the perception EPI data
        trialstartP = ((1+Dummytime):Oriprestime:(Oriprestime*Nori))/2;
        TRstartP = repmat(runstart,3,1) + trialstartP';
        for ori = 1:3
            OrnP(:,ori) = sort(nonzeros(TRstartP'.*(Localizer{1}==O(ori))));
        end
        if subn==3
            OrnP=OrnP(1:end-1,:);
        end
        % load localizer EPI data 
        if exist(fullfile(subdir, 'func',[ 'sub' num2str(subn, '%02d')  '_run' num2str(7, '%02d') '.nii.gz']))
                gunzip(fullfile(subdir, 'func',[ 'sub' num2str(subn, '%02d') '_run' num2str(7, '%02d') '.nii.gz']))
        end
        niftidir = fullfile(subdir, 'func',[ 'sub' num2str(subn, '%02d')  '_run' num2str(7, '%02d') '.nii']);
        Mepifolder = spm_select('expand', (niftidir));


        ['8. Localizer run: sort localizer data by trials, time points and cortical depth']
        for ori = 1:Nori
            for trial = 1:numel(squeeze(OrnP(:,ori)))
                for tp = 0:Ntpoints-1
                        pbfiles1 = spm_vol(fullfile(Mepifolder(OrnP(trial,ori) + tp, :)));
                        temp = spm_read_vols(pbfiles1);
                        for l = 1:Nlay
                            pbfiles{a,l}(ori,trial,tp+1,:) = temp(laymult(l,:));
                        end
                       clear temp pbfiles1
                end
            end
        end
    end

    ['9. Localizer run: save sorted data']
    resdir = fullfile(sdir, 'sorted_data', 'localizer');
    if ~exist(resdir)
        mkdir(resdir)
    end
    save(fullfile(resdir, ['subn' num2str(subn, '%02d') '.mat']), 'pbfiles')
    clear pbfiles niftidir
    
                     
end
toc

function [P,R,N]=decoding_raw
%% EXPLANATION


%addpath(genpath('/spm12'))
%addpath(genpath('/libsvm-3.11/matlab'))

%% Parameters
Nori = 3; 
Ntpoints = 6;
Nlay = 3;
Ntrspertrial = 6;    
O = [15,75,135];
subs = [1,3,24];
for subn =1:numel(subs)
    ['subject: ' num2str(subn)]   
    [ '1. load experimental and localizer data']

    expsorteddir = fullfile(pwd, 'sorted_data', 'experiment');
    load(fullfile(expsorteddir, ['subn' num2str(subs(subn),'%02d') '.mat']))
    locsorteddir = fullfile(pwd, 'sorted_data', 'localizer');
    load(fullfile(locsorteddir, ['subn' num2str(subs(subn),'%02d') '.mat']))
    
    ['2. decoding in progress']
    percmat = ([ones(1,12)*(Nori-2), ones(1,12)*(Nori-1), ones(1,12)*Nori])';
    rotmat = ([ones(1,6)*2, ones(1,6)*3 ones(1,6), ones(1,6)*3,ones(1,6), ones(1,6)*2])';
    notpmat = ([ones(1,6)*3, ones(1,6)*2, ones(1,6)*3, ones(1,6),ones(1,6)*2, ones(1,6)])';
    
       for tp = 1:(Ntpoints-1) % the last time point is iti and is not used in decoding
             for r = 1:size(lbfiles{1},2) %runs
                   for l = 1:Nlay % cortical depth 
                            ['2.1 training']
                            training_data=[squeeze(pbfiles{l}(1,:, tp,:)) ; ...
                                                  squeeze(pbfiles{l}(2, :, tp,:)); ...
                                                  squeeze(pbfiles{l}(3, :, tp,:))];

                            labels_train=[ones(1,size(pbfiles{1},2)) ...
                                                2*ones(1,size(pbfiles{1},2)) ...
                                                3*ones(1,size(pbfiles{1},2))];
                            modelsvm = svmtrain(labels_train', training_data,'-s 0 -t 0 -q');
                            
                            ['2.2 testing']
                            testing_data=[squeeze(lbfiles{l}(1,r,:,tp,:)) ; ...
                                                 squeeze(lbfiles{l}(2,r,:,tp,:)); ...
                                                 squeeze(lbfiles{l}(3,r,:,tp,:))];
                                             
                            labels_test= [ones(1,12) ones(1,12)*2 ones(1,12)*3];
                            [predicted_label, accuracy, decision_values] = svmpredict(labels_test', testing_data , modelsvm);
                           
                            %Acc(find(subtotal==subn), find(nvox==voxels), l, tp, sess) = accuracy(1);
                            P{subn}(l, tp, r) = mean(predicted_label==percmat);
                            R{subn}(l, tp, r) = mean(predicted_label==rotmat);
                            N{subn}(l, tp, r) = mean(predicted_label==notpmat);
                   end
             end
        end 
    clearvars -except P R N Varea subs Nori Ntpoints Nlay
end


function plot_main_7T_IM(P,R,N,V)  
% Example calling of the script:  plot_main_7T_IM(P,R,N) 
% inputs are the proportions of predicted labels for
% presented, rotated and not shown grating 
%for each depth, time point and run. 

%Parameters
testtp = [4:5]; % at which time points the effect is estimated
counter=0;

for subn = 1:numel(P)
    counter=counter+1;
    % cut off the last time point and average trial decoding
    res{1}(counter,:,:)= mean(P{subn},3); 
    res{2}(counter,:,:)= mean(R{subn},3);
    res{3}(counter,:,:)= mean(N{subn},3);
end

%% define combined depth vars

ffds = (squeeze(mean(res{1}(:,1,testtp),3)) + squeeze(mean(res{1}(:,3,testtp),3)))/2;% feedforward deep superficial
fbds = (squeeze(mean(res{2}(:,1,testtp),3)) + squeeze(mean(res{2}(:,3,testtp),3)))/2;% feedback deep superficial
fnods3 = (squeeze(mean(res{3}(:,1,testtp),3)) + squeeze(mean(res{3}(:,3,testtp),3)))/2;% feedback deep superficial for not shown

%% Plot

clear h
clear p
interval = [0.3 0.6 0.9];
interval2 = [1.35 1.65];
dotsize = 2;
figure(81)
%% plot 5
for n = 1:3
    if n==1
        color = [0.4490 0.7608 0];
        delta = [0,0,0];
        w=3;
        s='-';
    elseif n==2
        color = [0.5000 0.3892 0.8098];
        delta = [0.1,0.1,0.1];
        w=3;
        s='-';
    elseif n==3
        color = [0.5000 0.5 0.5];
        delta = [0.05,0.05,0.05];
        w=2;
        s='--';
    end
       errorbar([interval]+delta, mean(squeeze(mean(res{n}(:,1:3,testtp),3))), ...
        std(squeeze(mean(res{n}(:,1:3,testtp),3)))/sqrt(size(res{n},1)), ...
        'Linewidth', w, 'Color', color, 'LineStyle', s,...
          'Marker'          , 'o'         , ...
        'MarkerSize'      , 10           , ...
        'MarkerEdgeColor' , 'none'      , ...
        'MarkerFaceColor' , color ); hold on;
        hold on
        
        X = repmat([interval]+delta, [size(res{1},1),1]);
        X = X +  (rand(size(X,1),size(X,2))-1/2)/65;
        for l = 1:3
            scatter(X(:,l), ...
                    squeeze(mean(res{n}(:,l,testtp),3)), ...
                    dotsize, color, 'filled')
            hold on
        end
    for l = 1:3
      [h(l,:),p(n,l,:),~ ,stats(n,l,:)]  = ttest(squeeze(mean(res{n}(:,l,testtp),3)),...
                                                             squeeze(mean(res{3}(:,l,testtp),3)), 'Tail', 'right');
       d(n, l,:) = computeCohen_d(squeeze(mean(res{n}(:,l,testtp),3)), ...
                                                   squeeze(mean(res{3}(:,l,testtp),3)), 'paired');
    end
    h(h==0) = NaN;
    h(h==1) =0;
    hold on
end
%% plot 4
hold on;
delta = [0 0.1 0.05]
errorbar([interval2]+delta(1), mean([ffds squeeze(mean(res{1}(:,2,testtp),3)) ]), ...
    (std([ffds squeeze(mean(res{1}(:,2,testtp),3))]))/sqrt(size(res{1},1)), ...
    'Linewidth', 3, 'Color', [0.4490 0.7608 0], ...
    'Marker', 'o', 'MarkerSize', 10,'MarkerEdgeColor' , 'none', 'MarkerFaceColor' , [0.4490 0.7608 0])
    hold on 
    X = repmat([interval2]+delta(1), [size(res{1},1),1]);
    X = X +  (rand(size(X,1),size(X,2))-1/2)/65;
    Y = [ffds squeeze(mean(res{1}(:,2,testtp),3))];
    for l = 1:2    
    scatter(X(:,l), ...
            Y(:,l), ...
            dotsize, [0.4490 0.7608 0], 'filled')
    end
    hold on


hold on
errorbar([interval2] +delta(2), mean([fbds squeeze(mean(res{2}(:,2,testtp),3))]), ...
    (std([fbds squeeze(mean(res{2}(:,2,testtp),3))]))/sqrt(size(res{1},1)), ...
    'Linewidth', 3, 'Color', [0.5000 0.3892 0.8098], ...
    'Marker', 'o', 'MarkerSize', 10, 'MarkerEdgeColor' , 'none', 'MarkerFaceColor' , [0.5000 0.3892 0.8098])

    hold on 
    X = repmat([interval2]+delta(2), [size(res{1},1),1]);
    X = X +  (rand(size(X,1),size(X,2))-1/2)/65;
    Y = [fbds squeeze(mean(res{2}(:,2,testtp),3))];
    for l = 1:2
        scatter(X(:,l), ...
                Y(:,l), ...
                dotsize, [0.5000 0.3892 0.8098], 'filled')
    end
    hold on

hold on
errorbar([interval2] + delta(3), mean([fnods3 squeeze(mean(res{3}(:,2,testtp),3))]), ...
    (std([fbds squeeze(mean(res{3}(:,2,testtp),3))]))/sqrt(size(res{1},1)), ...
    'Linewidth', 2, 'Color', [0.5000 0.5 0.5], 'LineStyle', '--', ...
    'Marker', 'o', 'MarkerSize', 10, 'MarkerEdgeColor' , 'none', 'MarkerFaceColor' , [0.5000 0.5 0.5])

    hold on 
    X = repmat([interval2]+delta(3), [size(res{1},1),1]);
    X = X +  (rand(size(X,1),size(X,2))-1/2)/65;
    Y = [fnods3 squeeze(mean(res{3}(:,2,testtp),3))];
    for l = 1:2
        scatter(X(:,l), ...
                Y(:,l), ...
                dotsize, [0.5000 0.5 0.5], 'filled')
    end
    hold on


%%

x = sprintf('proportion of predicted labels')  %same
xticks([interval+0.05 interval2+0.05])
xticklabels({'deep','middle', 'superficial', 'deep+superficial', 'middle'})
hLegend = legend({'presented (feedforward)', 'rotated (feedback)', 'not shown'}, 'Position', [0.45 0.73 0.1 0.2])
hXLabel = xlabel(['cortical depth'])
hYLabel = ylabel(x)
xlim([min(interval) - 0.1 max(interval2) + 0.15])
hTitle = title(['Interaction of Cortical Layer X Signal']) 

legend('boxoff')  

set(gca, 'Box', 'off')
% Fonts
set( gca                       , ...
    'FontName'   , 'Times' );
set([hXLabel, hYLabel], ...
    'FontName'   , 'Times');
set([hLegend, gca]             , ...
    'FontSize'   , 12           );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 14          );
set( hTitle                    , ...
    'FontSize'   , 18          , ...
    'FontWeight' , 'bold'      );
% Saving as it is on the screen
set(gcf, 'PaperPositionMode', 'auto');
legend off
%print -depsc2 plot06_tp35.eps
%print -djpeg plot06.jpg
%close;
['p perception: ' ]
[~, ~, ~, adj_p]=fdr_bh(p(1,:))
%p(1,:)
 ([stats(1,:).tstat])
['cohens d']
d(1,:)
['p mental rotation: ' ]
[~, ~, ~, adj_p]=fdr_bh(p(2,:))
%p(2,:)
 ([stats(2,:).tstat])
['cohens d']
d(2,:)

end
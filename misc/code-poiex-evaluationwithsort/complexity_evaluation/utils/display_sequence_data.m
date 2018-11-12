function hFig=display_sequence_data(result,config)

hFig=[];

for ss = 1:numel(result) 
    data = result{ss};
    Nframes = result{ss}.Nframes;
    
    for kk=1:data.Nframes        
        %alternative cardinality cost        
        card_gt_de_v2(kk) = abs(size(data.overlap_gt_de{kk},1) - size(data.overlap_gt_de{kk},2)) / data.Nassoc_gt_de(kk);
        card_gt_tr_v2(kk) = abs(size(data.overlap_gt_tr{kk},1) - size(data.overlap_gt_tr{kk},2)) / data.Nassoc_gt_tr(kk);
    end
        
    if (config.DISPLAY_COST_A == 1)
    
        % plot data for current sequence
        hFig(ss,1)=figure;
        set(gcf,'Name',sprintf('%s Intra-frame association complexity for A: association cost',data.seq));
    
        %number of elements
        subplot 511;    
        plot(1:Nframes,data.Nde,1:Nframes,data.Ntr,1:Nframes,data.Ngt_de); hold on;    
        legend('#de_k','#tr_k','#gt_k','Orientation','Horizontal','Location','best');    
        axis([1 Nframes min([data.Nde data.Ntr data.Ngt_de]) max([data.Nde data.Ntr data.Ngt_de])])   
        ylabel('# data');
        title(sprintf('Intra-frame scores for %s with association (A) costs', data.seq));    

        %number of associations
        subplot 512;    
        plot(1:Nframes,data.Nassoc_gt_de,1:Nframes,data.Nassoc_gt_tr); hold on;
        legend('#asso^d_k','#asso^t_k','Orientation','Horizontal','Location','best');    
        ylabel('# associations');
        axis([1 Nframes min([data.Nde data.Ntr data.Ngt_de]) max([data.Nde data.Ntr data.Ngt_de])])   

        %association cost  (accumulated)  
        subplot 513;
        plot(1:Nframes,data.cost_gt_de,1:Nframes,data.cost_gt_tr);
        legend('A_k^d','A_k^t','Orientation','Horizontal','Location','best');        
        ylabel('Total cost');
        axis([1 Nframes min([data.cost_gt_de data.cost_gt_tr]) max([data.cost_gt_de data.cost_gt_tr])])

        %association cost  (average)  
        subplot 514;
        plot(1:Nframes,data.cost_gt_de./data.Nassoc_gt_de,1:Nframes,data.cost_gt_tr./data.Nassoc_gt_tr);
        legend('A_k^d/#assoc^d_k','A_k^t/#assoc^t_k','Orientation','Horizontal','Location','best');    
        ylabel('Avg cost');
        axis([1 Nframes min([data.cost_gt_de./data.Nassoc_gt_de data.cost_gt_tr./data.Nassoc_gt_tr]) max([data.cost_gt_de./data.Nassoc_gt_de data.cost_gt_tr./data.Nassoc_gt_tr])])
        
        %association cost (normalized by max(u_k,v_k))
        nfactor_gt_de = max(data.Nde,data.Ngt_de);
        nfactor_gt_tr = max(data.Ntr,data.Ngt_tr);

        subplot 515;
        plot(1:Nframes,data.cost_gt_de./nfactor_gt_de,1:Nframes,data.cost_gt_tr./nfactor_gt_tr);
        legend('A_k^d/max(#de_k,#gt_k)','A_k^t/max(#tr_k,#gt_k)','Orientation','Horizontal','Location','best');   
        ylabel('Norm cost');
        axis([1 Nframes min([data.cost_gt_de./nfactor_gt_de data.cost_gt_tr./nfactor_gt_tr]) max([data.cost_gt_de./nfactor_gt_de data.cost_gt_tr./nfactor_gt_tr])])         
    end
    
    if (config.DISPLAY_COST_C == 1)
    
        % plot data for current sequence
        hFig(ss,2)=figure;
        set(gcf,'Name',sprintf('%s Intra-frame association complexity for C: cardinality cost', data.seq));
        
         %number of elements
        subplot 511;    
        plot(1:Nframes,data.Nde,1:Nframes,data.Ntr,1:Nframes,data.Ngt_de); 
        legend('#de_k','#tr_k','#gt_k','Orientation','Horizontal','Location','best');    
        axis([1 Nframes min([data.Nde data.Ntr data.Ngt_de]) max([data.Nde data.Ntr data.Ngt_de])])   
        ylabel('# data');
        title(sprintf('Intra-frame scores for %s with association (A) costs', data.seq));    

        %number of associations
        subplot 512;    
        plot(1:Nframes,data.Nassoc_gt_de,1:Nframes,data.Nassoc_gt_tr); hold on;
        legend('#asso^d_k','#asso^t_k','Orientation','Horizontal','Location','best');    
        ylabel('# associations');
        axis([1 Nframes min([data.Nde data.Ntr data.Ngt_de]) max([data.Nde data.Ntr data.Ngt_de])])   
        
        %cardinality cost
        subplot 513;
        plot(1:Nframes,card_gt_de_v2,1:Nframes,card_gt_tr_v2);
        legend('C_k^d=|#de_k-#gt_k|/#asso^d_k','C_k^t=|#tr_k-#gt_k|/#asso^t_k','Orientation','Horizontal','Location','best');    
        ylabel('cost');
        axis([1 Nframes min([card_gt_de_v2 card_gt_tr_v2]) max([card_gt_de_v2 card_gt_tr_v2])])   
        
        %cardinality cost
        subplot 514;
        plot(1:Nframes,data.card_gt_de,1:Nframes,data.card_gt_tr);
        legend('C_k^d=|#de_k-#gt_k|/max(#de_k,#gt_k)','C_k^t=|#tr_k-#gt_k|/max(#tr_k,#gt_k)','Orientation','Horizontal','Location','best');    
        ylabel('cost');
        axis([1 Nframes min([data.card_gt_de data.card_gt_tr]) max([data.card_gt_de data.card_gt_tr])])   
    end
    
    if (config.DISPLAY_COST_B == 1)

        % plot data for current sequence
        hFig(ss,3)=figure;
        set(gcf,'Name',sprintf('%s Intra-frame association complexity for A: association cost, C: cardinality cost', data.seq));

          %number of elements
        subplot 511;    
        plot(1:Nframes,data.Nde,1:Nframes,data.Ntr,1:Nframes,data.Ngt_de); 
        legend('#de_k','#tr_k','#gt_k','Orientation','Horizontal','Location','best');    
        axis([1 Nframes min([data.Nde data.Ntr data.Ngt_de]) max([data.Nde data.Ntr data.Ngt_de])])   
        ylabel('# data');
        title(sprintf('Intra-frame scores for %s with association (A) costs', data.seq));    

        %number of associations
        subplot 512;    
        plot(1:Nframes,data.Nassoc_gt_de,1:Nframes,data.Nassoc_gt_tr); hold on;
        legend('#asso^d_k','#asso^t_k','Orientation','Horizontal','Location','best');    
        ylabel('# associations');
        axis([1 Nframes min([data.Nde data.Ntr data.Ngt_de]) max([data.Nde data.Ntr data.Ngt_de])])   

        %association cost  (accumulated)  
        subplot 513;
        plot(1:Nframes,data.cost_gt_de,1:Nframes,data.cost_gt_tr);
        legend('A_k^d','A_k^t','Orientation','Horizontal','Location','best');        
        ylabel('Total cost');
        axis([1 Nframes min([data.cost_gt_de data.cost_gt_tr]) max([data.cost_gt_de data.cost_gt_tr])])

        %cardinality cost (normalized)
        subplot 514;
        plot(1:Nframes,data.card_gt_de,1:Nframes,data.card_gt_tr);
        legend('C_k^d=|#de_k-#gt_k|/max(#de_k,#gt_k)','C_k^t=|#tr_k-#gt_k|/max(#tr_k,#gt_k)','Orientation','Horizontal','Location','best');    
        ylabel('cost');
        axis([1 Nframes min([data.card_gt_de data.card_gt_tr]) max([data.card_gt_de data.card_gt_tr])])  
    end
    
    if (config.DISPLAY_COST_D == 1)
    
        % plot data for current sequence
        hFig(ss,3)=figure;
        
        set(gcf,'Name',sprintf('%s - Intra-frame association complexity for A: cost of association, B: cost of non-association, C: cardinality cost', data.seq));
        
        % number of elements
        subplot 511;    
        plot(1:Nframes,data.Nde,1:Nframes,data.Ntr,1:Nframes,data.Ngt_de); 
        legend('#de_k','#tr_k','#gt_k','Orientation','Horizontal','Location','best');    
        axis([1 Nframes min([data.Nde data.Ntr data.Ngt_de]) max([data.Nde data.Ntr data.Ngt_de])])   
        ylabel('# data');
        title(sprintf('Intra-frame scores for %s with association (A) costs', data.seq));    

        % cost of association
        subplot 512;    
        plot(1:Nframes, data.Cost_assoc_gt_de, 1:Nframes, data.Cost_assoc_gt_tr); hold on;
        % legend('#asso^d_k','#asso^t_k','Orientation','Horizontal','Location','best');    
        ylabel('cost of assoc');
        axis([1 Nframes 0 1])   
        
        % cost of non-association
        subplot 513;
        plot(1:Nframes, data.Cost_non_assoc_gt_de, 1:Nframes, data.Cost_non_assoc_gt_tr);
        % legend('A_k^d','A_k^t','Orientation','Horizontal','Location','best');        
        ylabel('cost of non-assoc');
        axis([1 Nframes 0 1])
        
        % cardinality cost (normalized)
        subplot 514;
        plot(1:Nframes, data.card_gt_de, 1:Nframes, data.card_gt_tr);
        % legend('C_k^d=|#de_k-#gt_k|/max(#de_k,#gt_k)','C_k^t=|#tr_k-#gt_k|/max(#tr_k,#gt_k)','Orientation','Horizontal','Location','best');    
        ylabel('cardinality cost');
        axis([1 Nframes 0 1])  
        
        % METE
        subplot 515;
        plot(1:Nframes, data.E_gt_de, 1:Nframes, data.E_gt_tr);
        % legend('C_k^d=|#de_k-#gt_k|/max(#de_k,#gt_k)','C_k^t=|#tr_k-#gt_k|/max(#tr_k,#gt_k)','Orientation','Horizontal','Location','best');    
        ylabel('mete');
        axis([1 Nframes 0 1.2])  
    end
    
    if (config.DISPLAY_COST_E == 1)
    
        % plot data for current sequence
        hFig(ss,3)=figure;
        
        subplot 211
        plot(1:Nframes, data.mete_de, 1:Nframes, data.mete_tr);
        legend('METE-DE','METE-TR','Orientation','Horizontal','Location','best');
        ylabel('mete');
        axis([1 Nframes 0 1])
        
        subplot 212
        plot(1:Nframes, data.IntraComplexity);
        ylabel('IntraComplexity');
        title(sprintf('intra-frame complexity - average %1.4f',mean(data.IntraComplexity))) % value of IntraComplexity computed as the mean of IntraComplexity at each frame
        axis([1 Nframes -1 1])
        
        set(hFig(ss,3), 'position', [279 170 1051 760])
        
        hImg = figure;
        [X,Y] = meshgrid(0:.01:1,0:.01:1);
        Z = X.^1.1 - Y.^1.1;
        idx = find(X < Y);
        Z(idx) = -((1-X(idx)).^1.1 - (1-Y(idx)).^1.1); % flip the function when the effort in reversed
        
        contourf(Z,30)
        set(gca, 'ytick', 0:10:100, 'yticklabel', 0:.1:1);
        set(gca, 'xtick', 0:10:100, 'xticklabel', 0:.1:1);
        axis ij
        colorbar
        
        set(hImg, 'position', [347 366 689 566])
        
        mu_mete_de = mean(data.mete_de);
        mu_mete_tr = mean(data.mete_tr);
        rectangle('position', [mu_mete_de*100 mu_mete_tr*100 1 1], 'linewidth', 3, 'edgecolor', 'r') % this is multipled by 100 only to rescale it for the graph
        
        % value of IntraComplexity computed using the mean of METE (note that is different than that above in subplot 212)
        if mu_mete_de >= mu_mete_tr
            title(sprintf('intra-frame complexity - average %1.4f',mu_mete_de^1.1 - mu_mete_tr^1.1));
        else
            title(sprintf('intra-frame complexity - average %1.4f', -((1-mu_mete_de)^1.1 - (1-mu_mete_tr)^1.1)));
        end
        
    end
    
end
%     
%     %association cost    
%     subplot 512;
%     plot(1:Nframes,cost_gt_de,1:Nframes,cost_gt_tr);
%     legend('A_k^d','A_k^t','Orientation','Horizontal','Location','best');    
%     title(sprintf('Intra-frame scores for %s with costs: A=association & C=cardinality', Seqs{ss}));    
%     axis([1 Nframes min([cost_gt_de cost_gt_tr]) max([cost_gt_de cost_gt_tr])])
%     

%     
%    
% %     %association cost (normalized by min(u_k,v_k))
% %     nfactor_gt_de = min(Nde,Ngt_de);
% %     nfactor_gt_tr = min(Ntr,Ngt_tr);    
% %     subplot 513;
% %     plot(1:Nframes,cost_gt_de./nfactor_gt_de,1:Nframes,cost_gt_tr./nfactor_gt_tr);
% %     legend('A_k^d/min(u^d_k,gt_k)','A_k^t/min(u^t_k,gt_k)','Orientation','Horizontal','Location','best');        
% %     axis([1 Nframes min([cost_gt_de./nfactor_gt_de cost_gt_tr./nfactor_gt_tr]) max([cost_gt_de./nfactor_gt_de cost_gt_tr./nfactor_gt_tr])])         
% %        
%     %association cost (normalized by max(u_k,v_k))
%     nfactor_gt_de = max(Nde,Ngt_de);
%     nfactor_gt_tr = max(Ntr,Ngt_tr);
% 
%     subplot 514;
%     plot(1:Nframes,cost_gt_de./nfactor_gt_de,1:Nframes,cost_gt_tr./nfactor_gt_tr);
%     legend('A_k^d/max(#de_k,#gt_k)','A_k^t/max(#tr_k,#gt_k)','Orientation','Horizontal','Location','best');        
%     axis([1 Nframes min([cost_gt_de./nfactor_gt_de cost_gt_tr./nfactor_gt_tr]) max([cost_gt_de./nfactor_gt_de cost_gt_tr./nfactor_gt_tr])])         
%     
%     %association cost (normalized by gt)
%     subplot 515;
%     plot(1:Nframes,cost_gt_de./Ngt_de,1:Nframes,cost_gt_tr./Ngt_tr); hold on;
%     plot(1:Nframes,cost_gt_de./Ngt_de,1:Nframes,cost_gt_tr./Ngt_tr); hold on;
%     legend('A_k^d/#gt_k','A_k^t/#gt_k','Orientation','Horizontal','Location','best');        
%     axis([1 Nframes min([cost_gt_de./Ngt_de cost_gt_tr./Ngt_tr]) max([cost_gt_de./Ngt_de cost_gt_tr./Ngt_tr])])         
% %     
% %     %cardinality cost (normalized by max(u_k,v_k))
% %     subplot 514;
% %     plot(1:Nframes, card_gt_de./nfactor_gt_de,1:Nframes, card_gt_tr./nfactor_gt_tr);
% %     legend('C_k^d/max(u^d_k,gt_k)','C_k^t/max(u^t_k,gt_k)','Orientation','Horizontal','Location','best');        
% %     axis([1 Nframes min([card_gt_de./nfactor_gt_de card_gt_tr./nfactor_gt_tr]) max([card_gt_de./nfactor_gt_de card_gt_tr./nfactor_gt_tr])])         
%     
%     %     plot(1:Nframes, mete_gt_de); hold on;
% %     plot(1:Nframes, mete_gt_tr); hold on;
% %     legend('METE_k^d','METE_k^t','Orientation','Horizontal','Location','best');
% %     
% %     subplot 513;
% %     plot(1:Nframes,cost_gt_de-cost_gt_tr);
% %     legend('\Delta cost = cost_k^d - cost_k^t','Location','best');
% %     xlim([1 Nframes])
% %     ylim([min(cost_gt_de-cost_gt_tr) max(cost_gt_de-cost_gt_tr)])
% %     
% %     subplot 514;
% %     plot(1:Nframes,card_gt_de-card_gt_tr);
% %     legend('\Delta card = card_k^d - card_k^t','Location','best');
% %     xlim([1 Nframes])
% %     ylim([min(card_gt_de-card_gt_tr) max(card_gt_de-card_gt_tr)])
%     
% %     %% define functions to normalize
% %     %normalize_fun =@(E_d,E_t) abs(E_d-E_t) ./ E_d;
% %     normalize_fun1 =@(E_d,E_t) (E_d-E_t) ./ E_d;
% %     normalize_fun2 =@(E_d,E_t,factor) (E_d-E_t) ./ factor; %normalized by the max of #det, #est, #gt
% %         
% %     subplot 514;
% %     intraScoreMETE = normalize_fun2(mete_gt_de,mete_gt_tr,oNtr(1,numel(mete_gt_tr)));
% %     plot(1:Nframes,intraScoreMETE);
% %     legend('\Delta METE_k^{intra} = METE_k^d - METE_k^t','Location','best');
% %     xlim([1 Nframes])    
% %     ylim([-0.5 0.5])
% %     
% %     subplot 515;
% %     intraScore1 = normalize_fun1(cost_gt_de,cost_gt_tr);
% %     intraScore2 = normalize_fun2(cost_gt_de,cost_gt_tr,NormFactor);
% %     plot(1:Nframes,intraScore1); hold on;
% %     plot(1:Nframes,intraScore2);
% %     legend('\Delta E_k^{intra} / E_k^d','\Delta E_k^{intra} / max(#Det,#Est,#Gt)');
% %     xlabel('Frame number (k)');
% %     xlim([1 Nframes])
% %     ylim([-1 1])
% %     intraScore = intraScore2; %we save the intra-score using the normalization factor
% %     
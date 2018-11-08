function hFig = display_overall_data(results,Seqs,config)

if config.DISPLAY_STATS
    % overall results
    hFig(1)=figure;
    set(gcf,'Name','Intra-frame score for each sequence');
    hold on;
    
    outconf = 5;
    for ss = 1:numel(results)    
       
        subplot 311; hold on;
        data = results{ss}.intraScore_A;    
        data = data(isfinite(data)); %remove NaN & Inf values
        labels = bplot(data,ss,'whisker',outconf);        
        ylabel('Intra-score (cardinality)'); %text for Y label
        
        subplot 312; hold on;
        data = results{ss}.intraScore_C;    
        data = data(isfinite(data)); %remove NaN & Inf values
        labels = bplot(data,ss,'whisker',outconf);
        
        subplot 313; hold on;
        data = results{ss}.intraScore;    
        data = data(isfinite(data)); %remove NaN & Inf values
        labels = bplot(data,ss,'whisker',outconf);                
    end    
    
    subplot 311; set(gca,'XTick',[]); ylabel('Asso decrease'); %text for Y label
    subplot 312; set(gca,'XTick',[]); ylabel('Card decrease'); %text for Y label
    subplot 313; set(gca,'XTick',1:numel(results),'XTickLabel',Seqs); ylabel('Intra-score'); %text for Y label
    legend(labels,'Location','best');%legend(labels,'Location','southeast');
    
    ax = gca; 
    ax.XTickLabelRotation = 45;

    hFig(2)=figure('Position',[100 100 600 800]);
    set(gcf,'Name','Score comparison for each sequence (TP,FP,FN)');

    for ss = 1:numel(results)  
        a = results{ss}.TPde; det(1,ss)=sum(a(:));
        a = results{ss}.FPde; det(2,ss)=sum(a(:));
        a = results{ss}.FNde; det(3,ss)=sum(a(:));
        a = results{ss}.TPtr; est(1,ss)=sum(a(:));
        a = results{ss}.FPtr; est(2,ss)=sum(a(:));
        a = results{ss}.FNtr; est(3,ss)=sum(a(:));

        a=results{ss}.trackMetrics;
        trk(1,ss)= a(1);%precision
        trk(2,ss)= a(2);%recall
        trk(3,ss)= a(8);%FPs
        trk(4,ss)= a(9);%FNs

    end

    subplot 311
    plot(1:numel(results),det(1,:),'r+-',1:numel(results),det(2,:),'g*-',1:numel(results),det(3,:),'bd-')
    legend('TP-detection','FP-detection','FN-detection');

    subplot 312
    plot(1:numel(results),est(1,:),'r+-',1:numel(results),est(2,:),'g*-',1:numel(results),est(3,:),'bd-')
    legend('TP-tracks','FP-tracks','FN-tracks');

    subplot 313
    plot(1:numel(results),trk(3,:),'g*-',1:numel(results),trk(4,:),'bd-')
    legend('FP(MOT)','FN(MOT)');
    set(gca,'XTick',1:numel(results),'XTickLabel', Seqs); %text for each element of X label
    set(gca,'XTickLabelRotation',45);

    hFig(3)=figure('Position',[100 100 600 800]);
    set(gcf,'Name','Score comparison for each sequence (Pre, Rec)');

    for ss = 1:numel(results) 
        c = results{ss}.Ngt;
        b = results{ss}.Nde;     
        a = results{ss}.TPde; 
        det(1,ss)=sum(a(:))/sum(b(:)); %precision
        det(2,ss)=sum(a(:))/sum(c(:)); %recall

        a = results{ss}.TPtr; 
        b = results{ss}.Ntr; 
        est(1,ss)=sum(a(:))/sum(b(:)); %precision
        est(2,ss)=sum(a(:))/sum(c(:)); %recall

        a=results{ss}.trackMetrics;
        trk(1,ss)= a(2);%precision
        trk(2,ss)= a(1);%recall    
    end

    subplot 311
    plot(1:numel(results),100*det(1,:),'r+-',1:numel(results),100*det(2,:),'g*-')
    legend('Pre-detection','Rec-detection','Location','southeast');
    title('Frame level');

    subplot 312
    plot(1:numel(results),100*est(1,:),'r+-',1:numel(results),100*est(2,:),'g*-')
    legend('Pre-tracks','Rec-tracks','Location','southeast');
    title('Frame level');

    subplot 313
    plot(1:numel(results),trk(1,:),'r+-',1:numel(results),trk(2,:),'g*-')
    legend('Pre(MOT)','Rec(MOT)','Location','southeast');
    set(gca,'XTick',1:numel(results),'XTickLabel', Seqs); %text for each element of X label
    set(gca,'XTickLabelRotation',45);
    title('Sequence level (MOT 2015)');

    saveas(hFig(1),'Comparison_intrascore.png','png');
    saveas(hFig(1),'Comparison_intrascore.fig','fig');
    saveas(hFig(2),'Comparison_TP_FP_FN.png','png');
    saveas(hFig(2),'Comparison_TP_FP_FN.fig','fig');
    saveas(hFig(3),'Comparison_Precision_Recall.png','png');
    saveas(hFig(3),'Comparison_Precision_Recall.fig','fig');
end
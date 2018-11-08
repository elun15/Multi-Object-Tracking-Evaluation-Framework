function [TP, FP, FN, Nde, Ngt] = PerformanceAssociationFrameLevel(assoc_matrix,overlap_matrix)
%

td = 0.3; %threshold for minimum detection

N = numel (assoc_matrix);
Ngt = zeros(1,N);
Nde = zeros(1,N);
TP = zeros(1,N);
FP = zeros(1,N);
FN = zeros(1,N);
for kk = 1:N
    A = assoc_matrix{kk}; %association matrix for ground-trut & detections
   
    Ngt(kk) = size(A,1); % ground-truth correspond to rows
    Nde(kk) = size(A,2); % detections correspond to columns
    
    for bb=1:Ngt(kk)
        ind = find(A(bb,:)==1);
    
        %False Negative - no match for the ground-truth element
        if isempty(ind)
            FN(kk) = FN(kk) + 1;
        else        
            %check the overlap matrix
            if overlap_matrix{kk}(bb,ind) > td
                %True Positive - sufficiently match for the ground-truth element
                TP(kk) = TP(kk) + 1;
            else
               %False Negative  - not sufficiently match for the ground-truth element
               FN(kk) = FN(kk) + 1;
            end
        end
    end
    FP(kk)= Nde(kk) - TP(kk);
end
P = sum(TP)/ sum(Nde);
R = sum(TP)/ (sum(TP)+ sum(FN));
% fprintf(' Frame-level performance: Ngt=%d  Ndata=%d --> TP=%d FP=%d FN=%d Pre=%.2f Rec=%.2f\n',sum(Ngt),sum(Nde),sum(TP),sum(FP),sum(FN),P,R);
%% define the mapping of colors combinations to 
geneMap.geneNames = {'Pat','Mat','REF'};
geneMap.channelTable = [1 1 0;...
                        0 1 1;...
                        1 1 1;];
geneMap.RNAFields = {'cy','gfp','tmr'};


%%
%Run statistical analysis of SUZ12

load('SUZ12-flatter-1-2-2ndDay-1-thru-4.mat');

% results matrix: [nCells (rows) x total RNA, WT, SNP w(cols)]
[results,snper] = getSNPresults(objects,geneMap);

load('SUZ12-HeLa-data002-3.mat');
[resultsHomo,snper2] = getSNPresults(objects,geneMap);

%Perform analysis at population level

totals = sum(results); %Obtain composite counts
totalsH = sum(resultsHomo); %Obtain composite counts

%MLE of detection efficiency based on binomial fit (with confidence
%intervals)

[d_1 d_1conf] = binofit(totalsH(2) + totalsH(3), totalsH(1));

[d_MLE d_conf]= binofit(totals(2) + totals(3), totals(1));

dNMT1 = 

%Overall allelic imbalance MLE
p = 0.05 %Set desired p_value

I_MLE = totals(2)./(totals(2) + totals(3));
[I_lower I_upper] = imbalanceConfidenceBounds(totals, I_MLE, d_MLE, d_MLE, p);



%%
%Run statistical analysis of DMNT1





%%
%Run statistical analysis of SKA3





%% SSM Model
clear all
load(fullfile(cd,'ARparameter'));

%%
par             = parAR;            % parameters of the AR(2) model
par.numTrial    = 500;              % number of trials
par.fsample     = 1000;             % sample rate
par.time        = 20;               % time in sec
par.a           = 2/3;              % slope 1/f

func    = {[],'sigmoid'};           % determines transfer function [ [] = liner transfer]
cw      = 0.05;                     % projection strength
fac     = 2;                        % determines SOS (scales with 1/SOS)
result  = cell(1,length(func));

for cnt1 = 1 : length(func)
    
    id =1 ;
    parameter = cell(1,length(fac)*length(cw));
    for cnt2 = 1 : length(fac)        
        for cnt3 = 1 : length(cw)
            parameter{id}       = par;
            parameter{id}.cw    = cw(cnt3);
            parameter{id}.fac   = fac(cnt2);
            parameter{id}.func  = func{cnt1};
            id = id + 1;
        end
    end            
    out = cellfun(@SSM1,parameter);  
    
    result{cnt1}.Freq = out.Freq;
    
    id = 1;
    for cnt2 = 1 : length(fac)        
        for cnt3 = 1 : length(cw)
            result{cnt1}.Coh{cnt2,cnt3} = out(id).Coh;
            result{cnt1}.cw(cnt2,cnt3) = cw(cnt3);
            result{cnt1}.sos(cnt2,cnt3) = out(id).SOS;
            result{cnt1}.CohPeakSim(cnt2,cnt3) = out(id).CohPeak;
            result{cnt1}.CohPeakAna(cnt2,cnt3) = sqrt(1./(1+(1./(cw(cnt3).^2*(1+out(id).SOS)))));
            result{cnt1}.func = func{cnt1};
            id = id +1;
        end
    end
end

figure
hold
plot(result{1}.Freq,result{1}.Coh{1,1})
plot(result{2}.Freq,result{2}.Coh{1,1})
xlabel('frequency')
ylabel('coherence')
xlim([0 100])
legend({'linear transfer','sigmoidal transfer'})

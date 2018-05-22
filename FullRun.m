
%% unsupervised
global GROUP_SIZES iter chanceTable
GROUP_SIZES = 0;
global fullTable ;
fullTable = cell(0) ;
chanceTable =[ ];
MAX_DIM = [];
names = cell(0);
for iter = 1:9
    %%
    if iter == 1
        setName = 'GSP_volume';
    elseif iter == 2
        setName = 'GSP_thickness' ;
    elseif iter == 3
        setName = 'monkeys';
    elseif iter == 4
        setName = 'connectome_VBM';
    elseif iter == 5
        setName = 'GSP_VBM';
    elseif iter == 6
        setName = 'Car_Ris';
    elseif iter == 7
        setName = 'GSP_volume_divide_power';% ICV
    elseif iter == 8
        setName = 'Cortical';
    elseif iter == 9
        setName = 'Cortical_corrected';
    end
    readData;
    originalData = allData;
    originalGroups = allGroups;
    if strcmp( setName , 'GSP_volume' )
        originalFullSize = fullSize;
    end
    if ~exist(fullfile( setName , ['allDataGroupsOriginal.mat' ] ) , 'file')
        if strcmp( setName , 'GSP_volume' )
            allFullSize = originalFullSize;
            save( fullfile( setName , ['allDataGroupsOriginal.mat' ] ) ,'allFullSize', 'allData' , 'allGroups' );
        else
            save( fullfile( setName , ['allDataGroupsOriginal.mat' ] ) , 'allData' , 'allGroups' );
        end        
    end
    if iter == 1
        MainUnsupervised;
        sandbox;
        sandboxOnly2;
        GROUP_SIZES = 1;
        MainUnsupervised;
        sandboxOnly2
        sandbox;
        GROUP_SIZES = 0;
    else
        MainUnsupervised;
        sandboxOnly2;
        sandbox;
    end
end

%% supervise
MainSupervisedAllWithAges
sandboxSupervised

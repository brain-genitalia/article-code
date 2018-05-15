
%% unsupervised
global GROUP_SIZES iter chanceTable
GROUP_SIZES = 0;
global fullTable ;
fullTable = cell(0) ;
chanceTable =[ ];
MAX_DIM = [];
names = cell(0);
for iter = [6 2 1 16 19 21 20 ]
    %%
    if iter == 0
        setName = 'GSP_volume_divide';
    elseif iter == 1
        setName = 'GSP_volume';
    elseif iter == 2
        setName = 'GSP_thickness' ;
    elseif iter == 3
        setName = 'monkeys';
    elseif iter == 4
        setName = 'monkeys3';
    elseif iter == 5
        setName = 'connectome_VBM';
    elseif iter == 6
        setName = 'GSP_VBM';
    elseif iter == 7
        setName = 'israel';
    elseif iter == 8
        setName = 'beijing';
    elseif iter == 9
        setName = 'cambridge';
    elseif iter == 10
        setName = 'zirich';
    elseif iter == 11
        setName = 'GSP_behavior';
    elseif iter == 12
        setName = 'ADD_Health';
    elseif iter == 13
        setName = 'Car_Ris';
    elseif iter == 14
        setName = 'GSP_volume_log_divide';
    elseif iter == 15
        setName = 'GSP_volume_divide_prop';
    elseif iter == 16
        setName = 'GSP_volume_divide_power';% ICV
    elseif iter == 17
        setName = 'GSP_volume_divide_regres';
    elseif iter == 18
        setName = 'Kids';
    elseif iter == 19
        setName = 'Cortical';
    elseif iter == 20
        setName = 'simulated';
    elseif iter == 21
        setName = 'Cortical_corrected';
    end
    readData;
    
    names{length(names) + 1 } = setName;
    mkdir( setName );
    mkdir( fullfile( setName , 'data' ) );
    mkdir( fullfile( setName , 'imagesNew' ) );
    mkdir( fullfile( setName , 'imagesNew' , 'supervised') );
    mkdir( fullfile( setName , 'imagesNew' , 'clustering') );
    mkdir( fullfile( setName , 'imagesNew' , 'anomaly detection') );
    mkdir( fullfile( setName , 'imagesNew' , 'example') );
    mkdir( fullfile( setName , 'imagesNew' , 'general') );
    if iter == 1
        mkdir( fullfile( setName , 'imagesVolume' ) );
        mkdir( fullfile( setName , 'imagesVolume' , 'supervised') );
        mkdir( fullfile( setName , 'imagesVolume' , 'clustering') );
        mkdir( fullfile( setName , 'imagesVolume' , 'anomaly detection') );
        mkdir( fullfile( setName , 'imagesVolume' , 'example') );
        mkdir( fullfile( setName , 'imagesVolume' , 'general') );
    end
    
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
        for i = 1 : 9
            ind = randperm( length( allGroups ) );
            allGroups = originalGroups( ind );
            allData = originalData( ind , : );
            if strcmp( setName , 'GSP_volume' );
                allFullSize = originalFullSize( ind );
                save( fullfile( setName , ['allDataGroupsRandomized' , num2str(i) , '.mat' ] ) , 'allData' , 'allGroups' , 'allFullSize' , 'ind' );
            else
                save( fullfile( setName , ['allDataGroupsRandomized' , num2str(i) , '.mat' ] ) , 'allData' , 'allGroups' , 'ind' );
            end
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


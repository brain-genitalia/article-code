global REGION
if isempty( REGION)
    REGION = 0;
end
median_size = 1.576423454230000e+06;
load ind2size.mat
% in groups 1 - males, 2 - females
switch setName
    case 'connectome_VBM'
        num = xlsread( 'Israeli_(first)_sample_VBM.xlsx' , 'A2:DN281' );
        israelAges = num(all(~isnan(num) , 2 ) , 2 );
        israelData = num( all(~isnan(num) , 2 ) , 3 : end);
        israelGroups = num( all(~isnan(num) , 2 ) , 1 );
        num = xlsread('1000_Connectomes_VBM.xlsx' , 'A2:DN856');
        globalAges = num(all(~isnan(num) , 2 ) , 2 );
        globalData = num( all(~isnan(num) , 2 ) , 3 : end);
        globalGroups = num( all(~isnan(num) , 2 ) , 1 );
        
        allData = [ israelData ; globalData ;  ];
        allGroups = [ israelGroups ; globalGroups ; ];
        allAges = [israelAges ; globalAges ];
        [ allData , allGroups , ind ] = divideTo2( allData , allGroups );
        allAges = allAges( ind );
    case 'GSP_thickness'
        [num,txt] = xlsread('DataRelease_2014-04-22.xlsx', 'DataRelease_2014-04-22','A1:CJ1571');
        gender = double( strcmp( txt(2 : end , 5) , 'F'))  + 1;
        age = num(: , 4 );
        
        [num,txt] = xlsread('GSP_FS_thickness.xlsx');
        ind = txt( 2: end , 1 );
        ind = cell2mat( cellfun(@(x) str2num( x( 4:end)) , ind , 'UniformOutput', false) );
        outliers = xlsread('VBM_outliers.xlsx');
        legalIndices = ~ismember( ind , outliers ) ;
        ind = ind( legalIndices);
        allData = num( legalIndices , : );
        orig_all_data = allData;
        allGroups = gender( ind );
        [ allData , allGroups ] = divideTo2( allData , allGroups );
        [ is_large_than_median_result ] = is_large_than_median( orig_all_data , allData , ind , ind2size , median_size );
        save(fullfile(setName , 'is_large_than_median' ) , 'is_large_than_median_result')
    case 'Cortical'
        [num,txt] = xlsread('DataRelease_2014-04-22.xlsx', 'DataRelease_2014-04-22','A1:CJ1571');
        gender = double( strcmp( txt(2 : end , 5) , 'F'))  + 1;
        age = num(: , 6 );
        [num,txt] = xlsread('Cortical surface for revision');
        fullSize = num( : , end );
        num = num(: , 1 : end - 1 ); % dont take the whole size
        ind = txt( 2: end , 1 );
        ind = cell2mat( cellfun(@(x) str2num( x( 4:end-1)) , ind , 'UniformOutput', false) );
        allGroups = gender( ind );
        
        outliers = xlsread('VBM_outliers.xlsx');
        legalIndices = ~ismember( ind , outliers ) ;
        ind = ind( legalIndices);
        fullSize = fullSize( legalIndices );
        allData = num( legalIndices , : );
        allGroups = allGroups( legalIndices );
        [ allData , allGroups , totInd] = divideTo2( allData , allGroups );
        fullSize = fullSize( totInd );
        orig_all_data = allData;
        [ is_large_than_median_result ] = is_large_than_median( orig_all_data , allData , ind , ind2size , median_size );
        save(fullfile(setName , 'is_large_than_median' ) , 'is_large_than_median_result')
    case 'Cortical_corrected'
        [num,txt] = xlsread('DataRelease_2014-04-22.xlsx', 'DataRelease_2014-04-22','A1:CJ1571');
        gender = double( strcmp( txt(2 : end , 5) , 'F'))  + 1;
        age = num(: , 6 );
        [num,txt] = xlsread('Cortical surface for revision');
        fullSize = num( : , end );
        num = num(: , 1 : end - 1 ); % dont take the whole size
        
        ind = txt( 2: end , 1 );
        ind = cell2mat( cellfun(@(x) str2num( x( 4:end-1)) , ind , 'UniformOutput', false) );
        allGroups = gender( ind );
        
        outliers = xlsread('VBM_outliers.xlsx');
        legalIndices = ~ismember( ind , outliers ) ;
        ind = ind( legalIndices);
        fullSize = fullSize( legalIndices );
        allData = num( legalIndices , : );
        allData = normalizeBrainSize( allData , fullSize , 'power' , allGroups);
        
        allGroups = allGroups( legalIndices );
        [ allData , allGroups , totInd] = divideTo2( allData , allGroups );
        
        fullSize = fullSize( totInd );
        orig_all_data = allData;
        [ is_large_than_median_result ] = is_large_than_median( orig_all_data , allData , ind , ind2size , median_size );
        save(fullfile(setName , 'is_large_than_median' ) , 'is_large_than_median_result')
    case 'GSP_volume'
        [num,txt] = xlsread('DataRelease_2014-04-22.xlsx', 'DataRelease_2014-04-22','A1:CJ1571');
        gender = double( strcmp( txt(2 : end , 5) , 'F'))  + 1;
        age = num(: , 6 );
        [num,txt] = xlsread('GSP_FS_volume_relevant.xlsx');
        fullSize = num( : , end );
        num = num(: , 1 : end - 1 ); % dont take the whole size
        ind = txt( 2: end , 1 );
        ind = cell2mat( cellfun(@(x) str2num( x( 4:end)) , ind , 'UniformOutput', false) );
        allGroups = gender( ind );
        
        outliers = xlsread('VBM_outliers.xlsx');
        legalIndices = ~ismember( ind , outliers ) ;
        ind = ind( legalIndices);
        fullSize = fullSize( legalIndices );
        allData = num( legalIndices , : );
        allGroups = allGroups( legalIndices );
        orig_all_data = allData;
        [ allData , allGroups , totInd] = divideTo2( allData , allGroups );
        fullSize = fullSize( totInd );
        [ is_large_than_median_result , all_ind ] = is_large_than_median( orig_all_data , allData , ind , ind2size , median_size );
        save(fullfile(setName , 'is_large_than_median' ) , 'is_large_than_median_result')
    case 'GSP_volume_divide_power'
        [num,txt] = xlsread('DataRelease_2014-04-22.xlsx', 'DataRelease_2014-04-22','A1:CJ1571');
        gender = double( strcmp( txt(2 : end , 5) , 'F'))  + 1;
        age = num(: , 6 );
        [num,txt] = xlsread('GSP_FS_volume_relevant.xlsx');
        fullSize = num( : , end );
        num = num(: , 1 : end  ); % take the whole size too, to divide
        ind = txt( 2: end , 1 );
        ind = cell2mat( cellfun(@(x) str2num( x( 4:end)) , ind , 'UniformOutput', false) );
        allGroups = gender( ind );
        
        outliers = xlsread('VBM_outliers.xlsx');
        legalIndices = ~ismember( ind , outliers ) ;
        ind = ind( legalIndices);
        fullSize = fullSize( legalIndices );
        brainSize = num( legalIndices , end );
        allData = num( legalIndices , 1 : end - 1);
        allGroups = allGroups( legalIndices );
        allData = normalizeBrainSize( allData , brainSize , 'power' , allGroups);
        orig_all_data = allData;
        [ allData , allGroups , totInd] = divideTo2( allData , allGroups );
        fullSize = fullSize( totInd );
        [ is_large_than_median_result ] = is_large_than_median( orig_all_data , allData , ind , ind2size , median_size );
        save(fullfile(setName , 'is_large_than_median' ) , 'is_large_than_median_result')
    case 'monkeys'
        num = xlsread('monkeys all landmarks.xlsx');
        data1 = myNormalize( num( 1 : 20 * 20 , :) );
        data2 = myNormalize( num( 401 : 400 + 31*20, : ) );
        data3 = myNormalize( num( 400 + 31*20 + 1 : end , : ) );
        
        allData1 = [] ;
        for i = 1 : 20 : size( data1 , 1 )
            cur = data1( i : i + 19 , : );
            dist = pdist2( cur , cur );
            vec = triu( dist );
            vec = vec( vec > 0 );
            allData1 = [ allData1 ; vec' ];
        end
        allGroups1 = ones( size( allData1 , 1 ) , 1 );
        
        allData2 = [] ;
        for i = 1 : 20 : size( data2 , 1 )
            cur = data2( i : i + 19 , : );
            dist = pdist2( cur , cur );
            vec = triu( dist );
            vec = vec( vec > 0 );
            allData2 = [ allData2 ; vec' ];
        end
        allGroups2 = 2 * ones( size( allData2 , 1 ) , 1 );
        
        allData3 = [] ;
        for i = 1 : 20 : size( data3 , 1 )
            cur = data3( i : i + 19 , : );
            dist = pdist2( cur , cur );
            vec = triu( dist );
            vec = vec( vec > 0 );
            allData3 = [ allData3 ; vec' ];
        end
        allGroups3 = 3 * ones( size( allData3 , 1 ) , 1 );
        
        allData = [ allData2 ; allData3 ];
        allGroups = [ allGroups2 ; allGroups3 ];
        allGroups = allGroups - 1;
        [ allData , allGroups , totInd] = divideTo2( allData , allGroups );
    case 'GSP_VBM'
        [num,txt] = xlsread('DataRelease_2014-04-22.xlsx', 'DataRelease_2014-04-22','A1:CJ1571');
        gender = double( strcmp( txt(2 : end , 5) , 'F'))  + 1;
        age = num(: , 4 );
        % this file is without the outliers
        [num,txt] = xlsread('GSP_VBM_1515.xlsx');
        ind = txt( 2: end , 1 );
        ind = cell2mat( cellfun(@(x) str2num( x( 4:end)) , ind , 'UniformOutput', false) );
        allData = num;
        allGroups = gender( ind );
        orig_all_data = allData;
        allAges = age( ind );
        [ allData , allGroups , totInd] = divideTo2( allData , allGroups );
        allAges = allAges( totInd );
        [ is_large_than_median_result ] = is_large_than_median( orig_all_data , allData , ind , ind2size , median_size );
        save(fullfile(setName , 'is_large_than_median' ) , 'is_large_than_median_result')
    case 'beijing'
        [num,txt,raw] = xlsread('1000_VBM_with_demographics.xlsx' , 'A2:DQ856');
        age = num( : , 4 );
        num = num( : , 6 : end );
        
        legalInd = all(~isnan(num) , 2 );
        globalData = num( legalInd , :);
        globalGroups = double( cell2mat(  cellfun(@(x) double( x(1) ) == 102 , txt(: , 1 ), 'UniformOutput', false) ) )  + 1;
        
        from = txt(: , 4 );
        un = unique( from );
        region = nan( size( from ) );
        for i = 1 : length( un )
            a = un{i};
            curInd = cell2mat( cellfun(@(x)myCompare( x , a ) , from, 'UniformOutput', false) );
            region( find( curInd == 1 ) ) = i;
        end
        
        % beijing
        beijingInd = find( region == 3 );
        beijingData = globalData( beijingInd , :);
        beijingGroups = globalGroups( beijingInd);
        allAges = age( beijingInd );
        [ allData , allGroups , ind] = divideTo2( beijingData , beijingGroups );
        allAges = allAges( ind );
    case 'cambridge'
        [num,txt,raw] = xlsread('1000_VBM_with_demographics.xlsx' , 'A2:DQ856');
        age = num( : , 4 );
        num = num( : , 6 : end );
        legalInd = all(~isnan(num) , 2 );
        globalData = num( legalInd , :);
        globalGroups = double( cell2mat(  cellfun(@(x) double( x(1) ) == 102 , txt(: , 1 ), 'UniformOutput', false) ) )  + 1;
        
        from = txt(: , 4 );
        un = unique( from );
        region = nan( size( from ) );
        for i = 1 : length( un )
            a = un{i};
            curInd = cell2mat( cellfun(@(x)myCompare( x , a ) , from, 'UniformOutput', false) );
            region( find( curInd == 1 ) ) = i;
        end
        % cambridge
        cambridgeInd = find( region == 5 );
        cambridgeData = globalData( cambridgeInd , :);
        cambridgeGroups = globalGroups( cambridgeInd);
        allAges = age( cambridgeInd );
        [ allData , allGroups , ind] = divideTo2( cambridgeData , cambridgeGroups );
        allAges = allAges( ind );
    case 'israel'
        num = xlsread( 'Israeli_(first)_sample_VBM.xlsx' , 'A2:DN281' );
        israelData = num( all(~isnan(num) , 2 ) , 3 : end);
        israelGroups = num( all(~isnan(num) , 2 ) , 1 );
        israelAges = num(all(~isnan(num) , 2 ) , 2 );
        
        [ allData , allGroups , ind] = divideTo2( israelData , israelGroups );
        allAges = israelAges( ind );
    case 'Car_Ris'
        num = xlsread('car&Ris.xlsx');
        allGroups = num(: , 2 );
        allData = num( : , 3 : end );
        [ allData , allGroups ] = divideTo2( allData , allGroups );
        
end


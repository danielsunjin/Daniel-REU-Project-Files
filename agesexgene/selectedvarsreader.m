clear;
filename = "/Users/ali/Desktop/may/sccapapr/AD_DECODE_data050922selected.csv" ;
connectomes_folder = "/Users/ali/Desktop/may/sccapapr/humandipy/";

connectomes_type = 'xlsx';
allfiles_data = readtable(filename);
%one extra line ius read
allfiles_data=allfiles_data(1:(size(allfiles_data,1)-1),:);


data_source = 2;

if data_source ==2
    outpath='/Users/ali/Desktop/may/sccapapr/results'
    if ~exist(outpath, 'dir')
       mkdir(outpath)
    end
end

genotypekeySet = {'APOE22', 'APOE23' 'APOE33', 'APOE34' , 'APOE44', 'APOE22HN', 'APOE33HN', 'APOE44HN', 'HN'};
genotypevalueSet = [2 2 3 4 4 5 6 7 8];
geno = containers.Map(genotypekeySet,genotypevalueSet);

sexkeySet = {'M', 'male' ,'F', 'female'};
sexvalueSet = [1 1 2 2];
sex = containers.Map(sexkeySet,sexvalueSet);

%treatment = {'treadmill', 'wheel_only', 'sedentary'};
%treatmentvals = [1 1 3]; %only seden and nonseden
%treatmentvals = [1 2 0]; %all three groups


diets = {'Control', 'HFD'};
dietvals = [1 2];
diet = containers.Map(diets,dietvals);
%


%{
response_table = table('Size',[size(allfiles_data,1) 28],'VariableNames',{ 'MRI_Exam', 'sex', 'age', 'Weight', 'risk_for_ad', 'genotype', 'Systolic', ...
    'MOCA_Visuospatial',	'MOCA_Naming',	'MOCA_Attention_Digits',	'MOCA_Attention_Letters',	'MOCA_Attention_Substraction',	'MOCA_Language1',	...
    'MOCA_Language2',	'MOCA_Abstraction',	'MOCA_DelayedRecall',	'MOCA_Orientation',	'MOCA_TOTAL','Im_BensonTotal' ,'Delay_BensonTotal' ...
    ,'Composite_Pleasantness',	'Composite_Intensity',	'Composite_Familiarity',	'Composite_Nameability',	'PrecentCorrectRecall',	'Recognized', 'RAVLT_PERCENTFORGETTING', 'pulse'}, 'VariableTypes',{'double', 'double','double','double','double', ...
    'double', 'double', 'double','double', 'double','double','double', 'double', 'double', 'double', 'double','double','double', 'double', 'double', 'double', 'double', 'double',  'double', 'double', 'double', 'double',  'double'});
response_array_init = zeros([size(allfiles_data,1) 7]);
%} 




genetemp=allfiles_data(:,'genotype');
sextemp=allfiles_data(:,'sex');
allfiles_data=removevars(allfiles_data,{'Subject', 'genotype', 'Risk', 'sex'});
sexandgenetable=table('Size',[size(allfiles_data,1) 2],'VariableNames',{'sex', 'genotype'}, 'VariableTypes',{'double', 'double'});



for i = 1:size(sexandgenetable,1)
    
   sexandgenetable(i,1)=array2table(sex(cell2mat(table2array(  sextemp(i,1)  ))));
   sexandgenetable(i,2)= array2table(geno(cell2mat(table2array(  genetemp(i,1)  ))));

end

allfiles_data=[sexandgenetable allfiles_data];

response_array_init=allfiles_data;

response_table=response_array_init;


%{

for i = 1:size(allfiles_data,1)
        temp=table2array(allfiles_data(i,'MRI_Exam'));
        %temp=regexp(temp,'\d+(\.)?(\d+)?','match');
        %temp=[temp{:}];
        if isempty(temp)==0
           %if  table2array(allfiles_data(i,'risk_for_ad')) <2 %remove mci and ad
            %if geno(cell2mat(table2array(allfiles_data(i,'Genotype')))) <5 &geno(cell2mat(table2array(allfiles_data(i,'Genotype'))))>2
                %if table2array(allfiles_data(i,'Perfusion'))<datetime(2016,01,01)
 

%{
temp=temp(1);
response_array_init(i,1) =temp;
response_array_init(i,2:size(allfiles_data,2))=table2array(allfiles_data(i,2:size(allfiles_data,2)));



    response_array_init(i,2) = sex(cell2mat(table2array(allfiles_data(i,'sex'))));
    response_array_init(i,3) = table2array(allfiles_data(i,'age'));
    response_array_init(i,4) = table2array(allfiles_data(i,'Weight'));
    response_array_init(i,5) =table2array(allfiles_data(i,'risk_for_ad'));
    response_array_init(i,6) = geno(cell2mat(table2array(allfiles_data(i,'genotype'))));
    response_array_init(i,7) =table2array(allfiles_data(i,'Systolic'));
    response_array_init(i,8) =table2array(allfiles_data(i,'MOCA_Visuospatial'));
    response_array_init(i,9) =table2array(allfiles_data(i,'MOCA_Naming'));
    response_array_init(i,10) =table2array(allfiles_data(i,'MOCA_Attention_Digits'));
    response_array_init(i,11) =table2array(allfiles_data(i,'MOCA_Attention_Letters'));
    response_array_init(i,12) =table2array(allfiles_data(i,'MOCA_Attention_Substraction'));
    response_array_init(i,13) =table2array(allfiles_data(i,'MOCA_Language1'));
    response_array_init(i,14) =table2array(allfiles_data(i,'MOCA_Language2'));
    response_array_init(i,15) =table2array(allfiles_data(i,'MOCA_Abstraction'));
    response_array_init(i,16) =table2array(allfiles_data(i,'MOCA_DelayedRecall'));
    response_array_init(i,17) =table2array(allfiles_data(i,'MOCA_Orientation'));
    response_array_init(i,18) =table2array(allfiles_data(i,'MOCA_TOTAL'));
    response_array_init(i,19) =table2array(allfiles_data(i,'Im_BensonTotal'));
    response_array_init(i,20) =table2array(allfiles_data(i,'Delay_BensonTotal'));
    response_array_init(i,21) =table2array(allfiles_data(i,'Composite_Pleasantness'));
    response_array_init(i,22) =table2array(allfiles_data(i,'Composite_Intensity'));
    response_array_init(i,23) =table2array(allfiles_data(i,'Composite_Familiarity'));
    response_array_init(i,24) =table2array(allfiles_data(i,'Composite_Nameability'));
    response_array_init(i,25) =table2array(allfiles_data(i,'PrecentCorrectRecall'));
    response_array_init(i,26) =table2array(allfiles_data(i,'Recognized'));
    response_array_init(i,27) =table2array(allfiles_data(i,'RAVLT_PERCENTFORGETTING'));
    response_array_init(i,28) =table2array(allfiles_data(i,'Pulse'));
%}
     %{ 
    % lest do opposite direction
    response_array_init(i,2) = max(sexvalueSet)-sex(cell2mat(table2array(allfiles_data(i,'sex'))));
    response_array_init(i,3) = max(table2array(allfiles_data(:,'age')))-table2array(allfiles_data(i,'age'));
    response_array_init(i,4) = max(table2array(allfiles_data(:,'Weight')))-table2array(allfiles_data(i,'Weight'));
    response_array_init(i,5) = max(table2array(allfiles_data(:,'risk_for_ad')))-table2array(allfiles_data(i,'risk_for_ad'));
    response_array_init(i,6) = 4-geno(cell2mat(table2array(allfiles_data(i,'genotype'))));
     %}
    
    response_table(i,1) = num2cell(response_array_init(i,1));
    response_table(i,2) = num2cell(response_array_init(i,2));
    response_table(i,3) = num2cell(response_array_init(i,3));
    response_table(i,4) = num2cell(response_array_init(i,4));
    response_table(i,5) = num2cell(response_array_init(i,5));
    response_table(i,6) = num2cell(response_array_init(i,6));
    response_table(i,7) = num2cell(response_array_init(i,7));
    response_table(i,8) = num2cell(response_array_init(i,8));
    response_table(i,9) = num2cell(response_array_init(i,9));
    response_table(i,10) = num2cell(response_array_init(i,10));
    response_table(i,11) = num2cell(response_array_init(i,11));
    response_table(i,12) = num2cell(response_array_init(i,12));
    response_table(i,13) = num2cell(response_array_init(i,13));
    response_table(i,14) = num2cell(response_array_init(i,14));
    response_table(i,15) = num2cell(response_array_init(i,15));
    response_table(i,16) = num2cell(response_array_init(i,16));
    response_table(i,17) = num2cell(response_array_init(i,17));
    response_table(i,18) = num2cell(response_array_init(i,18));
    response_table(i,19) = num2cell(response_array_init(i,19));
    response_table(i,20) = num2cell(response_array_init(i,20));
    response_table(i,21) = num2cell(response_array_init(i,21));
    response_table(i,22) = num2cell(response_array_init(i,22));
    response_table(i,23) = num2cell(response_array_init(i,23));
    response_table(i,24) = num2cell(response_array_init(i,24));
    response_table(i,25) = num2cell(response_array_init(i,25));
    response_table(i,26) = num2cell(response_array_init(i,26));
    response_table(i,27) = num2cell(response_array_init(i,27));
    response_table(i,28) = num2cell(response_array_init(i,:));

  % response_table(i,7) =allfiles_data(i,'Perfusion');
  % response_table(i,8) =allfiles_data(i,'CIVM_ID');
                %end

            %end

           %end     
    end
end

%}
response_table=rmmissing(response_table); % remove na rows
%ismissing(response_table)


if strcmp(connectomes_type,'xlsx')
    getpath = join([connectomes_folder,'*connec*.xlsx'],"");
elseif strcmp(connectomes_type,'mat')
    getpath = join([connectomes_folder,'*.mat'],"");
end


%noreadcsf=[148 152 161 314 318 327]; % dont read csf

files=dir(getpath);
file = files(1);
  if strcmp(connectomes_type,'xlsx')
                temp = readtable(join([connectomes_folder,file.name],""));
            elseif strcmp(connectomes_type,'mat')
                temp = load(join([connectomes_folder,file.name],""));  
                temp=temp.connectivity;
  end
dim=size(temp,1); % dimension
%dim=dim-size(noreadcsf,2); % no csf in dimension

connectivity = zeros(dim,dim,size(response_table,1));

files = dir(getpath);
subjlist = zeros(size(response_table,1),1);
notfoundlist = zeros(size(response_table,1),1);
j=1;
l=1;
for i = 1:size(response_table,1)
    subjname = response_table{i,'MRI_Exam'};
  % if  ~(subjname==3394)
    found = 0;
    for file = files'
        subj = strsplit(file.name,'_');
        subj = subj{1};
        subj = subj(2:6);
        if  subjname == str2double(subj)
            if strcmp(connectomes_type,'xlsx')
                csv = readtable(join([connectomes_folder,file.name],""));
                %csv.Var1{84} = 'ctx-rh-insula';
                csv = removevars(csv,{'Var1'});
                csv = table2array(csv);
                connectivity(:,:,j) = csv;
                found = 1;
                break
            elseif strcmp(connectomes_type,'mat')
                A = load(join([connectomes_folder,file.name],""));  
                connectivity(:,:,j) =  A.connectivity;
                found = 1;
                break
            end
        end
    end
    if found==1
        %display('found '+ string(subjname))
        subjlist(j) = subjname;
        j = j + 1;
    else
        %display('did not find '+ string(subjname))
        notfoundlist(l) = subjname;
        l = l + 1;
    end
  % end 
end

subjlist = subjlist(subjlist ~= 0);
notfoundlist = notfoundlist(notfoundlist ~= 0);
connectivity = connectivity(:,:,1:size(subjlist,1));



response_array = zeros(size(subjlist,1),size(response_array_init,2));
i=1;
for k = 1:numel(response_array_init(:,"MRI_Exam"))
    if ismember(table2array(response_array_init(k, "MRI_Exam")),subjlist)
        response_array(i,:) = table2array(response_array_init(k,:));
        i=i+1;
    end
end

varnames = response_array_init.Properties.VariableNames;

%subselect = '_genotype_4';
subselect = '';
%subselect = '_NCgt40';
%subselect = 'norisk';

if size(subselect,2)>0
    if contains(subselect,'genotype')
        if contains(subselect,'3')
            APOE3 = response_array(:,2)==3;
            connectivity = connectivity(:,:,APOE3);
            response_array = response_array(APOE3,:);
            subjlist = subjlist(APOE3);
        elseif contains(subselect,'4')
            APOE4 = response_array(:,2)==4;
            connectivity = connectivity(:,:,APOE4);
            response_array = response_array(APOE4,:);
            subjlist = subjlist(APOE4);
        end
    elseif contains(subselect,'_NCgt40')
        %NCgt40 = find((response_array(:,3)>40).*(response_array(:,5)<2)); % response(response(:,5)==2, 1); # better be nonzero or code crashes
        NCgt40 = find((response_array(:,3)>40)); % response(response(:,5)==2, 1); # better be nonzero or code crashes
        connectivity = connectivity(:,:,NCgt40);
        response_array =response_array(NCgt40,:);
        subjlist = subjlist(NCgt40);
    end
     elseif contains(subselect,'norisk')
        %NCgt40 = find((response_array(:,3)>40).*(response_array(:,5)<2)); % response(response(:,5)==2, 1); # better be nonzero or code crashes
        norisk = find((response_array(:,5)<2)); % response(response(:,5)==2, 1); # better be nonzero or code crashes
        connectivity = connectivity(:,:,norisk);
        response_array =response_array(norisk,:);
        subjlist = subjlist(norisk);
end


response_arrayraw=response_array;
connectivityraw=connectivity;





%{

age=response_array(:,3); risks=response_array(:,[2 4 5 6]); %risks= [ ones(size(risks, 1),1) risks ]; % intercept needs one in design matrix
for i=1:size(risks,2)
[~,~,r]=regress(risks(:,i), age); 
risks(:,i)=r; % replace age by the residual of this regression
end

 response_array(:,[2 4 5 6])=risks;  %put them back
%}


%}




%age=response_array(:,3); 
%sex=response_array(:,2); 
%risks=response_array(:,[4 5 6]); %risks= [ ones(size(risks, 1),1) risks ]; % intercept needs one in design matrix
%{
for i=1:size(risks,2)
[~,~,r]=regress(risks(:,i), [ones(size(sex)) sex age sex.*age] ); 
risks(:,i)=r; % replace age by the residual of this regression
end
%}



origtraingle=NaN( size(connectivity,3)   ,  (size(connectivity,1)*(size(connectivity,2)-1))/2    );

for i=1:size(connectivity,3)  %extract the lower triangle
        A=connectivity(:,:,i);
        At = A.';
        m = tril(true(size(At)),-1);
        v = At(m).';
        if std(v)==0; display(i); end % no column with all zero values
        origtraingle(i,:)=v;
end


%age=response_array(:,3); 
%sex=response_array(:,2); 
%{
regressor=response_array(:,2);%regress on age 

for j=1:size(origtraingle,2)  % each connectivity is regressed to age in a ismple lin regression
%[~,~,r]=regress(origtraingle(:,j),[ones(size(sex)) sex age sex.*age]);
[~,~,r]=regress(origtraingle(:,j),[ones(size(age)) regressor]); 

origtraingle(:,j)=r;
end   

%}

% put them back in
for i=1:size(connectivity,3) 
        A=connectivity(:,:,i);
        BB=A*0;
        BB(m)=origtraingle(i,:);
        BB=BB.';
        connectivity(:,:,i)=BB+BB.';
end
%}
%}
%%%%

%}

%{


origtraingle=NaN( size(connectivity,3)   ,  (size(connectivity,1)*(size(connectivity,2)-1))/2    );

for i=1:size(connectivity,3)  %extract the lower triangle
        A=connectivity(:,:,i);
        At = A.';
        m = tril(true(size(At)),-1);
        v = At(m).';
        if std(v)==0; display(i); end % no column with all zero values
        origtraingle(i,:)=v;
end

%}












response_array_path = join([outpath 'response_array' subselect '.mat'],"");
response_array_pathraw = join([outpath 'response_arrayraw' subselect '.mat'],"");
response_table_path= join([outpath 'response_table' subselect '.mat'],""); 
connectomes_path = join([outpath 'connectivity_all' '_ADDecode' '_Dipy' subselect '.mat'],"");
connectomes_pathraw = join([outpath 'connectivity_allraw' '_ADDecode' '_Dipy' subselect '.mat'],"");
response_tablename_path= join([outpath 'response_tablename' subselect '.mat'],""); 

trainglepath = join([outpath 'traingle' subselect '.mat'],"");


save(response_array_path, 'response_array');
save(response_array_pathraw, 'response_arrayraw');
save(response_table_path, 'response_table');
save(connectomes_path, 'connectivity', 'subjlist');
save(connectomes_pathraw, 'connectivityraw', 'subjlist');
save(trainglepath, 'origtraingle')
save(response_tablename_path, 'varnames')

varnames = response_array_init.Properties.VariableNames;


%{
%hstogram of ages with edge of bins:
edge1=35;
edge2=55;
edge3=77;
binpartition=[0 edge1 edge2 edge3];
agegenehist=[response_array_init(:,3)  response_array_init(:,2)  ]
hist( agegenehist.agegenehist()  );
%}

notfounddata=NaN( size(notfoundlist,1)   ,  2   );
for j=1:size(notfoundlist,1) 
    for i=1:size(response_array_init,1) 
        if notfoundlist(j,:)==response_array_init(i,1)
        notfounddata(j,:)=response_array_init(i,[1 6]);
        end
    end
end

%{
       temp=table2array(allfiles_data(i,'Perfusion'));
        temp=regexp(temp,'\d+(\.)?(\d+)?','match');
        temp=[temp{:}];
%}
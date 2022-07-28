
library(readxl)
library(dplyr)
library(stringr)

path_master='/Users/daniel/Downloads/MasterSheet_Experiments2021.xlsx'
data=read_xlsx(path_master, sheet = '18ABB11_readable02.22.22_BJ_Cor' ) %>% mutate(BadeaID = str_replace(BadeaID, '-', '_')) %>% 
  mutate(BadeaID = str_replace(BadeaID, ':0', '')) %>% mutate(BadeaID = str_replace(BadeaID, 'Cage ', ''))  %>% mutate(BadeaID = trimws(BadeaID))
datatemp=data%>%dplyr::select(BadeaID,Genotype, Sex, Diet, Age_Months)#subselect
#nchar(datatemp[111,1])
datatemp=na.omit(datatemp)
datatemp[nchar(datatemp$BadeaID)<=2,]=matrix(NA,1,dim(datatemp)[2])
datatemp=na.omit(datatemp)
#datatemp[substr(datatemp$BadeaID,1,1)!="N",]=matrix(NA,1,dim(datatemp)[2])
#datatemp=na.omit(datatemp) ## ommit all na and zero character dwi and died durring
#datatemp$BadeaID=as.numeric(substr(datatemp$BadeaID,2,6)) # make dwi numeric
#datatemp=datatemp[datatemp$Genotype!="HN",]

####
path_connec="/Users/daniel/Downloads/FC_matrices/"
file_list=list.files(path_connec)
temp_conn= read.csv( paste0(path_connec,file_list[1]) )
temp_conn=temp_conn[,2: dim(temp_conn)[2]]
connectivity=array( NA ,dim=c(dim(temp_conn)[1],dim(temp_conn)[2],dim(datatemp)[1]))
dim(connectivity)

notfound=0
##read connec
for (i in 1:dim(connectivity)[3]) {
  
  temp_index=which(datatemp$BadeaID[i]==str_replace(file_list, '.csv', ''))
  if (length(temp_index)>0) 
  {
  temp_connec=read.csv( paste0(path_connec,file_list[temp_index]) )
  temp_connec=temp_connec[,2:dim(temp_connec)[2]]
  #colnames(temp_connec)=NA
  connectivity[,,i]=as.matrix(temp_connec)
  }
  else
    notfound=c(notfound, datatemp$BadeaID[i])
  
}

notfound=notfound[2:length(notfound)]
not_found_index=which( datatemp$BadeaID  %in%  notfound )

datatemp=datatemp[-not_found_index,]
connectivity=connectivity[,,-not_found_index]
sum(is.na(connectivity))

load("/Users/daniel/Downloads/behavior.rda")
behavioral_data <- behavioral_data %>%
  mutate(BadeaID = Animal_ID) %>%
  select(BadeaID, Day0_Learning_Slope, Day1_Contextual_Freezing, Day2_Tone_Freezing)

response=left_join(datatemp, behavioral_data, by='BadeaID')
write.csv(response, "/Users/daniel/Downloads/behavior.csv", row.names = TRUE)
#setwd(system("pwd", intern = T) )
save(response, file="response.rda")
noreadcsf=c(53, 70, 110, 111, 137) # dont read csf already in matlab



#remove white matter

# chasspath='/Users/ali/Desktop/Jul/apoe/CHASSSYMMETRIC2Legends09072017annotated.xlsx'
# chass=read_xlsx(chasspath , sheet='thetruth (2)')
# indecies=chass$index
# which=which(chass$Level_4=="white_matter")
# index_white=indecies[which]
# noreadcsf=c(noreadcsf,index_white)
# noreadcsf

connectivity=connectivity[-noreadcsf,-noreadcsf,]
dim(connectivity)

library(reticulate)
np = import("numpy")
np$save("connectivity.npy",r_to_py(connectivity))
save(connectivity, file="connectivity.rda")
save(noreadcsf, file="noreadcsf.rda")



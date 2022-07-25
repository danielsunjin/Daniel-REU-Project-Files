
# run this right after running Step A matlab that would produce the connectivity data by reading and re-arranging
# install.packages("R.matlab")
# library(R.matlab)
# path="/Users/ali/Desktop/may/sccapapr/resultsconnectivity_all_ADDecode_Dipy.mat"
# path2="/Users/ali/Desktop/may/sccapapr/resultsresponse_array.mat"

# 
# data=readMat(path)
# connectivity=data$connectivity
# 
# noreadcsf=c(148,152,161,314,318,327) # dont read csf already in matlab

#temp=connectivity[-noreadcsf,-noreadcsf,1]
temp=connectivity[,,1]
indexlower=lower.tri(temp, diag=FALSE)
indexlowertrue=which(indexlower==TRUE)
temp=temp[indexlower]
len=sum(indexlower)  
dim(connectivity)


# data2=readMat(path2, fixNames=TRUE)
# response=data2$response.array 
# 'MRI_Exam', 'sex', 'age', 'Weight', 'risk_for_ad', 'genotype'

#riskfactors=matrix(NA,  dim(response)[1], (dim(response)[2]-1))
riskfactors=matrix(NA,  (dim(response)[1]), (dim(response)[2]-1)) #
# 'sex', 'age', 'Weight', 'risk_for_ad', 'genotype'
#sum(riskfactors[,2]==3)
riskfactors=response[,2:dim(response)[2]]

# subjnameofconnectivity=data$subjlist

# for (i in 1:dim(riskfactors)[1]) {
#   ind=which(response[i,1]==subjnameofconnectivity)
#   if (i!=ind) cat("here", i)
#   #riskfactors[ind,]=response[ind, 2:(dim(response)[2]) ]
#   temp=response[ind, 1:(dim(response)[2]) ];
#   temp=temp[-c(9)];
#   riskfactors[ind,]= temp;
# }


###covar names as well:
# pathnames0="/Users/ali/Desktop/may/sccapapr/resultsresponse_tablename.mat"
# temp=readMat(pathnames0, fixNames=T)
# temp=unlist(temp$varnames)
# temp=temp[-c(9)]
# colnames(riskfactors)=temp
#riskfactors=riskfactors[,-c(3)] # no weight
# riskfactors=riskfactors[,c(1:10)] # phisio
# riskfactorsorig=riskfactors
# riskfactors=riskfactors[,c(1,2,9)] #only sex age gene and family
# #riskfactors=riskfactors[,-c(3,6,8)] # no bmi if weight is there high corrs also no sys and pulse
# #also no height between height and sex

# cor=cor(riskfactors)

# cor[lower.tri(cor, diag = T)]=0
# indd=which(abs(cor)>0.4 & abs(cor)<1, arr.ind = TRUE)
# corresult=matrix(NA,dim(indd)[1],3)
# for (i in 1:dim(indd)[1]) {
#   
#   corresult[i,]=c(colnames(cor)[indd[i,1]],colnames(cor)[indd[i,2]], cor[indd[i,1], indd[i,2]] )
#   
# }
# library(xlsx)
# 
# write.xlsx2(corresult, "cor.xlsx")
# 



######## pull all ad as mci
# famindex=which(colnames(riskfactorsorig)=="risk_for_ad")
# tempaaa=riskfactorsorig[,famindex]
# tempaaa[tempaaa==3]=2
# riskfactorsorig[,famindex]=tempaaa
#########


#riskfactorind=riskfactors>0
#sum(riskfactorind)
#riskfactors=riskfactors[riskfactorind,] # removing riskfactor 2,3


image=matrix(NA,  dim(connectivity)[3], len) # -6 becasue of cfs removal

for (i in 1:dim(connectivity)[3]){
  #temp=connectivity[-noreadcsf,-noreadcsf,i]
  temp=connectivity[,,i]
  indexlower=lower.tri(temp, diag=FALSE)
  temp=temp[indexlower]
image[i,]=temp
}
dim(image)
sum(is.na(image))

#image=image[riskfactorind,]

#recordzerocols # these are zero cols that we remove and add at the edn 
# we rmove now because cca needs to standardize and sd of them are zero
indd=0
for (i in 1:dim(image)[2]) if(sd(image[,i])==0 ) {indd=rbind(indd,i);  cat ( i , sd(image[,i]), "\n" );}
if (length(indd)>1){
indd=indd[2:dim(indd)[1]]
image=image[,-indd] }


inddz=0
for (i in 1:dim(riskfactors)[2]) if(sd(riskfactors[,i])==0 ) {inddz=rbind(indd,i);  cat ( i , sd(riskfactors[,i]), "\n" );}
if (length(inddz)>1){
inddz=inddz[2:dim(inddz)[1]]
riskfactors=riskfactors[,-inddz]
}



# ageind=which(colnames(riskfactors)=="age")
# medianage=median(riskfactors[,ageind])
# agecat=riskfactors[,ageind];agecat[agecat<=medianage]=1;agecat[agecat>medianage]=2   #agecat
#riskfactors=riskfactors[,c(5,9)] # NO WEIGHT it is sex, age, diet, gene
#riskfactors[,2]=agecat;





#lets run
## Not run:
#install.packages("PMA")
#install.packages("https://gitlab.oit.duke.edu/am983/PMA2/-/archive/master/PMA2-master.tar.gz", repos = NULL, type="source")
library(PMA2)





set.seed(3189) #for reproductivity

# Can run CCA with default settings, and can get e.g. 3 components
#??glmnet

Sex=riskfactors$Sex
Sex[Sex=="female"]=-1; Sex[Sex=="male"]=1
Sex=as.numeric(Sex)

Diet=riskfactors$Diet
Diet[Diet=="Control"]=-1; Diet[Diet=="HFD"]=1
Diet=as.numeric(Diet)

riskfactors=cbind(Sex, Diet)


# this is seecing a llambda for traits so it would penelize the most without sparisity 
for (i in 100:1) {
  zlamb=i/100
  out <- CCA(x=image,z=riskfactors,typex="standard",typez="standard", penaltyz = zlamb)
  numzerv=sum(out$v==0)
  #if (numzerv>0.6*length(out$v) ) { i=i+1;  zlamb=i/100;  break }
  if (numzerv>0 ) { i=i+2;  zlamb=i/100;  break }
}

 numzeru=sum(out$u!=0)
xlamb=out$penaltyx
nonsparsu=0.999
persnonsparse=floor((1-nonsparsu)*length(out$u))
while (numzeru>persnonsparse) {
  xlamb=0.7*xlamb
  out2 <- CCA(x=image,z=riskfactors,typex="standard",typez="standard", penaltyz = zlamb, penaltyx = xlamb)
  numzeru=sum(out2$u!=0); 
}
 
 for (i in 100:1) {
   zlamb=i/100
   out <- CCA(x=image,z=riskfactors,typex="standard",typez="standard", penaltyz = zlamb, penaltyx = xlamb)
   numzerv=sum(out$v==0)
   if (numzerv>0 ) { i=i+3;  zlamb=i/100;  break }
 }

# 
# 
# numzerv=sum(out$v!=0)
# nonsparsv=0.1
# persnonsparse=floor((1-nonsparsv)*length(out$v))
# while (numzerv>persnonsparse) {
#   zlamb=0.9*zlamb
#   out2 <- CCA(x=image,z=riskfactors,typex="standard",typez="standard", penaltyz = zlamb, penaltyx = xlamb)
#   numzerv=sum(out2$v!=0); 
# }







out2 <- CCA(x=image,z=riskfactors,typex="standard",typez="standard", penaltyz = zlamb, penaltyx = xlamb)
out2
sum(out$u!=0)
out2$v

perm.out <- CCA.permute(x=image,z=riskfactors,typex="standard",typez="standard",nperms=101, standardize=TRUE, SD=TRUE, penaltyxs = xlamb, penaltyzs = zlamb)

# if you dont want to run the 1000 permuttion again just load the 1000 permutation R data and run from here:



print(perm.out)

plot(perm.out)
#out <- CCA(x=image,z=riskfactors,typex="standard",typez="standard",
#           penaltyx=perm.out$bestpenaltyx/20,penaltyz=perm.out$bestpenaltyz,
#           v=perm.out$v.init)
out <- CCA(x=image,z=riskfactors,typex="standard",typez="standard",
           penaltyx=perm.out$bestpenaltyx,penaltyz=perm.out$bestpenaltyz, UVperms= perm.out$UVperms, allpenaltyxs = perm.out$penaltyxs)




print(out) # could do print(out,verbose=TRUE)
#print(image[out$u!=0]) 

u=out$u
# out$standardu[out$standardu!=0] #if all inf then all are significant
# out$standardv[out$standardv!=0] #none are inf becasue effect of sex is taken oiut
# out$SDu[out$SDu!=0]
#u=coef
# pvalsv=out$pvalsv
v=out$v
#out$pvalsv[out$pvalsv!=1]
# out$pvalsu[out$pvalsu!=1]
# max(out$pvalsu[out$pvalsu!=1])

# stdv=out$standardv

sum(u==0)
#len=length(u)
sum(u!=0)
u[u!=0]
sum(u==0)/len #sparsity 

uout=matrix(NA, dim(u)[1]+length(indd),1 )
#put those zeros back
if ( indd!=0){
uout[indd]=0
uout[-indd]=u}
if ( indd==0){  uout= u}
#uout[-indd]=coef

#make it square again



#take a look at zero rois through all subjects:

# ##### Example to reverse lower tri
# A=matrix(4*1:16,4,4)
# indexample=lower.tri(A, diag=FALSE)
# indexampletrue=which(indexample==TRUE)
# tempex=A[indexample]
# #position 2 of tempex is "#12" A(3,1)
# posindex=2
# tempex[posindex]
# indexampletrue[posindex]
# A[indexampletrue[posindex]]
# # multiple positions
# # position c(2,4) tempex of it are c(12,28)
# posindex=c(2,4)
# tempex[posindex]
# indexampletrue[posindex]
# A[indexampletrue[posindex]]
# # works just fine

indd
indexlowertrue=which(indexlower==TRUE)
temp[indd]
indexlowertrue[indd]

connectivityexample=connectivity[,,1]
connectivityexample[indexlowertrue[indd]] ##yes the're them
connectivityexample[indexlowertrue[indd]]="zeros" # lest make them known for a special word
indexofzeros=which(connectivityexample=="zeros", arr.ind=TRUE)

indexofzeros[,1]
indexofzeros

# #lest check really quick:
# for (j in 1:dim(indexofzeros)[1]) { 
# for (i in 1:dim(connectivity)[3]) {  cat(  "subject", i, "at position", indexofzeros[j,] , connectivity[matrix(c(indexofzeros[j,],i),1,3)] , "\n")
# }
# } ## yes theyre all odly zeros

#results of connectivities that matter:
nonzeroindex=which(uout!=0)
connectivityexample=connectivity[,,1]
connectivityexample[]=0
connectivitvals=connectivityexample
nonzerouout=uout[uout!=0]
for (i in 1:length(nonzeroindex)) {
  connectivityexample[indexlowertrue[nonzeroindex[i]]]=c("nonzero") # lest make them known for a special word
  connectivitvals[indexlowertrue[nonzeroindex[i]]]=nonzerouout[i] #store their coefitient values
}


library('igraph');
connectivitvalsones=connectivitvals
t=which(connectivitvalsones!=0, arr.ind=TRUE)
t <- cbind(t, connectivitvals[which(connectivitvals!=0,arr.ind=TRUE)]) 
t.graph=graph.data.frame(t,directed=F)
E(t.graph)$color <- ifelse(E(t.graph)$V3 > 0,'blue','red') 
#t.names <- colnames(cor.matrix)[as.numeric(V(t.graph)$name)]
minC <- rep(-Inf, vcount(t.graph))
maxC <- rep(Inf, vcount(t.graph))
minC[1] <- maxC[1] <- 0
l <- layout_with_fr(t.graph, minx=minC, maxx=maxC,
                    miny=minC, maxy=maxC)      


#pathnames='/Users/ali/Desktop/apr/sccapapr/anatomyInfo_whiston_new.csv'
#datanmes=read.csv(pathnames, header = TRUE, sep = ",", quote = "")
#datanmes$ROI




#noreadcsf=c(148,152,161,314,318,327) # dont read csf already in matlab

#datanmes=datanmes[-noreadcsf]

#datanmess=datanmes$ROI[-noreadcsf] # remove csf
#datanmess=datanmes$ROI

datanamess=seq(1:360)
noreadcsf=c(57, 77, 118, 119, 146) # dont read csf already in matlab
datanamess=datanamess[-noreadcsf]




par(mfrow=c(1,1))

#set.vertex.attribute(t.graph, "name", value=datanmes$ROI   )


#jpeg("nets", units="in", width=10, height=5, res=300)  
#png("short2dnet.png", units="in", width=10, height=5, res=400)  

plot(t.graph, layout=l, 
     rescale=T,
     asp=0,
     edge.arrow.size=0.1, 
     vertex.label.cex=0.8, 
     vertex.label.family="Helvetica",
     vertex.label.font=4,
     #vertex.label=t.names,
     vertex.shape="circle", 
     vertex.size=5, 
     vertex.color="deepskyblue2",
     vertex.label.color="black", 
     #edge.color=E(t.graph)$color, ##do not need this since E(t.graph)$color is already defined.
     edge.width=as.integer(cut(abs(E(t.graph)$V3), breaks = 5)))

#dev.off()
connectivitvals=connectivitvals+t(connectivitvals) #symetric


nonzeroposition=which(connectivityexample=="nonzero", arr.ind=TRUE)
getwd()
filename=paste(getwd(), "/", "valandpos.mat", sep = "")
#writeMat(filename, nonzeroposition = nonzeroposition, connectivitvals = connectivitvals , oddzeroposition=indexofzeros)







subnets=groups(components(t.graph))
subnetsresults=vector(mode = "list", length = length(subnets))
colsumabs=colSums(abs(connectivitvals))
colsum=colSums(connectivitvals)
#
# for (i in 1:length(subnets)) {
#   temp=subnets[[i]]
#   temp=as.numeric(temp)
#   net=matrix(NA,8,length(temp) )
#   net[2,]=datanmess[temp]
#   net[1,]=as.numeric(temp)
#   net[3,]= as.numeric( colsumabs[temp]   )
#   net[4,]= as.numeric( colsum[temp]   )
#   tt=as.numeric(net[1,])
#   #tt=c(1,200)
#   indofleftright=tt>=164
#   net[5,][indofleftright]="Right"
#   net[5,][!indofleftright]="Left"
#   net[6,]=sum(as.numeric(net[4,]))
#   net[7,]=sum(as.numeric(net[3,]))
#   for (j in 1:length( net[8,])) {
#     tempindex=which(datanmes$ROI %in% net[2,j]  )
#     if (net[5,j]=="Right" ) {net[8,j]= max(tempindex) } else { net[8,j]=min(tempindex) }
#   }
#   subnetsresults[[i]]=net
# }

#for (i in 1:length(subnetsresults)) {
#  net=subnetsresults[i]
#  print(net[[1]][1:2,])
#}


for (i in 1:length(subnetsresults)) {
  net=subnetsresults[i]
  cat( i,'th sub-net: the summation of all edges in this sub-net is' ,sum(as.numeric(net[[1]][4,])), 'and summation of absolut values of all edges in this subnet is', sum(as.numeric(net[[1]][3,])),'\n')
  cat(  'the fsirst row is the Region #, second row is the name of Region, the third row is the sum of absulote values of the edges of each region, and the last row is the sum of edges of each region \n')
  print(net)
  cat( '\n \n \n')
}


capture.output(subnetsresults, file = "subnet.txt")


#write.csv(subnetsresults, row.names = T)
#leftright=datanmes$Bigpart

####################3
for (i in 1:length(subnets)) {
  temp=subnets[[i]]
  temp=as.numeric(temp)
  net=matrix(NA,8,length(temp) )
  net[1,]=as.numeric(temp)
  tt=as.numeric(net[1,])
  #tt=c(1,200)
  #indofleftright=tt>=164
  #net[5,][indofleftright]="Right"
  #net[5,][!indofleftright]="Left"
  
  
  net[2,]=datanamess[temp]
  #net[5,]=leftright[temp]
  #net[1,]=paste(net[1,],net[5,])
  net[3,]= as.numeric( colsum[temp]   )
  net[4,]= as.numeric( colsumabs[temp]   )
  net[6,]=sum(as.numeric(net[4,]))
  net[7,]=sum(as.numeric(net[3,]))
  # for (j in 1:length( net[8,])) {
  #   tempindex=which(datanmes$ROI %in% net[2,j]  )
  #   if (net[5,j]=="Right" ) {net[8,j]= max(tempindex) } else { net[8,j]=min(tempindex) }
  # }
  subnetsresults[[i]]=net 
}

#install.packages("xlsx")
library(xlsx)


for (i in 1:length(subnetsresults)){
  net=t(subnetsresults[[i]])
  write.xlsx2(net, "nets.xlsx", sheetName =  paste0(i), append=TRUE )
}



# install.packages("vioplot")
library("vioplot")




 for (i in 1:length(subnets)) {
   temp=subnets[[i]]
   temp=as.numeric(temp)
   net=matrix(NA,8,length(temp) )
   net[2,]=datanmess[temp]
   net[1,]=as.numeric(temp)
   net[3,]= as.numeric( colsumabs[temp]   )
   net[4,]= as.numeric( colsum[temp]   )
   tt=as.numeric(net[1,])
   #tt=c(1,200)
   indofleftright=tt>=164
   net[5,][indofleftright]="Right"
   net[5,][!indofleftright]="Left"
   net[6,]=sum(as.numeric(net[4,]))
   net[7,]=sum(as.numeric(net[3,]))
   for (j in 1:length( net[8,])) {
     tempindex=which(datanmes$ROI %in% net[2,j]  )
     if (net[5,j]=="Right" ) {net[8,j]= max(tempindex) } else { net[8,j]=min(tempindex) }
   }
   subnetsresults[[i]]=net
 }
#bbb=cbind( colnames(riskfactors)  , out$v,out$SDv, out$pvalsv)






# 
# #### we need raw risk factors for the violin plot purpose
# path3="/Users/ali/Desktop/may/sccapapr/resultsresponse_arrayraw.mat"
# data3=readMat(path3)
# responseraw=data3$response.arrayraw
# 
# riskfactors=matrix(NA,  dim(responseraw)[1], (dim(responseraw)[2]-1))
# #sum(riskfactors[,2]==3)
# 
# 
# 
# for (i in 1:dim(riskfactors)[1]) {
#   ind=which(response[i,9]==subjnameofconnectivity)
#   if (i!=ind) cat("here", i)
#   #riskfactors[ind,]=response[ind, 2:(dim(response)[2]) ]
#   temp=response[ind, 1:(dim(response)[2]) ];
#   temp=temp[-c(9)];
#   riskfactors[ind,]= temp;
# }
# pathnames0="/Users/ali/Desktop/may/sccapapr/resultsresponse_tablename.mat"
# temp=readMat(pathnames0, fixNames=T)
# temp=unlist(temp$varnames)
# temp=temp[-c(9)]
# colnames(riskfactors)=temp
# riskfactors=riskfactors[,-inddz]
# 
# path4="/Users/ali/Desktop/may/sccapapr/resultsconnectivity_allraw_ADDecode_Dipy.mat"
# data=readMat(path4)
# connectivityraw=data$connectivityraw
# 

connectivityraw=connectivity

subjnameofconnectivity=data$subjlist

#######################

### histograms of nets
histdata=matrix(0,length(subnetsresults),dim(connectivity)[3])
#t

for (j in 1:length(subnetsresults)){
  net=subnetsresults[[j]]
  subnetsuperset=as.numeric(net[1,])
  for (i in 1:dim(t)[1]){
  if ( t[i,][1]%in%subnetsuperset){
  for (k in 1:dim(connectivity)[3]) {
    temp=connectivityraw[,,k]
     #temp=connectivity[,,k]
   histdata[j,k]=histdata[j,k]+ (temp[t[i,][1],t[i,][2]]+temp[t[i,][2],t[i,][1]])
  #histdata[j,k]=histdata[j,k]+ abs(t[i,][3]*(temp[t[i,][1],t[i,][2]]+temp[t[i,][2],t[i,][1]]))
  #histdata[j,k]=histdata[j,k]+ t[i,][3]*(temp[t[i,][1],t[i,][2]]+temp[t[i,][2],t[i,][1]])
    #histdata[j,k]=histdata[j,k]+ abs((temp[t[i,][1],t[i,][2]]+temp[t[i,][2],t[i,][1]]))
      }
  }
}
}
 histdata=cbind(seq(1,length(subnetsresults)),histdata)



##split plots.
histdatasplit=histdata[,2:dim(histdata)[2]]
#uniqgeneafterreg=unique(riskfactors[,5])
apoe2=histdatasplit[,riskfactors[,2]==2] 
apoe3=histdatasplit[,riskfactors[,2]==3]
apoe4=histdatasplit[,riskfactors[,2]==4]


library(plotrix)
genindex=which(colnames(riskfactors)=="genotype")
GenoTypes=riskfactors[,genindex]
GenoTypes[GenoTypes==2]="2";GenoTypes[GenoTypes==3]="3";GenoTypes[GenoTypes==4]="4";
sexindex=which(colnames(riskfactors)=="sex")

Sex=riskfactors[,1]; Sex[Sex==1]="1M"; Sex[Sex==-1]="2F"; 
Sexname=Sex; Sexname[Sexname=="1M"]="Male" ;  Sexname[Sexname=="2F"]="Female";

######## pull all ad as mci
tempaaa=riskfactorsorig[,famindex]
tempaaa[tempaaa==3]=2
riskfactorsorig[,famindex]=tempaaa
#########
family=riskfactorsorig[,famindex];

#### pull ad and mic together
Diet=riskfactors[,2]


riskfactors
###### here specify   
xaxisvar=Diet; 
xaxis="Diet" ;
xaxisvarnames=Diet;
brightnessvar=Sex; 
brightness="Sex";
#######


names(xaxisvar)=xaxisvarnames





sqrt=sqrt(length(subnetsresults))
#png("agecat.png", units="in", width=15, height=3, res=400)  

par(mfrow = c(floor(sqrt), ceiling(length(subnetsresults)/sqrt)), cex.main=1.5, cex.axis=1.5, cex.lab=1.5)
#par(mfrow = c(1, 5), cex.main=1.2, cex.axis=1.5, cex.lab=1.5)


for (j in 1:length(subnetsresults)){
  #cols <- brewer.pal(8,'Set2')[6:8]
  cols=c(rgb(0,0,1),rgb(0,1,0),rgb(1,0,0,))
  cols[length(unique(xaxisvar))]=rgb(1,0,0,)
  cols=adjustcolor(cols, alpha.f = 0.1)
  legend=paste0("Net ",j, " medians: ( ");
  for (m in 1:length(unique(xaxisvar))) {
    if (m==1) {legend=paste(legend,  round(median(histdatasplit[j,xaxisvar==sort(unique(xaxisvar))[m]]),2), sep =""  )}
    else {legend=paste(legend,  round(median(histdatasplit[j,xaxisvar==sort(unique(xaxisvar))[m]]),2), sep =","  )}
  }
  legend=paste(legend,")")
  vioplot(histdatasplit[j,]~ xaxisvar , plotCentre = "dot", col =cols,  ylab="net weight" , cex.lab=10,
          main = legend, xlab ="Age Category", cex.names=1.5, cex.axis=1.5 )
  a=subnetsresults[[j]]; a=as.table(a);a= as.numeric(a[1,]); 
  #mtext(paste("R",a, collapse=', '), side=4, cex=0.5)
  
  for (l in 1:length(sort(unique(brightnessvar), decreasing=T))) {
    cols=c(rgb(0,0,1),rgb(0,1,0),rgb(1,0,0,))
    cols[length(unique(xaxisvar))]=rgb(1,0,0,)
    tempnum=length(sort(unique(brightnessvar), decreasing=T))
    cols=adjustcolor(cols, alpha.f = l/length(sort(unique(brightnessvar), decreasing=T)))
    stripchart(histdatasplit[j,brightnessvar==sort(unique(brightnessvar), decreasing=T)[l]]~xaxisvar[brightnessvar==sort(unique(brightnessvar), decreasing=T)[l]], vertical = TRUE, method = "jitter", points=50,
               pch = (17:length(sort(unique(brightnessvar), decreasing=T))), add = TRUE, col =cols , offset=0, cex = 1.5, cex.axis = 2,   font.label = list(size = 20, color = "black"))
    cat(sort(unique(brightnessvar), decreasing=T)[l],"  "  ,l/length(unique(brightnessvar, "\n") )  )
  }
  
  mtext(paste("Dark Jitt=", sort(unique(brightnessvar), decreasing=T)[l], brightness) , side=1, cex=0.6)
  
  for (k in 1:length(unique(xaxisvar))) {
    ablineclip(h=median(histdatasplit[j,xaxisvar==sort(unique(xaxisvar))[k]]), col=cols[k], lwd = 2, x1=0.4, x2=k, lty="dotted")
    
  }
}

# dev.off()


sum(GenoTypes=="APOE44" & Sex=="2F")
sum(family==2 & Sex=="2F")


library(brainconn2)

brainconn(atlas ="Desikan84num", conmat=connectivitvals, 
                     view="left", node.size =2, 
                     node.color = "pink", 
                     edge.width = 2, edge.color="blue", 
                     edge.alpha = 0.65,
                     edge.color.weighted = T,
                     scale.edge.width=T,
                     labels = T ,
                     all.nodes =F, 
                     show.legend = T, 
                     label.size=3.5, background.alpha=0.6, 
                     label.edge.weight=F)

library(ggplot2)
ggsave("glassleft.png", plot = last_plot(), 
       device='png', 
       scale=1, width=6, 
       height=6, unit=c("in"), dpi=400)


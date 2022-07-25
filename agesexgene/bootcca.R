boootcca=function(x=image, z=riskfactors, 
                  penaltyx=out$penaltyx ,penaltyz=out$penaltyz, 
                  nsim=1000, alpha=0.05, samplesize=dim(image)[1] )
{
  xorig=x;
  zorig=z;
  uboots=matrix(NA,dim(xorig)[2], nsim)
  vboots=matrix(NA,dim(zorig)[2], nsim)
  corboots=matrix(NA, nsim,1)

  for (ii in 1:nsim) {
    
    bootind=sample(dim(image)[1], replace = TRUE)
    x=xorig[bootind,];z=zorig[bootind,];
    
    bootindu=0
    for (i in 1:dim(x)[2]) if(sd(x[,i])==0 ) {bootindu=rbind(bootindu,i);}
    if (length(bootindu)>1){
      bootindu=bootindu[2:dim(bootindu)[1]]
      x=x[,-bootindu] }
    
    
    bootindv=0
    for (i in 1:dim(z)[2]) if(sd(z[,i])==0 ) {bootindv=rbind(bootindv,i);}
    if (length(bootindv)>1){
      bootindv=bootindv[2:dim(bootindv)[1]]
      z=z[,-bootindv] }
    
    
    outemp <- CCA(x=x,z=z,penaltyx=penaltyx,penaltyz=penaltyz, typex="standard",typez="standard")
    corboots[ii]=outemp$cors
    cat('number', ii, '\n')
    
    uouttemp=uboots[,ii]
    if(sum(bootindu)>0){
    uouttemp[bootindu]=0
    uouttemp[-bootindu]=outemp$u}
    else {  uouttemp =outemp$u }
    uboots[,ii]=uouttemp
    
    vouttemp=vboots[,ii]
    if(sum(bootindv)>0){
    vouttemp[bootindv]=0
    vouttemp[-bootindv]=outemp$v}
    else {  vouttemp= outemp$v}
    vboots[,ii]=vouttemp
    
  }
  
  lowerconfcor= quantile(corboots,  alpha/2)
  higherconfcor=quantile(corboots,  1-alpha/2)
  zstat=mean(corboots)/sd(corboots)
  pvalu=2*pnorm(abs(zstat), lower.tail = FALSE)
returnlist=list( 'corboots'=corboots,  'uboots'=uboots, 
                 'vboots'=vboots, 'lowerconfcor'=lowerconfcor,
                'higherconfcor'=higherconfcor,
                'zstat'=zstat, 'pvalu'=pvalu )
return(returnlist)
  
}






set.seed(123)
boot=boootcca(x=image, z=riskfactors, 
penaltyx=out$penaltyx ,penaltyz=out$penaltyz, 
nsim=1000, alpha=0.05, samplesize=dim(image)[1])

boot$lowerconfcor
boot$higherconfcor
boot$zstat
boot$pvalu


apply(boot$vboots, 1, quantile, probs = c(0.025))
apply(boot$vboots, 1, quantile, probs = c(0.975))
statsv=apply(boot$vboots, 1, mean)/apply(boot$vboots, 1, sd)
statsv
2*pnorm(abs(statsv), lower.tail = FALSE)


apply(boot$uboots, 1, quantile, probs = c(0.025))
apply(boot$uboots, 1, quantile, probs = c(0.975))
statsv=apply(boot$uboots, 1, mean)/apply(boot$uboots, 1, sd)
statsv
2*pnorm(abs(statsv), lower.tail = FALSE)

#### permutation confindence intervals
# quantile(perm.out$corperms,  0.025)
# quantile(perm.out$corperms,  0.975)

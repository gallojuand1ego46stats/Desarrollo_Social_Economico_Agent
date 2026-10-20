# Diagnosticos autorizados el 20-10-2026. R base; ejecutar desde la raiz.
# No ejecuta PCA, no retiene componentes ni construye un IVS.
options(stringsAsFactors=FALSE, digits=16)
try(Sys.setlocale('LC_CTYPE','Spanish_Colombia.utf8'),silent=TRUE)
out <- 'resultados/kmo_bartlett_20261020'
dir.create(out, recursive=TRUE, showWarnings=FALSE)
read <- function(p) read.csv(p, colClasses='character', check.names=FALSE, fileEncoding='UTF-8')
save <- function(x,n) write.csv(x,file.path(out,n),row.names=FALSE,fileEncoding='UTF-8',na='')
input <- 'resultados/descriptivos_sensibilidades_20261018/matriz_ocho_municipal_e_insular_0_1.csv'
all_input <- 'resultados/descriptivos_sensibilidades_20261018/indicadores_ocho_todas_unidades.csv'
sens_input <- 'resultados/descriptivos_sensibilidades_20261018/sensibilidades_por_codigo.csv'
protected <- c(input,all_input,sens_input)
before <- tools::md5sum(protected)
d <- read(input)
vars <- c('hogares_menores15','hogares_adultos_mayores','paredes_precarias_6V',
          'sin_energia_8V','sin_gas_8V','sin_internet_8V','estratos_1_2_o_sin_estrato_10V',
          'actividad_vulnerabilidad_10mas_5PM')
labels <- c('1HM','2HM','6V','Energia','Gas','Internet','10V','5PM')
X <- sapply(d[vars],as.numeric)
stopifnot(nrow(X)==1102,ncol(X)==8,!anyDuplicated(d$codigo_municipio),
          all(grepl('^[0-9]{5}$',d$codigo_municipio)), all(is.finite(X)),
          all(X>=0 & X<=1),all(apply(X,2,sd)>0))

diagnose <- function(X,scenario,method='pearson',store=FALSE) {
  n <- nrow(X); p <- ncol(X); R <- cor(X,method=method,use='everything')
  stopifnot(max(abs(R-t(R)))<1e-12,max(abs(diag(R)-1))<1e-12,qr(R)$rank==p)
  ch <- chol(R); logdet <- 2*sum(log(diag(ch))); inv <- chol2inv(ch)
  dimnames(inv) <- dimnames(R)
  # Anti-image Q contains +scaled inverse; partial correlations have opposite sign.
  Q <- inv/sqrt(outer(diag(inv),diag(inv)))
  partial <- -Q; diag(partial) <- 1
  r2 <- R^2; q2 <- Q^2; diag(r2) <- diag(q2) <- 0
  msa <- colSums(r2)/(colSums(r2)+colSums(q2))
  kmo <- sum(r2)/(sum(r2)+sum(q2))
  bartlett <- -(n-1-(2*p+5)/6)*logdet; df <- p*(p-1)/2
  # A rank correlation matrix is only a descriptive sensitivity here.
  logp <- if(method=='pearson') pchisq(bartlett,df,lower.tail=FALSE,log.p=TRUE) else NA_real_
  result <- data.frame(escenario=scenario,metodo=method,n=n,p=p,KMO=kmo,
    MSA_min=min(msa),indicador_MSA_min=names(which.min(msa)),MSA_menor_05=sum(msa<.5),
    determinante=exp(logdet),log_determinante=logdet,
    condicion_2=kappa(R,exact=TRUE),residuo_inversa=max(abs(R%*%inv-diag(p))),
    chi_cuadrado=if(method=='pearson') bartlett else NA_real_,gl=if(method=='pearson') df else NA_real_,
    p_nominal=if(method=='pearson' && exp(logp)>0) exp(logp) else NA_real_,
    p_subdesbordamiento=if(method=='pearson') exp(logp)==0 else NA,
    ln_p_nominal=logp,log10_p_nominal=logp/log(10))
  if(store) {
    save(data.frame(indicador=colnames(X),etiqueta=labels,MSA=msa,
                    suma_r2=colSums(r2),suma_parcial2=colSums(q2)),'msa_por_indicador.csv')
    for(nm in c('R','Q','partial')) save(data.frame(indicador=rownames(get(nm)),get(nm),check.names=FALSE),
                                      paste0(c(R='correlaciones_pearson',Q='anti_imagen',partial='correlaciones_parciales')[nm],'.csv'))
  }
  result
}

main <- diagnose(X,'municipal_e_insular',store=TRUE)
full <- read(all_input)
Xall <- sapply(full[vars],as.numeric)
stopifnot(nrow(Xall)==1122,all(is.finite(Xall)),!anyDuplicated(full$codigo_municipio))
territory <- rbind(main,diagnose(X[d$codigo_municipio!='88001',],'municipal_estricto'),
                  diagnose(Xall,'censal_completo'))
save(territory,'diagnosticos_por_ambito.csv')
save(diagnose(X,'municipal_e_insular_spearman','spearman'),'sensibilidad_spearman.csv')
leave <- do.call(rbind,lapply(seq_along(vars),function(j) {
  z <- diagnose(X[,-j],paste0('sin_',labels[j])); z$indicador_retirado <- vars[j]; z
}))
save(leave,'sensibilidad_retiro_individual.csv')
sens <- read(sens_input)
mapping <- c(peso_5PM_1=vars[8],peso_5PM_3=vars[8],actividad_total=vars[8],
             actividad_cota_NR=vars[8],gas_total=vars[5],internet_total=vars[6],estrato_total=vars[7])
alts <- do.call(rbind,lapply(names(mapping),function(sc) {
  z <- sens[sens$escenario==sc,]; idx <- match(d$codigo_municipio,z$codigo_municipio)
  stopifnot(!anyNA(idx),!anyDuplicated(z$codigo_municipio))
  Y <- X; Y[,mapping[[sc]]] <- as.numeric(z$alternativa[idx]); diagnose(Y,sc)
}))
save(alts,'sensibilidad_formulas.csv')
Z <- scale(X)
stopifnot(max(abs(cor(Z)-cor(X)))<1e-12)
save(cbind(d[1:4],as.data.frame(Z)),'matriz_z_diagnostico.csv')
stopifnot(all(before==tools::md5sum(protected)),main$KMO>=0,main$KMO<=1,
          main$gl==28,main$residuo_inversa<1e-10,all(is.finite(main$ln_p_nominal)))
save(data.frame(archivo=protected,md5_antes=unname(before),md5_despues=unname(tools::md5sum(protected))),
     'integridad_insumos.csv')
save(data.frame(control=c('dimensiones_1102_por_8','NA_cero','unicos_1102','rango_0_1',
  'variacion_no_nula','correlacion_definida_positiva','inversa_residuo_menor_1e_10',
  'invarianza_correlacion_escala_z','insumos_sin_modificaciones'),cumple=TRUE),'controles.csv')
texout <- file.path(out,'tablas_tex')
dir.create(texout,showWarnings=FALSE)
fmt <- function(x,d=4) formatC(x,format='f',digits=d,decimal.mark=',',big.mark='.')
make_tex <- function(name,caption,headers,rows,widths) {
  align <- paste0('@{}',paste0('p{',widths,'\\textwidth}',collapse=''),'@{}')
  lines <- c('\\begin{table}[htbp]','\\centering\\small',
    paste0('\\caption{',caption,'}\\label{tab:',name,'}'),
    paste0('\\begin{tabular}{',align,'}'),'\\toprule',
    paste0(paste(headers,collapse=' & '),' \\\\'),'\\midrule',
    apply(rows,1,function(r) paste0(paste(r,collapse=' & '),' \\\\')),
    '\\bottomrule','\\end{tabular}','\\end{table}')
  writeLines(lines,file.path(texout,paste0(name,'.tex')),useBytes=TRUE)
}
make_tex('kmo_ambitos','Diagnóstico Pearson de las ocho candidatas por ámbito territorial',
  c('Ámbito','n','KMO','Chi-cuadrado','gl'),
  cbind(c('Municipal e insular','Municipal estricto','Censal completo'),territory$n,
        fmt(territory$KMO),fmt(territory$chi_cuadrado,3),territory$gl),c(.30,.10,.16,.22,.07))
msa_tab <- read.csv(file.path(out,'msa_por_indicador.csv'))
make_tex('msa_actual','MSA individual en el ámbito municipal e insular (1.102 unidades)',
  c('Indicador','MSA','Lectura del diagnóstico'),
  cbind(labels,fmt(msa_tab$MSA),ifelse(msa_tab$MSA<.6,'Más próximo al umbral 0,50','Por encima de 0,60')),c(.20,.18,.48))
selected <- alts[alts$escenario %in% c('peso_5PM_1','peso_5PM_3','gas_total','internet_total','estrato_total'),]
make_tex('kmo_sensibilidad','Sensibilidad de adecuación a las fórmulas (1.102 unidades)',
  c('Variante','KMO','MSA mínimo','MSA menor de 0,50'),
  cbind(c('5PM peso 1:1','5PM peso 3:1','Gas total','Internet total','10V total'),
        fmt(selected$KMO),fmt(selected$MSA_min),selected$MSA_menor_05),c(.33,.15,.19,.22))
capture.output(sessionInfo(),file=file.path(out,'sessionInfo.txt'))
print(territory); print(read.csv(file.path(out,'msa_por_indicador.csv')))

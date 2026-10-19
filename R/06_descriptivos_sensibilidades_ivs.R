# Actualizacion descriptiva del informe, 18-10-2026. Ejecutar desde la raiz:
# Rscript R/06_descriptivos_sensibilidades_ivs.R
# Solo R base. NO calcula PCA, componentes, puntajes, KMO ni Bartlett.
# Conserva los insumos y las corridas historicas. No imputa ni elimina extremos.
options(stringsAsFactors = FALSE, digits = 15)
try(Sys.setlocale('LC_CTYPE', 'Spanish_Colombia.utf8'), silent = TRUE)
root <- normalizePath(getwd(), winslash = '/', mustWork = TRUE)
out <- file.path(root, 'resultados/descriptivos_sensibilidades_20261018')
dir.create(out, recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(out, 'tablas_tex'), showWarnings = FALSE)
dir.create(file.path(out, 'figuras'), showWarnings = FALSE)
read_text <- function(p) read.csv(p, colClasses = 'character', check.names = FALSE,
  na.strings = c('', 'NA'), fileEncoding = 'UTF-8')
save_csv <- function(x, name) write.csv(x, file.path(out, name), row.names = FALSE,
  na = '', fileEncoding = 'UTF-8')
as_num <- function(x) {
  y <- suppressWarnings(as.numeric(x))
  if (any(!is.na(x) & is.na(y))) stop('Conversion numerica fallida: ', paste(unique(x[!is.na(x)&is.na(y)]), collapse=', '))
  y
}
ratio <- function(a,b) { if (any(!is.finite(b) | b <= 0)) stop('Denominador invalido'); a/b }
protected <- sort(c(list.files('datos', recursive=TRUE, full.names=TRUE),
  list.files('resultados/indicadores_finales_ivs_20261015', full.names=TRUE),
  list.files('resultados/verificacion_consolidados', full.names=TRUE)))
protected <- protected[!file.info(protected)$isdir]
hash_before <- tools::md5sum(protected)
ids <- c('codigo_departamento','codigo_municipio','nombre_municipio','nombre_departamento')
old <- read_text('resultados/indicadores_finales_ivs_20261015/indicadores_municipales_y_denominadores.csv')
old <- old[order(old$codigo_municipio), ]
stopifnot(nrow(old)==1122L, !anyDuplicated(old$codigo_municipio), all(grepl('^[0-9]{5}$',old$codigo_municipio)))
source_total <- function(nm, extra=NULL) {
  x <- read_text(paste0('datos/intermedio/',nm,'.csv'))
  if ('area' %in% names(x)) x <- x[x$area=='Total', ]
  if ('sexo' %in% names(x)) x <- x[x$sexo=='Total', ]
  if (!is.null(extra)) x <- x[x$tipo_vivienda=='Total', ]
  stopifnot(!anyDuplicated(x$codigo_municipio), setequal(x$codigo_municipio,old$codigo_municipio))
  x <- x[match(old$codigo_municipio,x$codigo_municipio), ]
  for (v in setdiff(names(x),c(ids,'area','sexo','tipo_vivienda'))) x[[v]] <- as_num(x[[v]])
  x
}
message('[1/5] Recalculando ocho formulas desde las tablas intermedias')
h <- source_total('hogares_1HM_2HM'); v6 <- source_total('viviendas_6V',TRUE)
v8 <- source_total('viviendas_8V'); v10 <- source_total('viviendas_10V')
p5 <- source_total('persona_social_5PM'); p17 <- source_total('persona_demo_17PM')
vars <- c('hogares_menores15','hogares_adultos_mayores','paredes_precarias_6V',
  'sin_energia_8V','sin_gas_8V','sin_internet_8V','estratos_1_2_o_sin_estrato_10V','actividad_vulnerabilidad_10mas_5PM')
labels <- c('1HM','2HM','6V','Energia','Gas','Internet','10V','5PM')
walls <- c('guadua','tapia_bahareque_adobe','madera_burda','cana_vegetales','desecho','sin_paredes')
wall_n <- v6[paste0('total_',walls)]
labor_a <- p5$trabajo_o_ayudo_en_un_negocio_por_lo_menos_una_hora_sin_que_le_pagaran + p5$busco_trabajo
labor_i <- p5$esta_incapacitado_a_permanentemente_para_trabajar
labor_valid <- p5$total-p5$no_informa
strata_d <- rowSums(v10[paste0('estrato_',1:6)])+v10$no_tiene_estrato
strata_n <- v10$estrato_1+v10$estrato_2+v10$no_tiene_estrato
numerators <- data.frame(h$hogares_menores15,h$hogares_adultos_mayores,rowSums(wall_n),
  v8$energia_no,v8$gas_no,v8$internet_no,strata_n,labor_a+2*labor_i)
denominators <- data.frame(h$hogares_total,h$hogares_total_2HM,v6$total_total,
  v8$energia_total,v8$gas_total-v8$gas_sin_informacion,v8$internet_total-v8$internet_sin_informacion,
  strata_d,2*labor_valid)
names(numerators) <- names(denominators) <- vars
X <- as.data.frame(Map(ratio,numerators,denominators))
names(X) <- vars
stopifnot(all(is.finite(as.matrix(X))), all(as.matrix(X)>=0 & as.matrix(X)<=1))
checks <- data.frame(indicador=vars,n=nrow(X),
  max_diferencia=sapply(vars,function(v) max(abs(X[[v]]-as_num(old[[v]])))),
  tolerancia=1e-12)
checks$violaciones <- sapply(vars,function(v) sum(abs(X[[v]]-as_num(old[[v]]))>1e-12))
save_csv(checks,'verificacion_formulas.csv'); stopifnot(all(checks$violaciones==0))
# Lista temporal explicita: no se infiere la categoria administrativa de la falta
# de cabecera. La documentacion registra la fuente DANE y el limite de verificacion.
anm <- read_text('docs/metodologia/anm_divipola_2018_verificadas_20261018.csv')$codigo_municipio
stopifnot(length(anm)==20L, !anyDuplicated(anm), all(anm %in% old$codigo_municipio))
geo <- old[ids]
geo$tipo_2018 <- ifelse(geo$codigo_municipio %in% anm,'ANM',
  ifelse(geo$codigo_municipio=='88001','Isla San Andres','Municipio o distrito'))
geo$ambito_descriptivo <- geo$tipo_2018!='ANM'
geo$fuente <- 'DANE CNPV 2018, seccion 2.2.6 y capa ANM Serv_DeptosMpiosANM_2018/MapServer/2; consulta 2026-10-18'
stopifnot(sum(geo$tipo_2018=='ANM')==20, sum(geo$tipo_2018=='Municipio o distrito')==1101)
save_csv(geo,'clasificacion_territorial_2018.csv')
sets <- list(municipal_e_insular=which(geo$ambito_descriptivo),
  municipal_estricto=which(geo$tipo_2018=='Municipio o distrito'),
  anm=which(geo$tipo_2018=='ANM'),censal_completo=seq_len(nrow(X)))
sel <- sets$municipal_e_insular
save_csv(cbind(geo,X),'indicadores_ocho_todas_unidades.csv')
save_csv(cbind(geo[sel,ids],X[sel,]),'matriz_ocho_municipal_e_insular_0_1.csv')
save_csv(cbind(geo[sets$anm,ids],X[sets$anm,]),'indicadores_anm.csv')
audit_long <- do.call(rbind,lapply(seq_along(vars),function(j) data.frame(
  codigo_municipio=geo$codigo_municipio,indicador=vars[j],numerador=numerators[[j]],
  denominador=denominators[[j]],valor=X[[j]])))
save_csv(audit_long,'numeradores_denominadores.csv')
message('[2/5] Descriptivos por ambito y tasas como razones de sumas')
desc <- do.call(rbind,lapply(names(sets),function(s) do.call(rbind,lapply(vars,function(v) {
  x <- X[[v]][sets[[s]]]; n <- length(x); q <- quantile(x,c(.25,.5,.75),type=7,names=FALSE)
  data.frame(ambito=s,indicador=v,n=n,media=mean(x),de_poblacional=sqrt(mean((x-mean(x))^2)),
    de_convencional=sd(x),minimo=min(x),q1=q[1],mediana=q[2],q3=q[3],maximo=max(x),
    numerador_agregado=sum(numerators[[v]][sets[[s]]]),denominador_agregado=sum(denominators[[v]][sets[[s]]]),
    razon_sumas=sum(numerators[[v]][sets[[s]]])/sum(denominators[[v]][sets[[s]]]))
}))))
save_csv(desc,'descriptivos_ocho_por_ambito.csv')
chosen <- vars[c(1,3,4,7)]
table4 <- desc[desc$ambito=='municipal_e_insular' & desc$indicador %in% chosen, ]
save_csv(table4,'descriptivos_cuatro_informe.csv')
save_csv(cbind(geo[geo$codigo_municipio=='88001',ids],X[geo$codigo_municipio=='88001',]),'isla_san_andres.csv')
message('[3/5] Sensibilidad de formulas; no se descompone ninguna matriz')
edu_num <- rowSums(p17[c('ninguno','preescolar','primaria_completa','primaria_incompleta',
  'secundaria_completa','secundaria_incompleta','media_incompleta')])
edu <- ratio(edu_num,p17$total)
alternatives <- list(
  peso_5PM_1=ratio(labor_a+labor_i,labor_valid),
  peso_5PM_3=ratio(labor_a+3*labor_i,3*labor_valid),
  actividad_total=ratio(labor_a+2*labor_i,2*p5$total),
  actividad_cota_NR=ratio(labor_a+2*labor_i+2*p5$no_informa,2*p5$total),
  gas_total=ratio(v8$gas_no,v8$gas_total),internet_total=ratio(v8$internet_no,v8$internet_total),
  estrato_total=ratio(strata_n,v10$personas_hogares_particulares),
  educacion_normal=ratio(edu_num+p17$normal_incompleta,p17$total),
  educacion_valida=ratio(edu_num,p17$total-p17$sin_informacion))
refvars <- c(rep(vars[8],4),vars[5],vars[6],vars[7],rep('sin_media_completa_17PM',2))
refs <- c(X,list(sin_media_completa_17PM=edu))
sens_rows <- list(); details <- list()
for (s in names(sets)) for (j in seq_along(alternatives)) {
  ii <- sets[[s]]; a <- refs[[refvars[j]]][ii]; b <- alternatives[[j]][ii]; d <- b-a
  sens_rows[[length(sens_rows)+1L]] <- data.frame(ambito=s,escenario=names(alternatives)[j],
    indicador=refvars[j],n=length(ii),rho_spearman=cor(a,b,method='spearman'),
    delta_media=mean(d),delta_absoluto_medio=mean(abs(d)),delta_absoluto_maximo=max(abs(d)),
    unidades_delta_2pp=sum(abs(d)>=.02))
  if (s=='censal_completo') details[[length(details)+1L]] <- data.frame(codigo_municipio=geo$codigo_municipio[ii],
    escenario=names(alternatives)[j],principal=a,alternativa=b,delta=d)
}
sens <- do.call(rbind,sens_rows)
save_csv(sens,'sensibilidades_formulas_por_ambito.csv'); save_csv(do.call(rbind,details),'sensibilidades_por_codigo.csv')
# El contraste con total corresponde al limite inferior de no respuesta para
# servicios; el superior asigna toda NR a carencia. No se presume MAR/MCAR.
nr <- do.call(rbind,lapply(c('gas','internet'),function(s) {
  d <- v8[[paste0(s,'_total')]]; nr <- v8[[paste0(s,'_sin_informacion')]]; n <- v8[[paste0(s,'_no')]]
  data.frame(codigo_municipio=geo$codigo_municipio,servicio=s,total=d,no_respuesta=nr,
    principal=n/(d-nr),cota_inferior=n/d,cota_superior=(n+nr)/d,amplitud=nr/d)
}))
save_csv(nr,'cotas_no_respuesta_servicios.csv')
wall_shares <- as.data.frame(lapply(wall_n,function(x) ratio(x,v6$total_total)))
names(wall_shares) <- paste0('pared_',walls)
basuras <- ratio(v8$basuras_no,v8$basuras_total)
save_csv(cbind(geo[ids],wall_shares,sin_basuras_exploratoria=basuras,educacion_reservada=edu),
  'candidatas_sensibilidad_reservadas.csv')
reserved <- cbind(wall_shares,sin_basuras=basuras,sin_media_completa_17PM=edu,
  elegibles_10V=strata_d/v10$personas_hogares_particulares,
  sin_energia_10V=v10$sin_servicio_energia/v10$personas_hogares_particulares,
  nr_10V=v10$no_sabe_no_responde/v10$personas_hogares_particulares)
save_csv(do.call(rbind,lapply(names(reserved),function(v) {
  x <- reserved[[v]][sel]
  data.frame(variable=v,n=length(x),media=mean(x),mediana=median(x),minimo=min(x),maximo=max(x))
})),'descriptivos_sensibilidades_reservadas.csv')
# Sensibilidad estructural previa al PCA: diferencias entre correlaciones.
# No calcula eigen(), svd(), prcomp(), princomp(), cargas ni puntajes.
scenarios <- list(principal=X)
for (j in 1:7) { z <- X; z[[refvars[j]]] <- alternatives[[j]]; scenarios[[names(alternatives)[j]]] <- z }
z <- X; z[[vars[5]]] <- alternatives$gas_total; z[[vars[6]]] <- alternatives$internet_total
scenarios$gas_internet_total <- z
scenarios$sin_6V <- X[setdiff(vars,vars[3])]
scenarios$sin_1HM_2HM <- X[vars[-c(1,2)]]
scenarios$sin_6V_1HM_2HM <- X[vars[-c(1,2,3)]]
scenarios$paredes_separadas <- cbind(X[vars[-3]],wall_shares)
scenarios$basuras_exploratoria <- cbind(X,sin_basuras=basuras)
scenarios$educacion_reservada <- cbind(X,sin_media_completa_17PM=edu)
cor_summary <- list(); cor_long <- list()
for (s in names(scenarios)) for (m in c('pearson','spearman')) {
  z <- scenarios[[s]][sel,]; rr <- cor(z,method=m); rr0 <- cor(X[sel,],method=m)
  common <- intersect(colnames(rr),colnames(rr0)); dd <- rr[common,common]-rr0[common,common]
  diff <- dd[upper.tri(dd)]
  cor_summary[[length(cor_summary)+1L]] <- data.frame(escenario=s,metodo=m,n=nrow(z),p=ncol(z),
    pares_comparables=length(diff),delta_r_max=max(abs(diff)),delta_r_rms=sqrt(mean(diff^2)))
  idx <- which(upper.tri(rr),arr.ind=TRUE)
  cor_long[[length(cor_long)+1L]] <- data.frame(escenario=s,metodo=m,
    variable_1=colnames(rr)[idx[,1]],variable_2=colnames(rr)[idx[,2]],r=rr[idx])
}
save_csv(do.call(rbind,cor_summary),'sensibilidad_correlaciones.csv')
save_csv(do.call(rbind,cor_long),'correlaciones_escenarios.csv')
territorial <- do.call(rbind,lapply(c('municipal_estricto','censal_completo'),function(s) {
  rr0 <- cor(X[sel,]); rr <- cor(X[sets[[s]],]); dd <- (rr-rr0)[upper.tri(rr)]
  data.frame(ambito=s,n=length(sets[[s]]),delta_r_max=max(abs(dd)),delta_r_rms=sqrt(mean(dd^2)))
}))
save_csv(territorial,'sensibilidad_correlaciones_territorial.csv')
ipm <- read_text('datos/intermedio/ipm_municipal_ancho.csv')
priv <- names(ipm)[11:25]
overlap <- expand.grid(candidata=c(labels,'17PM'),privacion=priv,stringsAsFactors=FALSE)
overlap$relacion <- 'sin_equivalencia_directa_identificada'
overlap$nota <- 'Evaluacion conceptual, no prueba empirica ni escala numerica de similitud.'
set_overlap <- function(cand, vv, level, note) {
  ii <- overlap$candidata==cand & overlap$privacion %in% vv
  overlap$relacion[ii] <<- level; overlap$nota[ii] <<- note
}
set_overlap('1HM',c('tasa_de_dependencia','barreras_a_servicios_para_cuidado_de_la_primera_infancia'),
  'parcial','Presencia de menores 15 no equivale a personas por ocupado ni barreras de cuidado 0-5.')
set_overlap('2HM','tasa_de_dependencia','parcial','Presencia 60+ no equivale a dependencia economica ni funcional.')
set_overlap('6V','material_inadecuado_de_paredes_exteriores','directa_parcial',
  'Materiales y unidad distintos; IPM distingue umbrales urbanos y rurales.')
set_overlap('5PM',c('tasa_de_dependencia','trabajo_informal','trabajo_infantil'),'indirecta',
  'Actividad 10+ ponderada no mide dependencia hogar, informalidad ni trabajo infantil oficial.')
set_overlap('17PM',c('analfabetismo','bajo_logro_educativo','inasistencia_escolar','rezago_escolar'),
  'parcial','Nivel alcanzado 5+; diferente edad, unidad y concepto educativo.')
set_overlap('Internet',c('bajo_logro_educativo','inasistencia_escolar'),'indirecta',
  'Acceso digital puede relacionarse con oportunidades educativas; no es privacion IPM equivalente.')
overlap$fuente <- 'DANE nota metodologica IPM censal 2020; formulas aprobadas del proyecto.'
save_csv(overlap,'solapamiento_conceptual_ipm.csv')
# La correlacion entre variables conservadas no cambia al retirar columnas:
# delta cero en estos escenarios NO prueba estabilidad de componentes futuros.
zz <- scale(X[sel,]); idx <- which(abs(zz)>4,arr.ind=TRUE)
ext <- data.frame(codigo_municipio=geo$codigo_municipio[sel][idx[,1]],
  indicador=vars[idx[,2]],valor=as.matrix(X[sel,])[idx],z=zz[idx])
save_csv(ext,'extremos_z_mayor_4_para_cotejo.csv')
message('[4/5] Tablas LaTeX y figuras descriptivas')
fmt <- function(x,d=2) formatC(x,format='f',digits=d,decimal.mark=',')
texwrite <- function(lines,name) writeLines(enc2utf8(lines),file.path(out,'tablas_tex',name),useBytes=TRUE)
tt <- table4[match(chosen,table4$indicador),]
rows <- vapply(seq_len(nrow(tt)),function(i) paste(c(labels[c(1,3,4,7)][i],tt$n[i],
  fmt(100*as.numeric(tt[i,c('media','de_poblacional','mediana','q1','q3','minimo','maximo')]))),collapse=' & '),'')
texwrite(c('\\begin{tabular}{@{}lrrrrrrrr@{}}','\\toprule',
  'Indicador & $n$ & Media & DE & Mediana & Q1 & Q3 & Mín. & Máx. \\\\',
  '\\midrule',paste0(rows,' \\\\'),'\\bottomrule','\\end{tabular}'),'descriptivos_cuatro.tex')
names_s <- c('5PM: peso 1:1','5PM: peso 3:1','5PM: total','5PM: cota NR','Gas: total',
  'Internet: total','10V: total','17PM: Normal incompleta','17PM: base válida')
ss <- sens[sens$ambito=='municipal_e_insular',]
rows <- vapply(seq_len(nrow(ss)),function(i) paste(c(names_s[i],fmt(ss$rho_spearman[i],3),
  fmt(100*ss$delta_absoluto_medio[i]),fmt(100*ss$delta_absoluto_maximo[i]),ss$unidades_delta_2pp[i]),collapse=' & '),'')
texwrite(c('\\begin{tabular}{@{}lrrrr@{}}','\\toprule',
  'Alternativa & $\\rho_s$ & $|\\Delta|$ medio (pp) & $|\\Delta|$ máx. (pp) & $\\geq2$ pp \\\\',
  '\\midrule',paste0(rows,' \\\\'),'\\bottomrule','\\end{tabular}'),'sensibilidades.tex')
cs <- do.call(rbind,cor_summary)
cs <- cs[cs$metodo=='pearson' & cs$escenario %in% c(names(alternatives)[1:7],'gas_internet_total'),]
csnames <- c(names_s[1:7],'Gas e internet: total')
rows <- vapply(seq_len(nrow(cs)),function(i) paste(c(csnames[i],fmt(cs$delta_r_max[i],3),fmt(cs$delta_r_rms[i],3)),collapse=' & '),'')
texwrite(c('\\begin{tabular}{@{}lrr@{}}','\\toprule',
  'Alternativa & Máximo $|\\Delta r|$ & Raíz de diferencia cuadrática media \\\\',
  '\\midrule',paste0(rows,' \\\\'),'\\bottomrule','\\end{tabular}'),'correlaciones_sensibilidad.tex')
rows <- vapply(seq_len(nrow(tt)),function(i) paste(c(labels[c(1,3,4,7)][i],
  format(tt$numerador_agregado[i],scientific=FALSE,trim=TRUE),
  format(tt$denominador_agregado[i],scientific=FALSE,trim=TRUE),fmt(100*tt$razon_sumas[i])),collapse=' & '),'')
texwrite(c('\\begin{tabular}{@{}lrrr@{}}','\\toprule',
  'Indicador & Numerador agregado & Denominador agregado & Razón (\\%) \\\\',
  '\\midrule',paste0(rows,' \\\\'),'\\bottomrule','\\end{tabular}'),'razones_sumas.tex')
pdf(file.path(out,'figuras/distribuciones_cuatro.pdf'),width=7,height=5,family='Helvetica')
par(mar=c(4,4,1,1)); boxplot(X[sel,chosen]*100,names=labels[c(1,3,4,7)],
  ylab='Porcentaje',col=c('#8AB6D6','#B9C98D','#F1C785','#B7A4CA'),ylim=c(0,100),outline=TRUE)
grid(nx=NA,ny=NULL,col='gray85'); dev.off()
pdf(file.path(out,'figuras/sensibilidad_denominadores.pdf'),width=7,height=6,family='Helvetica')
par(mfrow=c(2,2),mar=c(4,4,2,1))
for (j in c(1,5,6,7)) { a <- refs[[refvars[j]]][sel]; b <- alternatives[[j]][sel]
  plot(a*100,b*100,pch=16,cex=.35,col=adjustcolor('#245B78',alpha.f=.35),
    xlab='Formula principal (%)',ylab='Alternativa (%)',main=names_s[j],xlim=c(0,100),ylim=c(0,100)); abline(0,1,lty=2,col='gray40') }
dev.off()
summary <- data.frame(hecho=c('codigos_censales','municipios_distritos','unidad_insular','anm',
  'unidades_descriptivo_principal','indicadores_principales','NA_matriz','violaciones_formulas',
  'codigos_extremos_z4','celdas_extremas_z4','PCA_ejecutado','KMO_Bartlett_ejecutados'),
  valor=c(nrow(X),sum(geo$tipo_2018=='Municipio o distrito'),sum(geo$tipo_2018=='Isla San Andres'),
    length(sets$anm),length(sel),length(vars),sum(is.na(X)),sum(checks$violaciones),
    length(unique(ext$codigo_municipio)),nrow(ext),'FALSE','FALSE'))
save_csv(summary,'resumen_ejecucion.csv')
capture.output(sessionInfo(),file=file.path(out,'sessionInfo.txt'))
message('[5/5] Verificando integridad de insumos')
hash_after <- tools::md5sum(protected)
save_csv(data.frame(archivo=protected,md5_antes=unname(hash_before),md5_despues=unname(hash_after),
  sin_cambios=unname(hash_before)==unname(hash_after)),'integridad_insumos.csv')
stopifnot(identical(unname(hash_before),unname(hash_after)))
message('Completado: descriptivos y sensibilidades. PCA no ejecutado. Salidas: ',out)

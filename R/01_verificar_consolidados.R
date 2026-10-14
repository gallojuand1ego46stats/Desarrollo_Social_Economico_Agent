# Verificacion de estructura, llaves, cobertura y consistencia de consolidados.
# Ejecutar desde la raiz: Rscript R/01_verificar_consolidados.R
# No deriva indicadores ni ejecuta imputacion, KMO, Bartlett o PCA.
local_lib <- file.path(Sys.getenv("USERPROFILE"), "AppData/Local/R/win-library/4.6")
if (dir.exists(local_lib)) .libPaths(c(local_lib, .libPaths()))
suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(tidyr)
  library(stringr); library(purrr); library(tibble); library(janitor)
})
options(stringsAsFactors = FALSE, readr.show_col_types = FALSE, encoding = "UTF-8")
utf8_locale <- c("English_United States.utf8", "Spanish_Colombia.utf8", ".UTF-8")
locale_ok <- FALSE
for (candidate in utf8_locale) {
  if (!is.na(suppressWarnings(Sys.setlocale("LC_CTYPE", candidate)))) { locale_ok <- TRUE; break }
}
if (!locale_ok) stop("No hay un locale LC_CTYPE UTF-8 disponible; no se ejecuta para evitar corrupci\u00F3n de caracteres.")
set.seed(20261006)
root <- normalizePath(getwd(), winslash="/", mustWork=TRUE)
input <- file.path(root,"datos")
f_cnpv <- file.path(input,"CUADROS_MUNICIPALES_UNIDOS.xlsx")
f_ipm <- file.path(input,"IPM_2018_organizado_region.xlsx")
f_div <- list.files(input,pattern="^DIVIPOLA-",full.names=TRUE)
f_dec <- file.path(root,"docs/diccionario/decisiones_variables_IVS_CNPV2018.csv")
out <- file.path(root,"resultados/verificacion_consolidados")
inter <- file.path(input,"intermedio")
dir.create(out,recursive=TRUE,showWarnings=FALSE); dir.create(inter,recursive=TRUE,showWarnings=FALSE)
dir.create(file.path(root,"docs/calidad/auditorias"),recursive=TRUE,showWarnings=FALSE)
stopifnot(length(f_div)==1L,all(file.exists(c(f_cnpv,f_ipm,f_div,f_dec))))
message("[1/9] Hashes originales y lectura literal de hojas")
hash <- function(p) unname(tools::md5sum(p))
hash_before <- c(CUADROS=hash(f_cnpv),IPM=hash(f_ipm),DIVIPOLA=hash(f_div))
read_book <- function(path) set_names(map(excel_sheets(path), ~read_excel(path,sheet=.x,col_names=FALSE,col_types="text",.name_repair="minimal",na="")),excel_sheets(path))
cn <- read_book(f_cnpv); ib <- read_book(f_ipm)
blank <- function(x) is.na(x) | str_trim(as.character(x))==""
val <- function(x) { x<-as.character(x); x[blank(x)]<-NA_character_; x }
excel_col <- function(n) vapply(n,function(k){s<-"";while(k>0){r<-(k-1)%%26;s<-paste0(LETTERS[r+1],s);k<-(k-1)%/%26};s},character(1))
clean_header <- function(x) { x<-str_squish(as.character(x)); x[is.na(x)]<-""; make_clean_names(x) }
sheet_inventory <- function(book,file) imap_dfr(book,function(x,nm) {
  nr<-nrow(x); nc<-ncol(x); hdr<-if(nm %in% c("HOGARES_MUNICIPAL")) 3L else if(nm %in% c("PERSONA_DEMO","PERSONA_SOCIAL")) 2L else if(nm=="VIVIENDAS") 3L else if(nm=="CONTEXTO") 2L else 1L
  if(nc==0) return(tibble(archivo=file,hoja=nm,filas_excel=nr,columnas=nc,filas_encabezado=hdr,filas_datos=max(0,nr-hdr),numero_col=NA_integer_,letra_excel=NA_character_,nombre_original=NA_character_,nombre_limpio=NA_character_,tipo_leido="texto",celdas_vacias_pct=NA_real_))
  hdr_col<-rep(hdr,nc); if(nm=="VIVIENDAS") hdr_col[70:nc]<-2L
  h<-vapply(seq_len(nc),function(j){hm<-as.data.frame(x[seq_len(min(hdr_col[j],nr)),j,drop=FALSE],check.names=FALSE);z<-as.character(unlist(hm));z<-z[!is.na(z)&str_trim(z)!=""];if(length(z))paste(str_squish(z),collapse=" | ") else ""},character(1))
  tibble(archivo=file,hoja=nm,filas_excel=nr,columnas=nc,filas_encabezado=hdr_col,filas_datos=pmax(0,nr-hdr_col),numero_col=seq_len(nc),letra_excel=excel_col(seq_len(nc)),nombre_original=ifelse(h=="",paste0("Columna_",seq_len(nc)),h),nombre_limpio=clean_header(h),tipo_leido="texto",celdas_vacias_pct=map_dbl(x,~round(mean(blank(.x))*100,4)))
})
inv <- bind_rows(sheet_inventory(cn,"CUADROS_MUNICIPALES_UNIDOS.xlsx"),sheet_inventory(ib,"IPM_2018_organizado_region.xlsx"))
disc <- tibble(severidad=character(),hoja=character(),columna_fila=character(),descripcion=character(),evidencia=character(),accion_sugerida=character())
check <- tibble(chequeo=character(),hoja=character(),n_evaluado=integer(),n_violaciones=integer(),tolerancia=character(),evidencia=character())
add_disc <- function(s,h,l,d,e,a) disc <<- bind_rows(disc,tibble(severidad=s,hoja=h,columna_fila=l,descripcion=d,evidencia=e,accion_sugerida=a))
add_check <- function(n,h,n0,b,t,e="") check <<- bind_rows(check,tibble(chequeo=n,hoja=h,n_evaluado=as.integer(n0),n_violaciones=as.integer(b),tolerancia=t,evidencia=e))
add_disc("BAJA","VIVIENDAS","BR(70)","Ajuste del encabezado de inventario para el bloque 10V: dos filas de encabezado; sin incorporar Total Nacional a BR","BR:CE inventariadas con filas 1:2; el bloque 10V conserva sus datos desde la fila 3","Solo presentaci\u00F3n del inventario; sin cambio en las tablas tidy")
expected_dims<-c(HOGARES_MUNICIPAL="1126x29",PERSONA_DEMO="12842x21",PERSONA_SOCIAL="12842x16",VIVIENDAS="6662x83",CONTEXTO="80987x20")
for (f in names(expected_dims)) {
  if(!f %in% names(cn)) {add_disc("ALTA",f,"hoja","Hoja requerida ausente","No encontrada","Revisar consolidado");next}
  actual<-paste0(nrow(cn[[f]]),"x",ncol(cn[[f]]))
  # Dimensiones en el contrato se refieren a filas Excel x columnas, incluidos encabezados.
  bad<-actual!=unname(expected_dims[f])
  add_check("Dimensiones Excel contra contrato",f,1L,as.integer(bad),"0",paste("esperado",unname(expected_dims[f]),"observado",actual))
  if(bad) add_disc("ALTA",f,"hoja","Dimensiones distintas al contrato",paste("esperado",unname(expected_dims[f]),"observado",actual),"No adaptar silenciosamente; revisar hoja")
}
expected_ipm_dims<-c(IPM_municipios_region="1123x23",Indicadores_municipales="17953x6",Indicadores_por_dominio="50491x7",Diccionario_variables="20x6",Diccionario_dominio="65x6",Resumen_region="7x21",Resumen_departamento="34x7",Control_calidad="7x2")
for(sh in names(expected_ipm_dims)) {if(!sh%in%names(ib)){add_disc("ALTA",sh,"hoja","Hoja IPM requerida ausente","No encontrada","Revisar el libro IPM");next};actual<-paste0(nrow(ib[[sh]]),"x",ncol(ib[[sh]]));bad<-actual!=expected_ipm_dims[[sh]];add_check("Dimensiones Excel contra contrato",sh,1L,as.integer(bad),"0",paste("esperado",expected_ipm_dims[[sh]],"observado",actual));if(bad)add_disc("ALTA",sh,"hoja","Dimensiones distintas al contrato",paste("esperado",expected_ipm_dims[[sh]],"observado",actual),"Revisar estructura antes de interpretar")}
add_check("Hoja IPM del libro CNPV vac\u00EDa","IPM",0L,as.integer(nrow(cn$IPM)!=0||ncol(cn$IPM)!=0),"0 celdas usadas",paste0(nrow(cn$IPM),"x",ncol(cn$IPM)))
get_block <- function(x,rows,cols) as_tibble(x[rows,cols,drop=FALSE],.name_repair="minimal")
as_num <- function(x) { x<-val(x); suppressWarnings(parse_number(x,locale=locale(grouping_mark=",",decimal_mark="."))) }
count_bad_num <- function(x) { z<-val(x); sum(!is.na(z)&is.na(as_num(z))) }
key_from_labels <- function(dep,mun,fmt=c("5d","3d"),fill=TRUE) {
  fmt<-match.arg(fmt); dep<-val(dep); mun<-val(mun)
  if(fill) {dep<-tidyr::fill(tibble(dep=dep),dep,.direction="down")$dep; mun<-tidyr::fill(tibble(mun=mun),mun,.direction="down")$mun}
  isnat<-str_detect(coalesce(mun,dep,""),regex("^Total Nacional$",ignore_case=TRUE))
  d<-str_match(coalesce(dep,""),"^\\s*(\\d{2})_\\s*(.+)$")
  if(fmt=="5d") {m<-str_match(coalesce(mun,""),"^(\\d{5})_(.+)$"); code<-m[,2]; nmun<-str_squish(m[,3]); depcode_raw<-d[,2]; depcode<-str_sub(code,1,2); ndep<-str_squish(d[,3])}
  else {m<-str_match(coalesce(mun,""),"^(\\d{3})_(.+)$"); depcode_raw<-d[,2]; code<-ifelse(is.na(depcode_raw)|is.na(m[,2]),NA_character_,paste0(depcode_raw,m[,2])); nmun<-str_squish(m[,3]); depcode<-depcode_raw; ndep<-str_squish(d[,3])}
  tibble(codigo_departamento=depcode,codigo_municipio=code,nombre_municipio=nmun,nombre_departamento=ndep,.nacional=isnat)
}
scan_department_labels <- function(tab,dep_col,mun_col,fmt,sheet,start_row,block) {
  dep_raw<-val(tab[[dep_col]]); mun_raw<-val(tab[[mun_col]])
  mun_fill<-fill(tibble(mun=mun_raw),mun,.direction="down")$mun
  ix<-which(!is.na(dep_raw)&seq_along(dep_raw)>=start_row&!str_detect(coalesce(dep_raw,""),regex("^Total Nacional$",ignore_case=TRUE)))
  map_dfr(ix,function(i) {
    label<-dep_raw[i]; dm<-str_match(label,"^\\s*(\\d{2})_\\s*(.*)$"); dcode<-dm[,2]; dname<-str_squish(dm[,3])
    mm<-if(fmt=="5d") str_match(coalesce(mun_fill[i],""),"^(\\d{5})_(.+)$") else str_match(coalesce(mun_fill[i],""),"^(\\d{3})_(.+)$")
    mcode<-if(fmt=="5d") mm[,2] else if(!is.na(dcode)&&!is.na(mm[,2])) paste0(dcode,mm[,2]) else NA_character_
    why<-character()
    if(is.na(dcode)) why<-c(why,"falta formato codigo_nombre") else if(is.na(dname)||dname=="") why<-c(why,"falta nombre departamental")
    if(!is.na(dcode)&&!is.na(mcode)&&dcode!=str_sub(mcode,1,2)) why<-c(why,"codigo departamental no coincide con codigo municipal")
    if(str_detect(label,"D0C0")) why<-c(why,"typo D0C0 en nombre de Bogota")
    if(!length(why)) return(tibble())
    tibble(hoja=sheet,columna_fila=paste0("fila ",i,"; bloque ",block,"; columna departamento"),codigo_municipio=mcode,etiqueta_origen=label,descripcion=paste(why,collapse="; "),evidencia=paste0("etiqueta=",label,"; municipio=",coalesce(mun_fill[i],""),"; codigo_municipio=",coalesce(mcode,"")))
  })
}
dept_scans<-list(
  list(tab=cn$HOGARES_MUNICIPAL,dep=1,mun=2,fmt="5d",sheet="HOGARES_MUNICIPAL",start=4,block="municipal"),
  list(tab=cn$PERSONA_DEMO,dep=1,mun=2,fmt="5d",sheet="PERSONA_DEMO",start=3,block="municipal"),
  list(tab=cn$PERSONA_SOCIAL,dep=1,mun=2,fmt="5d",sheet="PERSONA_SOCIAL",start=3,block="municipal"),
  list(tab=cn$VIVIENDAS,dep=1,mun=2,fmt="3d",sheet="VIVIENDAS",start=4,block="6V"),
  list(tab=cn$VIVIENDAS,dep=45,mun=46,fmt="3d",sheet="VIVIENDAS",start=4,block="8V"),
  list(tab=cn$VIVIENDAS,dep=70,mun=71,fmt="5d",sheet="VIVIENDAS",start=3,block="10V"),
  list(tab=cn$CONTEXTO,dep=1,mun=2,fmt="5d",sheet="CONTEXTO",start=3,block="1PM"),
  list(tab=cn$CONTEXTO,dep=11,mun=12,fmt="3d",sheet="CONTEXTO",start=3,block="1V")
)
dept_anomalies<-map_dfr(dept_scans,~scan_department_labels(.x$tab,.x$dep,.x$mun,.x$fmt,.x$sheet,.x$start,.x$block))
areas_norm <- function(x) case_when(str_to_lower(str_squish(x)) %in% c("total","total municipal")~"Total",str_to_lower(str_squish(x))=="cabecera"~"Cabecera",str_to_lower(str_squish(x))=="centro poblado"~"Centro poblado",str_to_lower(str_squish(x))=="rural disperso"~"Rural disperso",TRUE~NA_character_)
tidy_order <- function(x) x %>% select(codigo_departamento,codigo_municipio,nombre_municipio,nombre_departamento,everything())
municipal_only <- function(x) filter(x,!is.na(codigo_municipio),!is.na(codigo_departamento),!.nacional)
check_keys <- function(x,by,src,source_rows=NULL) {
  codes<-x$codigo_municipio
  bad<-is.na(codes)|!str_detect(codes,"^\\d{5}$")|str_detect(codes,"\\s")
  add_check("C\u00F3digo municipal cinco caracteres",src,length(codes),sum(bad),"cero inv\u00E1lidos")
  mismatch<-sum(!is.na(codes)&!is.na(x$codigo_departamento)&x$codigo_departamento!=str_sub(codes,1,2))
  add_check("Prefijo departamento coincide con municipio",src,length(codes),mismatch,"cero diferencias")
  d<-x %>% count(across(all_of(by)),name="n") %>% filter(n>1)
  add_check(paste("Unicidad",paste(by,collapse="+")),src,nrow(x),nrow(d),"cero duplicados",if(nrow(d)) paste(capture.output(print(head(d,20))),collapse=" ") else "")
  if(nrow(d)) add_disc("MEDIA",src,paste(by,collapse="+"),"Combinaciones llave duplicadas",paste(capture.output(print(head(d,20))),collapse=" "),"Revisar filas origen")
}
num_metrics <- function(x,cols,src,rows=seq_len(nrow(x))) {
  for(j in cols) if(j<=ncol(x)) {
    z<-as_num(x[[j]][rows]); raw<-val(x[[j]][rows])
    sent<-str_detect(coalesce(raw,""),regex("^(--|\\*|N\\.?D\\.?|NA)$",ignore_case=TRUE)); unc<-!is.na(raw)&is.na(z)
    add_check(paste0("Conversi\u00F3n num\u00E9rica columna ",j),src,length(raw),sum(unc&!sent),"Sin no-convertibles inesperados",paste0("no_convertibles=",sum(unc),"; de_ellos_sentinelas=",sum(unc&sent),"; negativos=",sum(z<0,na.rm=TRUE),"; no_enteros=",sum(abs(z-round(z))>1e-8,na.rm=TRUE)))
  }
}
check_sum <- function(df,group,cols,totalcol,label,tol=0) {
  z<-df %>% group_by(across(all_of(group))) %>% summarise(total=first(.data[[totalcol]]),sum=sum(c_across(all_of(cols)),na.rm=FALSE),.groups="drop")
  bad<-sum(!is.na(z$total)&!is.na(z$sum)&abs(z$total-z$sum)>tol)
  add_check(label,paste(unique(df$.src),collapse="/"),nrow(z),bad,paste0("abs<=",tol),paste0("total faltantes=",sum(is.na(z$total)),"; sum faltante=",sum(is.na(z$sum))))
  invisible(z)
}
check_area_totals <- function(df,groups,measures,label,tol=0) {
  for(vv in measures) {
    w<-df %>% select(all_of(c(groups,"area",vv))) %>% pivot_wider(names_from=area,values_from=all_of(vv),values_fn=list)
    needed<-c("Total","Cabecera","Centro poblado","Rural disperso")
    if(!all(needed%in%names(w))) {add_check(paste(label,"\u00E1reas",vv),label,0L,0L,paste0("abs<=",tol),"Falta una columna de \u00E1rea en la tabla");next}
    # values_fn=list preserves duplicates for audit; vector cells signal duplicates and are excluded here.
    valid<-map_lgl(seq_len(nrow(w)),~all(map_lgl(w[.x,needed,drop=FALSE],~length(.x[[1]])==1L && !is.na(.x[[1]]))))
    ev<-sum(valid); bad<-sum(map_lgl(which(valid),function(i) abs(w$Total[[i]][1]-w$Cabecera[[i]][1]-w$`Centro poblado`[[i]][1]-w$`Rural disperso`[[i]][1])>tol))
    add_check(paste(label,"Total=\u00E1reas",vv),label,ev,bad,paste0("abs<=",tol),paste0("combinaciones sin las 4 \u00E1reas=",sum(!valid)))
  }
}
write_table <- function(x,name) write_csv(tidy_order(x),file.path(inter,name),na="")
markdown_table <- function(x) {
  if (is.null(x) || nrow(x)==0L) return("_Sin filas._")
  x <- as.data.frame(x,stringsAsFactors=FALSE,check.names=FALSE)
  cell <- function(z) {
    z <- ifelse(is.na(z),"",as.character(z))
    z <- gsub("[\r\n]+"," ",z)
    gsub("|","\\|",z,fixed=TRUE)
  }
  heads <- names(x)
  rows <- lapply(seq_len(nrow(x)),function(i) vapply(x,function(z) cell(z[i]),character(1)))
  lines <- c(paste0("| ",paste(cell(heads),collapse=" | ")," |"),paste0("| ",paste(rep("---",length(heads)),collapse=" | ")," |"),vapply(rows,function(z)paste0("| ",paste(z,collapse=" | ")," |"),character(1)))
  paste(lines,collapse="\n")
}
source_tables<-list(); presence<-list()

message("[2/9] HOGARES, persona y bloques tabulares")
# HOGARES: 3 encabezados, nacional fila 4, municipios filas 5+
h<-cn$HOGARES_MUNICIPAL; hh<-h[5:nrow(h),,drop=FALSE]; hk<-key_from_labels(hh[[1]],hh[[2]],"5d")
areas<-c("Total","Cabecera","Centro poblado","Rural disperso")
hlong<-map_dfr(seq_along(areas),function(a){c1<-3+(a-1)*3;c2<-15+(a-1)*3;tibble(hk,area=areas[a],hogares_total=as_num(hh[[c1]]),hogares_menores15=as_num(hh[[c1+1]]),personas_menores15=as_num(hh[[c1+2]]),hogares_total_2HM=as_num(hh[[c2]]),hogares_adultos_mayores=as_num(hh[[c2+1]]),personas_60mas=as_num(hh[[c2+2]]))}) %>% municipal_only() %>% select(-.nacional)
source_tables$hogares<-hlong; presence$hogares<-unique(hlong$codigo_municipio); check_keys(hlong,c("codigo_municipio","area"),"HOGARES_MUNICIPAL"); write_table(hlong,"hogares_1HM_2HM.csv")
num_metrics(h,3:26,"HOGARES_MUNICIPAL",4:nrow(h))
for(m in c("hogares_total","hogares_menores15","personas_menores15","hogares_total_2HM","hogares_adultos_mayores","personas_60mas")) {w<-hlong %>% select(codigo_municipio,area,all_of(m)) %>% pivot_wider(names_from=area,values_from=all_of(m)); if(all(areas %in% names(w))) add_check(paste("Suma de \u00E1reas",m),"HOGARES_MUNICIPAL",nrow(w),sum(abs(w$Total-w$Cabecera-w$`Centro poblado`-w$`Rural disperso`)>0,na.rm=TRUE),"exacta")}

person_tidy <- function(tab,sheet,header_rows,first_data,order_sex,vals_start,vals_end,cats) {
  x<-tab[first_data:nrow(tab),,drop=FALSE]
  # Department and municipality are repeated/blank depending on blocks; fill only those key columns.
  k<-key_from_labels(x[[1]],x[[2]],"5d")
  area<-tidyr::fill(tibble(area=areas_norm(x[[3]])),area,.direction="down")$area
  sex<-tidyr::fill(tibble(sexo=val(x[[4]])),sexo,.direction="down")$sexo
  sex[!sex %in% c("Hombre","Mujer","Total")]<-NA_character_
  out<-bind_cols(k,tibble(area=area,sexo=sex),as_tibble(map_dfc(seq(vals_start,vals_end),~as_num(x[[.x]]))))
  names(out)[(ncol(out)-length(cats)+1):ncol(out)]<-cats
  out<-(out %>% municipal_only() %>% filter(!is.na(area),!is.na(sexo)) %>% select(-.nacional))
  list(data=out,raw=x)
}
pd<-cn$PERSONA_DEMO; demo_names<-make_clean_names(as.character(unlist(pd[2,6:20])))
demo<-person_tidy(pd,"PERSONA_DEMO",2,15,c("Hombre","Mujer","Total"),5,20,c("total",demo_names))$data
source_tables$demo<-demo; presence$persona_demo<-unique(demo$codigo_municipio); check_keys(demo,c("codigo_municipio","area","sexo"),"PERSONA_DEMO"); write_table(demo,"persona_demo_17PM.csv"); num_metrics(pd,5:20,"PERSONA_DEMO",3:nrow(pd))
for(v in c("total",demo_names)) {w<-demo %>% select(codigo_municipio,area,sexo,all_of(v)) %>% pivot_wider(names_from=sexo,values_from=all_of(v)); if(all(c("Total","Hombre","Mujer") %in% names(w))) add_check(paste("Total=Hombre+Mujer",v),"PERSONA_DEMO",nrow(w),sum(abs(w$Total-w$Hombre-w$Mujer)>0,na.rm=TRUE),"exacta")}
check_area_totals(demo,c("codigo_municipio","sexo"),c("total",demo_names),"PERSONA_DEMO")
row_sum_demo<-rowSums(as.data.frame(lapply(pd[15:nrow(pd),6:20],as_num)),na.rm=FALSE); total_demo<-as_num(pd[[5]][15:nrow(pd)]); add_check("17PM E=suma(F:T)","PERSONA_DEMO",length(total_demo),sum(abs(total_demo-row_sum_demo)>0,na.rm=TRUE),"exacta",paste0("diferencias no NA=",sum(!is.na(total_demo)&!is.na(row_sum_demo)&total_demo!=row_sum_demo)))

ps<-cn$PERSONA_SOCIAL; social_names<-make_clean_names(as.character(unlist(ps[2,6:15])))
social<-person_tidy(ps,"PERSONA_SOCIAL",2,15,c("Total","Hombre","Mujer"),5,15,c("total",social_names))$data
source_tables$social<-social; presence$persona_social<-unique(social$codigo_municipio); check_keys(social,c("codigo_municipio","area","sexo"),"PERSONA_SOCIAL"); write_table(social,"persona_social_5PM.csv"); num_metrics(ps,5:15,"PERSONA_SOCIAL",3:nrow(ps))
for(v in c("total",social_names)) {w<-social %>% select(codigo_municipio,area,sexo,all_of(v)) %>% pivot_wider(names_from=sexo,values_from=all_of(v)); if(all(c("Total","Hombre","Mujer") %in% names(w))) add_check(paste("Total=Hombre+Mujer",v),"PERSONA_SOCIAL",nrow(w),sum(abs(w$Total-w$Hombre-w$Mujer)>0,na.rm=TRUE),"exacta")}
check_area_totals(social,c("codigo_municipio","sexo"),c("total",social_names),"PERSONA_SOCIAL")
row_sum_social<-rowSums(as.data.frame(lapply(ps[15:nrow(ps),6:15],as_num)),na.rm=FALSE); total_social<-as_num(ps[[5]][15:nrow(ps)]); add_check("5PM E=suma(F:O)","PERSONA_SOCIAL",length(total_social),sum(abs(total_social-row_sum_social)>0,na.rm=TRUE),"exacta")

message("[3/9] Bloques independientes de VIVIENDAS y CONTEXTO")
v<-cn$VIVIENDAS
# B1: fila 4 total nacional; municipios desde fila 5. C\u00F3digo 3d + depto.
b1<-v[5:nrow(v),1:44,drop=FALSE]; k1<-key_from_labels(b1[[1]],b1[[2]],"3d"); typ<-tidyr::fill(tibble(tipo=val(b1[[3]])),tipo,.direction="down")$tipo
wallnames<-make_clean_names(as.character(unlist(v[3,5:13])))
b1out<-bind_cols(k1,tibble(tipo_vivienda=typ),map_dfc(seq(4,43),function(j) tibble(!!paste0("col",j):=as_num(b1[[j]]))))
names(b1out)[6:45]<-paste0("pared_",rep(c("total","material"),length.out=40)) # overwritten below with stable area variables
var6<-c("total","bloque_ladrillo_piedra_madera_pulida","concreto_vaciado","material_prefabricado","guadua","tapia_bahareque_adobe","madera_burda","cana_vegetales","desecho","sin_paredes")
area_cols<-list(Total=4:13,Cabecera=14:23,`Centro poblado`=24:33,`Rural disperso`=34:43)
b1out<-bind_cols(k1,tibble(tipo_vivienda=typ),map_dfc(names(area_cols),function(a) {cc<-area_cols[[a]]; as_tibble(set_names(map(cc,~as_num(b1[[.x]])),paste0(a,"_",var6)))}))
b1out<-b1out %>% mutate(across(starts_with("Total_"),identity)) %>% municipal_only() %>% select(-.nacional)
names(b1out)<-str_to_lower(names(b1out)); names(b1out)<-str_replace_all(names(b1out)," ","_")
# Cuando readxl no recibe valor cacheado de una f\u00F3rmula, se recalcula \u00FAnicamente
# esa celda como suma de las nueve categor\u00EDas fuente y se deja evidencia.
formula_map<-list(cabecera=c(14,15:23),centro_poblado=c(24,25:33),rural_disperso=c(34,35:43))
for(ar in names(formula_map)) {jj<-formula_map[[ar]][1]; mats<-paste0(ar,"_",var6[-1]); cached<-as_num(v[[jj]][5:nrow(v)]); sm<-rowSums(as.data.frame(lapply(v[formula_map[[ar]][-1]][5:nrow(v),,drop=FALSE],as_num)),na.rm=FALSE); add_check(paste0("Cach\u00E9 f\u00F3rmula ",excel_col(jj)," = suma materiales"),"VIVIENDAS_6V",length(cached),sum(!is.na(cached)&!is.na(sm)&abs(cached-sm)>0),"exacta",paste0("sin cache=",sum(is.na(cached)),"; rec\u00E1lculos necesarios=",sum(is.na(cached)&!is.na(sm)))); if(length(cached)==nrow(b1out)) b1out[[paste0(ar,"_total")]]<-ifelse(is.na(cached),sm,cached)}
source_tables$v6<-b1out; presence$viviendas_6V<-unique(b1out$codigo_municipio); check_keys(b1out,c("codigo_municipio","tipo_vivienda"),"VIVIENDAS_6V"); write_table(b1out,"viviendas_6V.csv")
num_metrics(v,4:43,"VIVIENDAS_6V",4:nrow(v))
for(ar in names(area_cols)) {tot<-paste0(str_to_lower(str_replace_all(ar," ","_")),"_total"); mats<-paste0(str_to_lower(str_replace_all(ar," ","_")),"_",var6[-1]); if(tot %in% names(b1out)) add_check(paste("6V total=9 materiales",ar),"VIVIENDAS_6V",nrow(b1out),sum(abs(b1out[[tot]]-rowSums(as.data.frame(b1out[mats]),na.rm=FALSE))>0,na.rm=TRUE),"exacta")}
for(ar in names(area_cols)) {pfx<-paste0(str_to_lower(str_replace_all(ar," ","_")),"_"); for(vv in var6) {col<-paste0(pfx,vv); w<-b1out %>% select(codigo_municipio,tipo_vivienda,all_of(col)) %>% pivot_wider(names_from=tipo_vivienda,values_from=all_of(col)); other<-setdiff(names(w),c("codigo_municipio",col)); if("Total"%in%other&&length(other)>0) add_check(paste("6V tipo Total=suma tipos",ar,vv),"VIVIENDAS_6V",nrow(w),sum(abs(w$Total-rowSums(as.data.frame(w[setdiff(other,"Total")]),na.rm=TRUE))>0,na.rm=TRUE),"suma de tipos observados; ausencias estructurales excluidas")}}
for(vv in var6) {cc<-paste0(c("total","cabecera","centro_poblado","rural_disperso"),"_",vv); if(all(cc%in%names(b1out))) add_check(paste("6V Total=Cabecera+Centro+Rural",vv),"VIVIENDAS_6V",nrow(b1out),sum(abs(b1out[[cc[1]]]-b1out[[cc[2]]]-b1out[[cc[3]]]-b1out[[cc[4]]])>0,na.rm=TRUE),"exacta")}
# B2 areas: col 46 municipio, 45 depto, 47 area; 48:68 medidas.
b2<-v[4:nrow(v),45:69,drop=FALSE]; k2<-key_from_labels(b2[[1]],b2[[2]],"3d"); ar2<-areas_norm(b2[[3]])
cols8<-make_clean_names(c("viviendas_presentes","energia_total","energia_si","energia_no","acueducto_total","acueducto_si","acueducto_no","alcantarillado_total","alcantarillado_si","alcantarillado_no","gas_total","gas_si","gas_no","gas_sin_informacion","basuras_total","basuras_si","basuras_no","internet_total","internet_si","internet_no","internet_sin_informacion"))
b2out<-bind_cols(k2,tibble(area=ar2),as_tibble(map_dfc(4:24,~as_num(b2[[.x]])))); names(b2out)[7:27]<-cols8; b2out<-b2out %>% municipal_only() %>% filter(!is.na(area)) %>% select(-.nacional)
source_tables$v8<-b2out; presence$viviendas_8V<-unique(b2out$codigo_municipio); check_keys(b2out,c("codigo_municipio","area"),"VIVIENDAS_8V"); write_table(b2out,"viviendas_8V.csv"); num_metrics(v,48:68,"VIVIENDAS_8V",4:nrow(v))
for(srv in c("energia","acueducto","alcantarillado","gas","basuras","internet")) {tc<-paste0(srv,"_total"); cats<-grep(paste0("^",srv,"_(si|no|sin_informacion)$"),names(b2out),value=TRUE); if(tc%in%names(b2out)) add_check(paste("8V categor\u00EDas suman total",srv),"VIVIENDAS_8V",nrow(b2out),sum(abs(b2out[[tc]]-rowSums(as.data.frame(b2out[cats]),na.rm=FALSE))>0,na.rm=TRUE),"exacta")}
check_area_totals(b2out,"codigo_municipio",cols8,"VIVIENDAS_8V")
# B3: fila 3 nacional total; datos 4+, fixed 70:83. 
b3<-v[4:nrow(v),70:83,drop=FALSE]; k3<-key_from_labels(b3[[1]],b3[[2]],"5d"); ar3<-areas_norm(b3[[3]])
cols10<-c("personas_hogares_particulares","sin_servicio_energia","no_tiene_estrato",paste0("estrato_",1:6),"no_sabe_no_responde")
b3out<-bind_cols(k3,tibble(area=ar3),as_tibble(map_dfc(4:13,~as_num(b3[[.x]])))); names(b3out)[7:16]<-cols10; b3out<-b3out %>% municipal_only() %>% filter(!is.na(area)) %>% select(-.nacional)
source_tables$v10<-b3out; presence$viviendas_10V<-unique(b3out$codigo_municipio); check_keys(b3out,c("codigo_municipio","area"),"VIVIENDAS_10V"); write_table(b3out,"viviendas_10V.csv"); num_metrics(v,73:82,"VIVIENDAS_10V",3:nrow(v))
add_check("10V BU=suma BV:CD","VIVIENDAS_10V",nrow(b3out),sum(abs(b3out$personas_hogares_particulares-rowSums(as.data.frame(b3out[cols10[-1]]),na.rm=FALSE))>0,na.rm=TRUE),"exacta")
diff_bv_bw<-b3out$sin_servicio_energia-b3out$no_tiene_estrato
add_check("10V relaci\u00F3n BV sin energ\u00EDa y BW no tiene estrato","VIVIENDAS_10V",nrow(b3out),0,"descriptivo; no se presupone igualdad",paste0("suma_BV=",sum(b3out$sin_servicio_energia,na.rm=TRUE),"; suma_BW=",sum(b3out$no_tiene_estrato,na.rm=TRUE),"; iguales=",sum(diff_bv_bw==0,na.rm=TRUE),"; BV>BW=",sum(diff_bv_bw>0,na.rm=TRUE),"; BV<BW=",sum(diff_bv_bw<0,na.rm=TRUE)))
check_area_totals(b3out,"codigo_municipio",cols10,"VIVIENDAS_10V")
# Context block 1PM and 1V
z<-cn$CONTEXTO
z1<-z[3:nrow(z),1:10,drop=FALSE]; kz1<-key_from_labels(z1[[1]],z1[[2]],"5d"); ar1<-tidyr::fill(tibble(area=areas_norm(z1[[3]])),area,.direction="down")$area; age<-tidyr::fill(tibble(grupo_edad=val(z1[[4]])),grupo_edad,.direction="down")$grupo_edad
ctx1<-bind_cols(kz1,tibble(area=ar1,grupo_edad=age),as_tibble(map_dfc(5:9,~as_num(z1[[.x]])))); names(ctx1)[8:12]<-c("total","hombre","mujer","indice_masculinidad","indice_feminidad"); ctx1<-ctx1 %>% municipal_only() %>% filter(!is.na(area),!is.na(grupo_edad)) %>% select(-.nacional)
source_tables$ctx1<-ctx1; presence$contexto_1PM<-unique(ctx1$codigo_municipio); check_keys(ctx1,c("codigo_municipio","area","grupo_edad"),"CONTEXTO_1PM"); write_table(ctx1,"contexto_1PM.csv"); num_metrics(z,5:9,"CONTEXTO_1PM",3:nrow(z))
z2<-z[3:nrow(z),11:20,drop=FALSE]; kz2<-key_from_labels(z2[[1]],z2[[2]],"3d"); ar2c<-areas_norm(z2[[3]]); typ2<-tidyr::fill(tibble(tipo=val(z2[[4]])),tipo,.direction="down")$tipo
ctx2<-bind_cols(kz2,tibble(area=ar2c,tipo_vivienda=typ2),as_tibble(map_dfc(5:9,~as_num(z2[[.x]])))); names(ctx2)[8:12]<-c("viviendas_total","ocupada_presentes","ocupada_ausentes","temporal_vacaciones","desocupada"); ctx2<-ctx2 %>% municipal_only() %>% filter(!is.na(area),!is.na(tipo_vivienda)) %>% select(-.nacional)
source_tables$ctx2<-ctx2; presence$contexto_1V<-unique(ctx2$codigo_municipio); check_keys(ctx2,c("codigo_municipio","area","tipo_vivienda"),"CONTEXTO_1V"); write_table(ctx2,"contexto_1V.csv"); num_metrics(z,15:19,"CONTEXTO_1V",3:nrow(z))
check_area_totals(ctx1,c("codigo_municipio","grupo_edad"),c("total","hombre","mujer"),"CONTEXTO_1PM")
check_area_totals(ctx2,c("codigo_municipio","tipo_vivienda"),c("viviendas_total","ocupada_presentes","ocupada_ausentes","temporal_vacaciones","desocupada"),"CONTEXTO_1V")

# Guarda por separado las filas nacionales y compara los agregados Total
# municipales contra sus valores publicados, sin reemplazar ni corregirlos.
nat_rows<-list()
append_nat<-function(sheet,block,rows,cols,area_col=NULL,dim_col=NULL) {
  x<-cn[[sheet]]
  for(r in rows) for(j in cols) nat_rows[[length(nat_rows)+1L]]<<-tibble(hoja=sheet,bloque=block,fila_excel=as.integer(r),area=if(is.null(area_col)) NA_character_ else areas_norm(x[[area_col]][r]),dimension=if(is.null(dim_col)) NA_character_ else as.character(x[[dim_col]][r]),columna=excel_col(j),variable=as.character(x[[j]][min(3,nrow(x))]),valor_original=val(x[[j]][r]))
}
append_nat("HOGARES_MUNICIPAL","1HM_2HM",4,3:26)
append_nat("PERSONA_DEMO","17PM",3:14,5:20,3,4)
append_nat("PERSONA_SOCIAL","5PM",3:14,5:15,3,4)
append_nat("VIVIENDAS","6V_MPIO",4,4:43,3)
append_nat("VIVIENDAS","8V_MPIO",4:7,48:68,47)
append_nat("VIVIENDAS","10V_MPIO",3:6,73:82,72)
append_nat("CONTEXTO","1PM",3,5:9,3,4)
append_nat("CONTEXTO","1V_MPIO",3,15:19,13,14)
nat<-bind_rows(nat_rows); write_csv(nat,file.path(inter,"control_nacional.csv"),na="")
compare_nat<-function(label,sheet,national,municipal) {
  n<-as_num(national); m<-sum(as_num(municipal),na.rm=FALSE); absd<-abs(n-m); reld<-if(is.na(n)||n==0) NA_real_ else absd/abs(n); bad<-is.na(absd)||absd>0
  add_check(paste("Total Nacional vs suma municipal",label),sheet,1L,as.integer(bad),"exacta",paste0("nacional=",n,"; suma_municipios=",m,"; n_municipal_NA=",sum(is.na(as_num(municipal))),"; diferencia_absoluta=",absd,"; diferencia_relativa=",reld))
}
cell<-function(tab,r,c) tab[[c]][r]
for(vv in c("hogares_total","hogares_menores15","personas_menores15","hogares_total_2HM","hogares_adultos_mayores","personas_60mas")) {
  colnat<-switch(vv,hogares_total=3L,hogares_menores15=4L,personas_menores15=5L,hogares_total_2HM=15L,hogares_adultos_mayores=16L,personas_60mas=17L)
  compare_nat(vv,"HOGARES_MUNICIPAL",cell(h,4,colnat),filter(hlong,area=="Total")[[vv]])
}
for(vv in c("total",demo_names)) for(sx in c("Hombre","Mujer","Total")) {rnat<-match(sx,as.character(pd[[4]][3:5]))+2L; jnat<-5L+match(vv,c("total",demo_names))-1L; compare_nat(paste(vv,sx),"PERSONA_DEMO",cell(pd,rnat,jnat),filter(demo,area=="Total",sexo==sx)[[vv]])}
for(vv in c("total",social_names)) for(sx in c("Total","Hombre","Mujer")) {rnat<-match(sx,as.character(ps[[4]][3:5]))+2L; jnat<-5L+match(vv,c("total",social_names))-1L; compare_nat(paste(vv,sx),"PERSONA_SOCIAL",cell(ps,rnat,jnat),filter(social,area=="Total",sexo==sx)[[vv]])}
for(ar in names(area_cols)) for(vv in var6) {vcol<-paste0(str_to_lower(str_replace_all(ar," ","_")),"_",vv); national_j<-area_cols[[ar]][match(vv,var6)]; compare_nat(paste("6V",ar,vv),"VIVIENDAS",cell(v,4,national_j),filter(b1out,tipo_vivienda=="Total")[[vcol]])}
for(ai in seq_along(areas)) for(jj in seq_along(cols8)) compare_nat(paste("8V",areas[ai],cols8[jj]),"VIVIENDAS",cell(v,3+ai,47+jj),filter(b2out,area==areas[ai])[[cols8[jj]]])
for(ai in seq_along(areas)) for(jj in seq_along(cols10)) compare_nat(paste("10V",areas[ai],cols10[jj]),"VIVIENDAS",cell(v,2+ai,72+jj),filter(b3out,area==areas[ai])[[cols10[jj]]])
for(vv in c("total","hombre","mujer")) {jnat<-match(vv,c("total","hombre","mujer"))+4L; compare_nat(paste("1PM",vv),"CONTEXTO",cell(z,3,jnat),filter(ctx1,area=="Total",grupo_edad=="Total")[[vv]])}
for(vv in c("viviendas_total","ocupada_presentes","ocupada_ausentes","temporal_vacaciones","desocupada")) {jnat<-match(vv,c("viviendas_total","ocupada_presentes","ocupada_ausentes","temporal_vacaciones","desocupada"))+14L; compare_nat(paste("1V",vv),"CONTEXTO",cell(z,3,jnat),filter(ctx2,area=="Total",tipo_vivienda=="Total")[[vv]])}

message("[4/9] IPM: normalizaci\u00F3n, rangos y consistencia entre hojas")
ip0<-ib$IPM_municipios_region
iphead<-as.character(unlist(ip0[1,])); ip<-as_tibble(ip0[-1,,drop=FALSE],.name_repair="minimal"); names(ip)<-clean_header(iphead)
if(!"id"%in%names(ip)) add_disc("ALTA","IPM_municipios_region","C","Falta encabezado ID","Columnas: ","Revisar esquema")
ip<-ip %>% mutate(codigo_municipio=str_trim(id),codigo_departamento=str_sub(codigo_municipio,1,2),nombre_municipio=municipio,nombre_departamento=departamento)
ip$ipm_municipal<-as_num(ip$ipm_municipal); ip$ipm<-as_num(ip$ipm); ip$cabeceras<-as_num(ip$cabeceras)
ipmvars<-names(ip)[9:23]
for(vv in c("ipm_centros_poblados_y_rural_disperso",ipmvars)) ip[[vv]]<-as_num(ip[[vv]])
num_metrics(ip0,5:23,"IPM_municipios_region",2:nrow(ip0))
ipmout<-ip %>% select(codigo_departamento,codigo_municipio,nombre_municipio,nombre_departamento,region_geografica,municipio,ipm_municipal,ipm,cabeceras,ipm_centros_poblados_y_rural_disperso,all_of(ipmvars))
write_table(ipmout,"ipm_municipal_ancho.csv"); presence$ipm<-unique(ip$codigo_municipio)
check_keys(ip,c("codigo_municipio"),"IPM_municipios_region")
add_check("ID cinco d\u00EDgitos IPM","IPM_municipios_region",nrow(ip),sum(!str_detect(ip$codigo_municipio,"^\\d{5}$")),"0")
add_check("IPM Municipal=IPM","IPM_municipios_region",nrow(ip),sum(abs(ip$ipm_municipal-ip$ipm)>1e-12,na.rm=TRUE),"exacta")
for(vv in c("ipm_municipal","ipm","cabeceras","ipm_centros_poblados_y_rural_disperso",ipmvars)) {x<-as_num(ip[[vv]]); add_check(paste("IPM rango [0,100]",vv),"IPM_municipios_region",length(x),sum(x<0|x>100,na.rm=TRUE),"0-100")}
# Largo municipal comparado con ancho
longm<-ib$Indicadores_municipales; lh<-as.character(unlist(longm[1,])); longm<-as.data.frame(longm[-1,,drop=FALSE],check.names=FALSE); names(longm)<-clean_header(lh)
longm<-longm %>% mutate(codigo_municipio=str_trim(id),valor_num=as_num(valor),variable_indice=str_squish(variable_indice))
mapwide<-ip %>% select(codigo_municipio,all_of(c("ipm_municipal","ipm","cabeceras","ipm_centros_poblados_y_rural_disperso",ipmvars))) %>% pivot_longer(-codigo_municipio,names_to="variable_indice",values_to="valor_ancho")
mapwide$variable_indice<-str_to_lower(str_squish(mapwide$variable_indice)); longm$variable_indice<-str_to_lower(str_squish(make_clean_names(longm$variable_indice)))
wide_key<-mapwide %>% mutate(variable_indice=str_replace_all(variable_indice,"_"," "))
long_key<-longm %>% mutate(variable_indice=str_replace_all(variable_indice,"_"," "))
cmp<-long_key %>% left_join(wide_key,by=c("codigo_municipio","variable_indice"))
add_check("Consistencia IPM ancho vs Indicadores_municipales","Indicadores_municipales",nrow(cmp),sum(abs(cmp$valor_num-cmp$valor_ancho)>1e-6,na.rm=TRUE),"1e-6",paste0("sin pareja=",sum(is.na(cmp$valor_ancho))))
num_metrics(longm,6,"Indicadores_municipales",seq_len(nrow(longm)))
# Indicadores por dominio: valide subset municipal Total con largo municipal cuando aplica
ld<-ib$Indicadores_por_dominio; dh<-as.character(unlist(ld[1,])); ld<-as.data.frame(ld[-1,,drop=FALSE],check.names=FALSE); names(ld)<-clean_header(dh)
ld<-ld %>% mutate(codigo_municipio=str_trim(id),valor_num=as_num(valor))
add_check("Dominio IPM entre valores admitidos","Indicadores_por_dominio",nrow(ld),sum(!ld$dominio_geografico%in%c("Total","Cabeceras","Centros poblados y rural disperso"),na.rm=TRUE),"dominios declarados")
num_metrics(ld,7,"Indicadores_por_dominio",seq_len(nrow(ld)))
ld_total<-ld %>% filter(dominio_geografico=="Total") %>% select(codigo_municipio,variable_indice,valor_num) %>% left_join(longm %>% select(codigo_municipio,variable_indice,valor_largo=valor_num),by=c("codigo_municipio","variable_indice"))
add_check("Indicadores_por_dominio Total coincide con Indicadores_municipales","Indicadores_por_dominio",nrow(ld_total),sum(abs(ld_total$valor_num-ld_total$valor_largo)>1e-6,na.rm=TRUE),"1e-6",paste0("sin par en largo municipal=",sum(is.na(ld_total$valor_largo))))

message("[5/9] Cobertura municipal y DIVIPOLA")
div<-read_csv(f_div,col_types=cols(.default=col_character()),locale=locale(encoding="UTF-8"),na=c("","NA"),name_repair="minimal",show_col_types=FALSE); names(div)<-str_squish(names(div))
pick<-function(nm,pat) {i<-which(str_detect(nm,regex(pat,ignore_case=TRUE)));if(length(i))i[1] else NA_integer_}
dc<-pick(names(div),"C\u00F3digo Municipio$"); dn<-pick(names(div),"Nombre Municipio$"); dd<-pick(names(div),"Nombre Departamento$"); dt<-pick(names(div),"Tipo: Municipio")
if(anyNA(c(dc,dn,dd,dt))) {dc<-3L;dd<-2L;dn<-4L;dt<-5L}
div$codigo_municipio<-str_pad(str_trim(div[[dc]]),5,pad="0"); div$codigo_departamento<-str_sub(div$codigo_municipio,1,2)
divkey<-tibble(codigo_municipio=div$codigo_municipio,codigo_departamento=div$codigo_departamento,nombre_municipio=as.character(div[[dn]]),nombre_departamento=as.character(div[[dd]]),tipo_divipola=as.character(div[[dt]])) %>% distinct(codigo_municipio,.keep_all=TRUE)
dept_ref<-divkey%>%distinct(codigo_departamento,nombre_departamento)%>%mutate(etiqueta_referencia=paste0(codigo_departamento,"_",nombre_departamento))
dept_anomalies<-dept_anomalies%>%mutate(codigo_departamento=str_sub(codigo_municipio,1,2))%>%left_join(dept_ref,by="codigo_departamento")
for(i in seq_len(nrow(dept_anomalies))) add_disc("BAJA",dept_anomalies$hoja[i],dept_anomalies$columna_fila[i],paste0("Etiqueta departamental de origen anomala: ",dept_anomalies$descripcion[i],"; sin efecto: la llave se toma del codigo municipal"),paste0(dept_anomalies$evidencia[i],"; etiqueta departamental DIVIPOLA por codigo=",coalesce(dept_anomalies$etiqueta_referencia[i],"sin referencia")),"Sin efecto: la llave se toma del codigo municipal")
divcode<-div$codigo_municipio
add_check("DIVIPOLA longitud c\u00F3digo","DIVIPOLA",nrow(div),sum(nchar(divcode)!=5|is.na(divcode)),"cinco caracteres")
add_check("DIVIPOLA c\u00F3digo \u00FAnico","DIVIPOLA",length(divcode),sum(duplicated(divcode)),"0")
all_codes<-sort(unique(c(unlist(presence,use.names=FALSE),divcode)))
all_codes<-all_codes[str_detect(all_codes,"^\\d{5}$")]
presence_cols<-map_dfc(names(presence),~tibble(!! .x := all_codes%in%presence[[.x]]))
cov<-bind_cols(tibble(codigo_municipio=all_codes),presence_cols,tibble(divipola=all_codes%in%divcode))
write_csv(cov,file.path(out,"cobertura_municipal_por_hoja.csv"))
ipm_names<-ip %>% transmute(codigo_municipio,nombre_municipio_ipm=municipio,nombre_departamento_ipm=departamento) %>% distinct(codigo_municipio,.keep_all=TRUE)
master<-tibble(codigo_municipio=all_codes,codigo_departamento=str_sub(all_codes,1,2)) %>% left_join(divkey,by=c("codigo_municipio","codigo_departamento")) %>% left_join(ipm_names,by="codigo_municipio") %>% mutate(nombre_municipio=coalesce(nombre_municipio,nombre_municipio_ipm),nombre_departamento=coalesce(nombre_departamento,nombre_departamento_ipm),en_divipola=codigo_municipio%in%divcode,en_ipm=codigo_municipio%in%presence$ipm)
for(nm in names(presence)) master[[nm]]<-all_codes%in%presence[[nm]]
master<-master %>% mutate(tiene_cabecera=NA,tiene_centro_poblado=NA)
# CNPV area coverage flags derive from explicit area labels in source blocks.
census_codes<-presence$hogares
master$tiene_cabecera<-ifelse(all_codes%in%census_codes,all_codes%in%unique(b2out$codigo_municipio[b2out$area=="Cabecera"]),NA)
master$tiene_centro_poblado<-ifelse(all_codes%in%census_codes,all_codes%in%unique(b2out$codigo_municipio[b2out$area=="Centro poblado"]),NA)
master<-master %>% select(-nombre_municipio_ipm,-nombre_departamento_ipm)
write_csv(master,file.path(out,"universo_municipal_maestro.csv"))
dep_lookup<-divkey %>% distinct(codigo_departamento,nombre_departamento)
file_lookup<-c(hogares="hogares_1HM_2HM.csv",demo="persona_demo_17PM.csv",social="persona_social_5PM.csv",v6="viviendas_6V.csv",v8="viviendas_8V.csv",v10="viviendas_10V.csv",ctx1="contexto_1PM.csv",ctx2="contexto_1V.csv")
for(nm in names(source_tables)) {tt<-source_tables[[nm]]; ix<-match(tt$codigo_departamento,dep_lookup$codigo_departamento); tt$nombre_departamento<-coalesce(tt$nombre_departamento,dep_lookup$nombre_departamento[ix]); source_tables[[nm]]<-tt; write_table(tt,file_lookup[[nm]])}
write_table(ipmout %>% mutate(nombre_municipio=coalesce(nombre_municipio,ip$municipio),nombre_departamento=coalesce(nombre_departamento,ip$departamento)),"ipm_municipal_ancho.csv")
for(nm in names(presence)) add_check("Conjunto municipal igual a IPM",nm,length(presence[[nm]]),as.integer(!setequal(presence[[nm]],presence$ipm)),"0 diferencias")
add_check("Diferencias DIVIPOLA/IPM","DIVIPOLA",length(divcode),sum(!divcode%in%presence$ipm)+sum(!presence$ipm%in%divcode),"reportar ambas",paste("DIVIPOLA solo:",paste(setdiff(divcode,presence$ipm),collapse=","),"; IPM solo:",paste(setdiff(presence$ipm,divcode),collapse=",")))
add_check("Municipios sin Cabecera","CNPV/IPM",length(census_codes),0,"solo informar",paste0("n sin cabecera en CNPV=",sum(master$tiene_cabecera==FALSE,na.rm=TRUE),"; fuera de CNPV=",sum(is.na(master$tiene_cabecera))))
add_check("Municipios sin Centro poblado","CNPV/IPM",length(census_codes),0,"solo informar",paste0("n sin centro poblado en CNPV=",sum(master$tiene_centro_poblado==FALSE,na.rm=TRUE),"; fuera de CNPV=",sum(is.na(master$tiene_centro_poblado))))
for(ar in areas) add_check(paste("Cobertura del \u00E1rea",ar),"VIVIENDAS_8V",length(unique(b2out$codigo_municipio)),0,"solo informar",paste0("municipios con fila de \u00E1rea=",length(unique(b2out$codigo_municipio[b2out$area==ar]))))
add_check("Departamentos del universo","CNPV/IPM",length(unique(master$codigo_departamento)),as.integer(length(unique(master$codigo_departamento))!=33),"33 departamentos incluida Bogot\u00E1 D.C.")
anm_count<-sum(str_detect(str_to_lower(coalesce(master$tipo_divipola,"")),"municipalizada")&master$en_ipm,na.rm=TRUE)
add_check("\u00C1reas no municipalizadas dentro de universo IPM","DIVIPOLA/IPM",anm_count,0,"reporte de conteo",paste0("n=",anm_count))
ip_area_dash<-sum(ip$cabeceras |> is.na()); add_check("Cabeceras IPM como --","IPM_municipios_region",nrow(ip),abs(ip_area_dash-20),"20 casos",paste0("tras convertir -- a NA: ",ip_area_dash))
no_head_cnpv<-setdiff(presence$ipm,unique(b2out$codigo_municipio[b2out$area=="Cabecera"])); no_head_ipm<-ip$codigo_municipio[is.na(ip$cabeceras)]; add_check("Conjunto sin Cabecera CNPV coincide con 20 -- IPM","IPM_municipios_region",length(no_head_ipm),length(symdiff(no_head_cnpv,no_head_ipm)),"0 c\u00F3digos distintos",paste0("CNPV=",length(no_head_cnpv),"; IPM=",length(no_head_ipm)))
norm_label<-function(x) str_to_lower(str_squish(stringi::stri_trans_nfc(enc2utf8(as.character(x)))))
anm_codes<-master$codigo_municipio[str_detect(norm_label(master$tipo_divipola),"municipalizada")&master$en_ipm]
no_head_amn<-intersect(no_head_cnpv,anm_codes); no_head_other<-setdiff(no_head_cnpv,anm_codes)
no_head_details<-ipm_names%>%filter(codigo_municipio%in%no_head_other)%>%select(codigo_municipio,nombre_municipio_ipm)
composition_ok<-length(no_head_cnpv)==length(no_head_amn)+length(no_head_other)&&length(no_head_amn)==anm_count&&length(no_head_other)==2L
add_check("Composici\u00F3n de municipios sin Cabecera","CNPV/IPM",length(no_head_cnpv),as.integer(!composition_ok),paste0(anm_count," \u00E1reas no municipalizadas + ",length(no_head_other)," casos adicionales"),paste0("ANM=",length(no_head_amn)," (",paste(no_head_amn,collapse=","),"); otros=",length(no_head_other)," (",paste(no_head_details$codigo_municipio,no_head_details$nombre_municipio_ipm,sep=" ",collapse="; "),")"))
add_disc("BAJA","CNPV/IPM","Cabecera","Hallazgo informativo: composici\u00F3n verificada de los municipios sin Cabecera",paste0(length(no_head_amn)," \u00E1reas no municipalizadas; casos adicionales: ",paste(no_head_details$codigo_municipio,no_head_details$nombre_municipio_ipm,sep=" ",collapse="; ")),"Documentar como ausencia de \u00E1rea; no imputar")
type_map<-b1out %>% transmute(tipo_vivienda) %>% filter(!is.na(tipo_vivienda)) %>% distinct() %>% mutate(.tipo_norm=norm_label(tipo_vivienda))
type_grid<-crossing(codigo_municipio=presence$ipm,.tipo_norm=type_map$.tipo_norm) %>% anti_join(b1out %>% transmute(codigo_municipio,.tipo_norm=norm_label(tipo_vivienda)) %>% distinct(),by=c("codigo_municipio",".tipo_norm")) %>% left_join(type_map,by=".tipo_norm")
for(i in seq_len(nrow(type_map))) {tp<-type_map$tipo_vivienda[i]; nabs<-sum(type_grid$.tipo_norm==type_map$.tipo_norm[i]); add_check(paste("Combinaci\u00F3n tipo vivienda ausente",tp),"VIVIENDAS_6V",length(presence$ipm),nabs,"ausencia estructural informativa",paste0("n ausentes=",nabs,"; ausencia estructural, no es dato faltante; no imputar")); if(nabs>0)add_disc("BAJA","VIVIENDAS_6V","tipo_vivienda","Combinaci\u00F3n de tipo ausente en municipios; no tratar como NA de una fila existente",paste0(tp,": ",nabs," combinaciones"),"Conservar como ausencia estructural; no imputar")}
age_blocks<-ctx1 %>% distinct(codigo_municipio,area); age_map<-ctx1 %>% transmute(grupo_edad) %>% filter(!is.na(grupo_edad)) %>% distinct() %>% mutate(.edad_norm=norm_label(grupo_edad)); age_grid<-crossing(age_blocks,.edad_norm=age_map$.edad_norm) %>% anti_join(ctx1 %>% transmute(codigo_municipio,area,.edad_norm=norm_label(grupo_edad)) %>% distinct(),by=c("codigo_municipio","area",".edad_norm")) %>% left_join(age_map,by=".edad_norm")
for(i in seq_len(nrow(age_map))) {ag<-age_map$grupo_edad[i]; nabs<-sum(age_grid$.edad_norm==age_map$.edad_norm[i]); add_check(paste("Combinaci\u00F3n grupo edad ausente",ag),"CONTEXTO_1PM",nrow(age_blocks),nabs,"ausencia estructural informativa",paste0("n ausentes=",nabs,"; ausencia estructural, no es dato faltante; no imputar")); if(nabs>0)add_disc("BAJA","CONTEXTO_1PM","grupo_edad","Grupo de edad ausente en bloques; no tratar como NA de una fila existente",paste0(ag,": ",nabs," combinaciones"),"Conservar como ausencia estructural; no imputar")}
name_compare<-ipm_names %>% left_join(divkey,by="codigo_municipio") %>% filter(!is.na(nombre_municipio)) %>% transmute(codigo_municipio,nombre_ipm=nombre_municipio_ipm,nombre_div=nombre_municipio)
norm_name<-function(x) str_to_upper(str_squish(x))
name_compare<-name_compare %>% filter(!is.na(nombre_div),norm_name(nombre_ipm)!=norm_name(nombre_div))
add_check("Nombres IPM y DIVIPOLA comparados por c\u00F3digo","IPM/DIVIPOLA",nrow(ipm_names %>% inner_join(divkey,by="codigo_municipio")),0,"informativo",paste0("nombres distintos tras normalizar may\u00FAsculas/acentos/puntuaci\u00F3n=",nrow(name_compare)))
if(nrow(name_compare)) for(i in seq_len(nrow(name_compare))) add_disc("BAJA","IPM/DIVIPOLA",name_compare$codigo_municipio[i],"Nombre difiere entre fuentes; llave por c\u00F3digo preserva la correspondencia",paste0("IPM=",name_compare$nombre_ipm[i],"; DIVIPOLA=",name_compare$nombre_div[i]),"No unir ni corregir por nombre; mantener c\u00F3digo")
row27493<-div %>% filter(codigo_municipio=="27493")
row94663<-ip %>% filter(codigo_municipio=="94663")
row_text<-function(x) if(!nrow(x)) "Sin fila en esta fuente" else paste(paste(names(x),vapply(x[1,,drop=FALSE],function(z)as.character(z[[1]]),character(1)),sep="="),collapse="; ")
add_disc("MEDIA","DIVIPOLA/IPM/CNPV","27493","C\u00F3digo presente solo en DIVIPOLA; fuera de CNPV/IPM",row_text(row27493),"Decidir si conservar fuera del universo maestro; no eliminar ni reasignar")
add_disc("MEDIA","DIVIPOLA/IPM/CNPV","94663","C\u00F3digo presente en IPM/CNPV pero ausente de DIVIPOLA; sin fila ni coordenadas en cat\u00E1logo",row_text(row94663),"Decidir si conservar en universo maestro sin coordenadas; no imputar")

message("[6/9] Encabezados, mapa de llaves y decisiones del diccionario")
maprows<-tribble(
  ~archivo,~hoja,~bloque,~codigo_municipio,~nombre,~departamento,~area,~sexo_tipo_grupo,~variables,
  "CUADROS_MUNICIPALES_UNIDOS.xlsx","HOGARES_MUNICIPAL","1HM y 2HM","B(2)","B(2) texto despu\u00E9s de _","A(1)","C:N (1HM); O:Z (2HM)","No aplica","C:Z: medidas por \u00E1rea; filas 1:3 encabezados",
  "CUADROS_MUNICIPALES_UNIDOS.xlsx","PERSONA_DEMO","17PM","B(2)","B(2) texto despu\u00E9s de _","A(1)","C(3)","D(4)","E:T (total y 15 categor\u00EDas)",
  "CUADROS_MUNICIPALES_UNIDOS.xlsx","PERSONA_SOCIAL","5PM","B(2)","B(2) texto despu\u00E9s de _","A(1)","C(3)","D(4)","E:O (total y actividad)",
  "CUADROS_MUNICIPALES_UNIDOS.xlsx","VIVIENDAS","6V_MPIO","B(2)","B(2) texto despu\u00E9s de _","A(1)","D:AQ por cuatro \u00E1reas","C(3) tipo de vivienda","D:AQ conteos de viviendas y 9 materiales",
  "CUADROS_MUNICIPALES_UNIDOS.xlsx","VIVIENDAS","8V_MPIO","AT(46)","AT(46) texto despu\u00E9s de _","AS(45)","AU(47)","No aplica","AV(48):BP(68) servicios y categor\u00EDas",
  "CUADROS_MUNICIPALES_UNIDOS.xlsx","VIVIENDAS","10V_MPIO","BS(71)","BS(71) texto despu\u00E9s de _","BR(70)","BT(72)","No aplica","BU(73):CD(82) personas y estratos",
  "CUADROS_MUNICIPALES_UNIDOS.xlsx","CONTEXTO","1PM","B(2)","B(2) texto despu\u00E9s de _","A(1)","C(3)","D(4) grupo de edad","E:I (conteos e \u00EDndices)",
  "CUADROS_MUNICIPALES_UNIDOS.xlsx","CONTEXTO","1V_MPIO","L(12)","L(12) texto despu\u00E9s de _","K(11)","M(13)","N(14) tipo de vivienda","O:S (conteos de vivienda)",
  "IPM_2018_organizado_region.xlsx","IPM_municipios_region","Formato ancho","C(3) ID","D(4) Municipio","B(2) Departamento","No aplica","No aplica","E:W IPM y privaciones",
  "IPM_2018_organizado_region.xlsx","Indicadores_municipales","Formato largo","C(3) ID","D(4) Municipio","B(2) Departamento","No aplica","Variable_indice","F Valor",
  "IPM_2018_organizado_region.xlsx","Indicadores_por_dominio","Formato largo","C(3) ID","D(4) Municipio","B(2) Departamento","Dominio_geografico","Variable_indice","G Valor",
  "IPM_2018_organizado_region.xlsx","Diccionario_variables","Diccionario","No aplica","No aplica","No aplica","No aplica","Variable_indice","A:F",
  "IPM_2018_organizado_region.xlsx","Diccionario_dominio","Diccionario","No aplica","No aplica","No aplica","Dominio_geografico","Variable_indice","A:F",
  "IPM_2018_organizado_region.xlsx","Resumen_region","Resumen","No aplica","No aplica","No aplica","Region_geografica","No aplica","A:U",
  "IPM_2018_organizado_region.xlsx","Resumen_departamento","Resumen","No aplica","No aplica","No aplica","Departamento","No aplica","A:G",
  "IPM_2018_organizado_region.xlsx","Control_calidad","Control","No aplica","No aplica","No aplica","No aplica","Control","A:B"
)
maprows<-maprows %>% mutate(formato_codigo_original=case_when(hoja=="VIVIENDAS"&bloque%in%c("6V_MPIO","8V_MPIO")~"3 d\u00EDgitos + c\u00F3digo departamento",hoja=="CONTEXTO"&bloque=="1V_MPIO"~"3 d\u00EDgitos + c\u00F3digo departamento",hoja%in%c("HOGARES_MUNICIPAL","PERSONA_DEMO","PERSONA_SOCIAL","CONTEXTO","IPM_municipios_region","Indicadores_municipales","Indicadores_por_dominio")~"5 d\u00EDgitos",hoja=="VIVIENDAS"&bloque=="10V_MPIO"~"5 d\u00EDgitos",TRUE~"No aplica"))
write_csv(maprows,file.path(out,"mapa_llaves.csv"))
dec<-read_csv(f_dec,col_types=cols(.default=col_character()),locale=locale(encoding="UTF-8"),na=c("","NA"),show_col_types=FALSE)
required<-c("1HM","2HM","17PM","5PM","6V_MPIO","8V_MPIO","10V_MPIO","1PM","1V_MPIO")
for(code in required) {found<-switch(code,"1HM"="HOGARES_MUNICIPAL","2HM"="HOGARES_MUNICIPAL","17PM"="PERSONA_DEMO","5PM"="PERSONA_SOCIAL","6V_MPIO"="VIVIENDAS cols A:AR","8V_MPIO"="VIVIENDAS cols AS:BQ","10V_MPIO"="VIVIENDAS cols BR:CE","1PM"="CONTEXTO cols A:J","1V_MPIO"="CONTEXTO cols K:T"); ok<-if(str_starts(found,"VIVIENDAS")) "VIVIENDAS"%in%names(cn) else if(str_starts(found,"CONTEXTO")) "CONTEXTO"%in%names(cn) else found%in%names(cn); add_check(paste("Decisi\u00F3n presente",code),found,1L,as.integer(!ok),"presente",if(!ok) "No localizada" else "Bloque en el consolidado")}
included_cnpv<-dec %>% filter(decision%in%c("INCLUIDA","CONTEXTO"),hoja%in%required)
for(i in seq_len(nrow(included_cnpv))) {code<-included_cnpv$hoja[i]; add_check(paste("CSV decisi\u00F3n",code),included_cnpv$base[i],1L,as.integer(!code%in%required),included_cnpv$decision[i],included_cnpv$descripcion_indice[i])}
# Reconciliaci\u00F3n del esquema IPM y diccionarios.
dict_read<-function(sh) {q<-ib[[sh]]; hd<-as.character(unlist(q[1,])); d<-as.data.frame(q[-1,,drop=FALSE],check.names=FALSE); names(d)<-clean_header(hd); d}
dict_vars<-dict_read("Diccionario_variables"); dict_dom<-dict_read("Diccionario_dominio")
expected_ipm_names<-names(ip)[5:23]; dictionary_names<-make_clean_names(dict_vars$variable_indice)
missing_dict<-setdiff(expected_ipm_names,dictionary_names); add_check("Diccionario_variables cubre 4 columnas IPM y 15 privaciones","Diccionario_variables",length(expected_ipm_names),length(missing_dict),"0 ausentes",paste0("entradas=",nrow(dict_vars),"; ausentes=",paste(missing_dict,collapse=",")))
add_check("Diccionario_dominio filas","Diccionario_dominio",nrow(dict_dom),as.integer(nrow(dict_dom)!=64),"64 entradas")
dec_ipm<-dec %>% filter(str_detect(base,"IPM_2018"),toupper(iconv(decision,to="ASCII//TRANSLIT"))%in%c("INCLUIDA","VALIDACION")) %>% mutate(variable=str_squish(str_extract(hoja,"(?<=\\| ).*")))
for(i in seq_len(nrow(dec_ipm))) {nm<-make_clean_names(dec_ipm$variable[i]); add_check(paste("Variable IPM decisi\u00F3n",dec_ipm$variable[i]),"IPM_municipios_region",1L,as.integer(!nm%in%expected_ipm_names),dec_ipm$decision[i],if(nm%in%expected_ipm_names) "Presente" else "Nombre no coincide con encabezado IPM")}
walls_name<-make_clean_names("Material inadecuado de paredes exteriores"); add_check("Material inadecuado de paredes: presente pero no incluida","IPM_municipios_region",1L,as.integer(!walls_name%in%expected_ipm_names),"INCLUIDA no; DESCARTAR por duplicidad con 6V","Columna disponible en IPM y en el diccionario")
# Recalcula res\u00FAmenes publicados desde la hoja IPM ancha con tolerancia 1e-6.
regtab<-dict_read("Resumen_region"); deptab<-dict_read("Resumen_departamento")
regcalc<-ip %>% group_by(region_geografica) %>% summarise(municipios=n_distinct(codigo_municipio),ipm_promedio=mean(ipm_municipal,na.rm=TRUE),ipm_mediana=median(ipm_municipal,na.rm=TRUE),ipm_min=min(ipm_municipal,na.rm=TRUE),ipm_max=max(ipm_municipal,na.rm=TRUE),across(all_of(ipmvars),~mean(.x,na.rm=TRUE),.names="{.col}_promedio"),.groups="drop")
regcmp<-regtab %>% inner_join(regcalc,by="region_geografica",suffix=c("_publicado","_recalculado")); regcols<-intersect(names(regtab),names(regcalc)); regbad<-0L; regn<-0L
for(nm in regcols) if(is.numeric(as_num(regcmp[[paste0(nm,"_publicado")]]))||nm=="municipios") {pub<-as_num(regcmp[[paste0(nm,"_publicado")]]);calc<-as_num(regcmp[[paste0(nm,"_recalculado")]]);regn<-regn+sum(!is.na(pub)&!is.na(calc));regbad<-regbad+sum(abs(pub-calc)>1e-6,na.rm=TRUE)}
add_check("Resumen_region recalculado","Resumen_region",regn,regbad,"1e-6")
deptcalc<-ip %>% group_by(departamento) %>% summarise(municipios=n_distinct(codigo_municipio),ipm_promedio=mean(ipm_municipal,na.rm=TRUE),ipm_mediana=median(ipm_municipal,na.rm=TRUE),ipm_min=min(ipm_municipal,na.rm=TRUE),ipm_max=max(ipm_municipal,na.rm=TRUE),.groups="drop")
deptcmp<-deptab %>% inner_join(deptcalc,by="departamento",suffix=c("_publicado","_recalculado")); deptcols<-intersect(names(deptab),names(deptcalc)); deptn<-0L; deptbad<-0L
for(nm in deptcols) {pub<-as_num(deptcmp[[paste0(nm,"_publicado")]]);calc<-as_num(deptcmp[[paste0(nm,"_recalculado")]]);deptn<-deptn+sum(!is.na(pub)&!is.na(calc));deptbad<-deptbad+sum(abs(pub-calc)>1e-6,na.rm=TRUE)}
add_check("Resumen_departamento recalculado","Resumen_departamento",deptn,deptbad,"1e-6")
ctrl<-dict_read("Control_calidad"); ctrl_names<-names(ctrl); cval<-as.character(ctrl[[2]]); control_expected<-c(length(unique(ip$codigo_municipio)),sum(!is.na(ip$departamento)),sum(!is.na(ip$region_geografica)),sum(!is.na(ip$ipm_municipal)),length(ipmvars),nrow(ld)); control_actual<-map_dbl(cval,~as_num(.x)); ctrlbad<-sum(abs(control_actual-control_expected)>0,na.rm=TRUE)+sum(is.na(control_actual)); add_check("Control_calidad recalculado","Control_calidad",length(control_expected),ctrlbad,"exacto",paste(paste(ctrl[[1]],control_actual,control_expected,sep=":"),collapse="; "))

message("[7/9] Inventario numerico, control nacional y discrepancias")
hash_after<-c(CUADROS=hash(f_cnpv),IPM=hash(f_ipm),DIVIPOLA=hash(f_div))
add_check("Integridad archivos fuente MD5 antes/despu\u00E9s","originales",length(hash_before),sum(hash_before!=hash_after),"0 cambios",paste(names(hash_before),hash_before,hash_after,sep=":",collapse="; "))
if(any(hash_before!=hash_after)) add_disc("ALTA","originales","MD5","Cambi\u00F3 un archivo fuente durante la ejecuci\u00F3n",paste(names(hash_before)[hash_before!=hash_after],collapse=","),"Revisar edici\u00F3n concurrente")
# Summary of numerical / structural contract deviations found so far.
write_csv(inv,file.path(out,"inventario_hojas_columnas.csv")); write_csv(check,file.path(out,"chequeos_consistencia.csv")); write_csv(disc,file.path(out,"discrepancias.csv"))

message("[8/9] Reporte de auditor\u00EDa y notas de interpretaci\u00F3n")
div_only<-setdiff(divcode,presence$ipm); ipm_only<-setdiff(presence$ipm,divcode)
universe_diff<-paste0("DIVIPOLA solo: ",paste(div_only,collapse=", "),"; IPM solo: ",paste(ipm_only,collapse=", "))
# All displayed quantities below are computed from the current audit objects.
check_summary <- check %>% group_by(hoja) %>% summarise(chequeos=n(),con_violaciones=sum(n_violaciones>0),violaciones=sum(n_violaciones),.groups="drop")
master_type_summary <- count(master,tipo_divipola,.drop=FALSE)
area_summary <- tibble(area=areas,municipios_con_fila=vapply(areas,function(a)sum(b2out$area==a,na.rm=TRUE),integer(1)))
type_abs_summary <- type_grid %>% count(tipo_vivienda,name="combinaciones_ausentes")
age_abs_summary <- age_grid %>% count(grupo_edad,name="combinaciones_ausentes")
report <- c(
  "# Verificaci\u00F3n de consolidados CNPV e IPM", "",
  "> Enlaces de la b\u00F3veda: [[Inicio_Proyecto]] \u00B7 [[Estructura_Bases]] \u00B7 [[Correccion_Estructura_Bases]]", "",
  paste("Ejecuci\u00F3n:",Sys.Date()), "",
  "## Resumen ejecutivo", "",
  paste0("Conclusi\u00F3n: los libros sirven como base com\u00FAn para continuar con decisiones territoriales pendientes. Los ",length(presence$ipm)," c\u00F3digos de CNPV/IPM coinciden entre los bloques CNPV e IPM; la comparaci\u00F3n con DIVIPOLA presenta ",length(div_only)+length(ipm_only)," discrepancias de c\u00F3digo documentadas abajo. No se derivaron indicadores ni se imputaron valores."), "",
  "## Hojas y bloques", "", markdown_table(inv %>% distinct(archivo,hoja,filas_excel,columnas,filas_encabezado)), "",
  "## Resultados de verificaci\u00F3n", "",
  paste0("Chequeos registrados: ",nrow(check),"; con contador n_violaciones positivo: ",sum(check$n_violaciones>0,na.rm=TRUE),". Los chequeos de combinaciones ausentes reportan conteos estructurales, no errores de datos. Ver detalle en `resultados/verificacion_consolidados/chequeos_consistencia.csv`."), "",
  markdown_table(check_summary), "",
  "## Llaves, universo y cobertura", "",
  paste0("C\u00F3digos en uni\u00F3n de fuentes: ",length(all_codes),"; c\u00F3digos CNPV/IPM: ",length(presence$ipm),"; DIVIPOLA: ",length(divcode),". Diferencias de conjunto: ",universe_diff,"."), "",
  "### Discrepancias territoriales", "",
  markdown_table(tibble(codigo="27493",fuente="Solo DIVIPOLA",detalle=row_text(row27493))), "",
  markdown_table(tibble(codigo="94663",fuente="Solo CNPV/IPM",detalle=row_text(row94663))), "",
  paste0("La uni\u00F3n tiene ",length(all_codes)," c\u00F3digos; no se resolvi\u00F3 cu\u00E1l universo adoptar."), "",
  "### Tipo DIVIPOLA y \u00E1reas no municipalizadas", "", markdown_table(master_type_summary), "",
  paste0("\u00C1reas no municipalizadas dentro de IPM/CNPV: ",anm_count,"; el mismo conteo alimenta chequeos_consistencia.csv."), "",
  "### Cobertura por \u00E1rea", "", markdown_table(area_summary), "",
  paste0("Cabecera: TRUE ",sum(master$tiene_cabecera %in% TRUE),", FALSE ",sum(master$tiene_cabecera==FALSE,na.rm=TRUE),", NA ",sum(is.na(master$tiene_cabecera)),". Centro poblado: TRUE ",sum(master$tiene_centro_poblado %in% TRUE),", FALSE ",sum(master$tiene_centro_poblado==FALSE,na.rm=TRUE),", NA ",sum(is.na(master$tiene_centro_poblado)),"."), "",
  paste0("Sin Cabecera en CNPV/IPM: ",length(no_head_cnpv),"; `--` en Cabeceras IPM: ",length(no_head_ipm),"; diferencia sim\u00E9trica: ",length(symdiff(no_head_cnpv,no_head_ipm)),"."), "",
  markdown_table(no_head_details), "",
  paste0("Composici\u00F3n verificada: ",length(no_head_amn)," c\u00F3digos tipo \u00E1rea no municipalizada y ",length(no_head_other)," casos adicionales mostrados arriba. Hip\u00F3tesis no comprobada: los casos adicionales podr\u00EDan corresponder a territorios que eran ANM en 2018."), "",
  "### Nombres distintos IPM-DIVIPOLA", "", markdown_table(name_compare), "",
  "### Combinaciones estructuralmente ausentes", "",
  paste0("Tipos observados en 6V: ",nrow(type_map),"; universo de combinaciones: ",length(presence$ipm)*nrow(type_map),"; filas presentes: ",nrow(b1out),"; ausencias: ",nrow(type_grid),"."), "", markdown_table(type_abs_summary), "",
  paste0("Grupos de edad observados: ",nrow(age_map),"; bloques municipio-\u00E1rea: ",nrow(age_blocks),"; universo de combinaciones: ",nrow(age_blocks)*nrow(age_map),"; filas presentes: ",nrow(ctx1),"; ausencias: ",nrow(age_grid),"."), "", markdown_table(age_abs_summary), "",
  "Son combinaciones no observadas estructuralmente, no datos faltantes de una fila; no se imputaron.", "",
  "## Duda de 17PM", "",
  "El encabezado de la columna E est\u00E1 bajo Nivel educativo y F:T son categor\u00EDas de nivel educativo. La suma E = suma(F:T) se verifica en el CSV de chequeos. La evidencia indica nivel educativo alcanzado, aunque el CSV de decisiones lo describa como asistencia escolar.", "",
  "## Reconciliaci\u00F3n IPM", "",
  markdown_table(check %>% filter(str_detect(chequeo,"Resumen_region recalculado|Resumen_departamento recalculado|Control_calidad recalculado|IPM Municipal = IPM|rango")) %>% select(chequeo,hoja,n_evaluado,n_violaciones,tolerancia,evidencia)), "",
  "Las hojas ancha y largas, diccionarios, res\u00FAmenes y controles se compararon seg\u00FAn los chequeos. Material inadecuado de paredes exteriores est\u00E1 presente aunque no est\u00E9 incluida en el grupo indicado por las decisiones.", "",
  "## Discrepancias", "", markdown_table(disc %>% arrange(factor(severidad,levels=c("ALTA","MEDIA","BAJA")))), "",
  "## Decisiones pendientes del usuario", "",
  "- Elegir universo maestro y tratamiento de 27493/94663.",
  "- Definir tratamiento anal\u00EDtico de las \u00E1reas no municipalizadas.",
  "- Mantener las filas ausentes como combinaciones no observadas, sin imputaci\u00F3n.",
  "- Decidir qu\u00E9 columnas de 8V se conservan para la fase siguiente.", "",
  "## Integridad de archivos fuente", "",
  paste0("MD5 antes/despu\u00E9s: ",paste(names(hash_before),hash_before,hash_after,sep=" = ",collapse="; ")), "",
  "## Siguiente paso", "",
  "Resolver las decisiones territoriales y de variables antes de preparar indicadores derivados o realizar an\u00E1lisis multivariado.", ""
)
writeLines(enc2utf8(report),file.path(root,"docs/calidad/auditorias/VERIFICACION_CONSOLIDADOS.md"),useBytes=TRUE)
report_file<-file.path(root,"docs/calidad/auditorias/VERIFICACION_CONSOLIDADOS.md")
audit_csvs<-list.files(out,pattern="\\.csv$",full.names=TRUE)
scan_files<-c(audit_csvs,report_file)
bad_tokens<-c("\u00C3","\u00E2\u20AC","\uFFFD")
encoding_hits<-map2_lgl(scan_files,seq_along(scan_files),function(path,i){txt<-read_file(path,locale=locale(encoding="UTF-8"));any(map_lgl(bad_tokens,~str_detect(txt,fixed(.x))))})
if(any(encoding_hits)) stop("Se detectaron marcadores de codificaci\u00F3n da\u00F1ada en: ",paste(scan_files[encoding_hits],collapse=", "))
message("[9/9] Terminado")
cat("Hojas inventariadas:",nrow(inv%>%distinct(archivo,hoja)),"\nDiscrepancias por severidad:\n"); print(count(disc,severidad,.drop=FALSE)); cat("Chequeos con violaciones:",sum(check$n_violaciones>0,na.rm=TRUE),"de",nrow(check),"\n")

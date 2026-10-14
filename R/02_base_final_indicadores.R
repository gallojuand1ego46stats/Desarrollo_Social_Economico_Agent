# Base final, denominadores, indicadores y matriz descriptiva IVS.
# Ejecutar desde la raiz. No modifica datos/intermedio/; no imputa ni ejecuta PCA/bootstrap.
suppressPackageStartupMessages({library(readr);library(dplyr);library(tidyr);library(stringr);library(purrr);library(tibble);library(janitor)})
options(readr.show_col_types=FALSE,encoding="UTF-8",stringsAsFactors=FALSE)
for(loc in c("English_United States.utf8","Spanish_Colombia.utf8",".UTF-8")) if(!is.na(suppressWarnings(Sys.setlocale("LC_CTYPE",loc)))) break
set.seed(20261013)
root<-normalizePath(getwd(),winslash="/",mustWork=TRUE)
source(file.path(root,"R/00_config.R"),encoding="UTF-8")
source(file.path(root,"R/funciones/io.R"),encoding="UTF-8")
source(file.path(root,"R/funciones/validacion.R"),encoding="UTF-8")
inter<-file.path(root,ivs_config$rutas$intermedios); work<-file.path(root,ivs_config$rutas$trabajo); out<-file.path(root,ivs_config$rutas$resultados_base)
dir.create(work,recursive=TRUE,showWarnings=FALSE);dir.create(out,recursive=TRUE,showWarnings=FALSE)
files<-ivs_config$archivos_intermedios
paths<-file.path(inter,files); master_path<-file.path(root,ivs_config$rutas$verificacion,ivs_config$archivo_universo)
stopifnot(all(file.exists(paths)),file.exists(master_path))
hash<-function(p)hash_archivos(p,root)
hash_before<-hash(c(paths,master_path))
read_txt<-leer_csv_texto
d<-set_names(map(paths,read_txt),tools::file_path_sans_ext(files)); master_all<-read_txt(master_path)
master<-master_all%>%filter(en_ipm=="TRUE",contexto_1PM=="TRUE")
if(nrow(master)!=ivs_config$n_municipios||anyDuplicated(master$codigo_municipio))stop("Universo 2018 distinto de los codigos unicos configurados.")
codes<-master$codigo_municipio
if(any(!str_detect(codes,"^\\d{5}$"))||any(master$codigo_departamento!=str_sub(codes,1,2)))stop("Codigo municipal/departamental invalido.")
parse_n<-parse_numero
ncols<-convertir_columnas_numericas
rate<-function(n,d)ifelse(!is.na(d)&d>0,n/d,NA_real_)
wo<-function(x,n)escribir_csv(x,out,n)
ww<-function(x,n)escribir_csv(x,work,n)
exp<-tibble(metrica=character(),esperado=character(),obtenido=character(),estado=character(),nota=character())
val<-tibble(validacion=character(),n_evaluado=integer(),n_violaciones=integer(),estado=character(),tolerancia=character(),evidencia=character())
ae<-function(m,e,o,note=""){exp<<-bind_rows(exp,registro_hallazgo(m,e,o,note))}
av<-function(m,n,b,tol="0",e=""){val<<-bind_rows(val,registro_validacion(m,n,b,tol,e))}
message("[1/8] Inventario, hashes y llaves")
wo(hash_before,"md5_insumos_antes.csv")
wo(imap_dfr(d,~tibble(tabla=.y,orden=seq_along(.x),columna=names(.x))),"nombres_columnas_fuente.csv")
for(nm in setdiff(names(d),"control_nacional")){
 x<-d[[nm]]
 if(all(c("codigo_municipio","codigo_departamento")%in%names(x))){
  bad<-sum(!verificar_llave_municipal(x),na.rm=TRUE)
  av(paste("Llave/prefijo",nm),nrow(x),bad)
 }
}
ae("Universo CNPV/IPM",ivs_config$n_municipios,n_distinct(master$codigo_municipio))

message("[2/8] 1PM: ceros estructurales y areas inexistentes")
ages<-c("0 a 4","5 a 9","10 a 14","15 a 19","20 a 24","25 a 29","30 a 34","35 a 39","40 a 44","45 a 49","50 a 54","55 a 59","60 a 64","65 a 69","70 a 74","75 a 79","80 a 84","85 y mas")
age<-d$contexto_1PM%>%mutate(across(c(total,hombre,mujer,indice_masculinidad,indice_feminidad),~parse_n(.x,"contexto_1PM")),grupo_edad=str_replace(grupo_edad,"85 y más","85 y mas"),fila_fuente=TRUE)
blocks<-age%>%filter(grupo_edad=="Total")%>%distinct(codigo_municipio,area)
missing_age<-expand_grid(blocks,grupo_edad=ages)%>%anti_join(age%>%filter(grupo_edad!="Total")%>%distinct(codigo_municipio,area,grupo_edad),by=c("codigo_municipio","area","grupo_edad"))%>%
 left_join(master%>%select(codigo_municipio,nombre_municipio,nombre_departamento),by="codigo_municipio")%>%mutate(codigo_departamento=str_sub(codigo_municipio,1,2))%>%
 select(codigo_departamento,codigo_municipio,nombre_municipio,nombre_departamento,area,grupo_edad)
wo(missing_age,"ausencias_estructurales_1PM.csv")
age0<-missing_age%>%mutate(total=0,hombre=0,mujer=0,indice_masculinidad=NA_real_,indice_feminidad=NA_real_,fila_fuente=FALSE)
age_full<-bind_rows(age,age0)%>%mutate(flag_cero_estructural=!fila_fuente,flag_indice_indefinido=is.na(indice_masculinidad)|is.na(indice_feminidad))%>%select(-fila_fuente)
ww(age_full,"demografico_1PM_completo_largo.csv")
ae("Combinaciones edad ausentes",335,nrow(missing_age));ae("Municipios afectados",119,n_distinct(missing_age$codigo_municipio))
for(a in c("Centro poblado","Rural disperso","Cabecera","Total"))ae(paste("Area",a),c("Centro poblado"=299,"Rural disperso"=25,"Cabecera"=6,"Total"=5)[[a]],sum(missing_age$area==a))
for(a in c("85 y mas","80 a 84","75 a 79"))ae(paste("Edad",a),c("85 y mas"=89,"80 a 84"=62,"75 a 79"=33)[[a]],sum(missing_age$grupo_edad==a))
gs<-age_full%>%filter(grupo_edad!="Total")%>%group_by(codigo_municipio,area)%>%summarise(g=sum(total),h=sum(hombre),m=sum(mujer),.groups="drop")%>%left_join(age_full%>%filter(grupo_edad=="Total")%>%select(codigo_municipio,area,total),by=c("codigo_municipio","area"))
av("Suma grupos edad = total",nrow(gs),sum(gs$g!=gs$total,na.rm=TRUE),"exacta")
av("Hombre + mujer = total 1PM",nrow(age_full),sum(age_full$hombre+age_full$mujer!=age_full$total,na.rm=TRUE),"exacta")
area_exist<-age_full%>%filter(grupo_edad=="Total",area!="Total")%>%mutate(area_key=recode(area,"Centro poblado"="Centro_poblado","Rural disperso"="Rural_disperso"),existe=TRUE)%>%select(codigo_municipio,area_key,existe)%>%pivot_wider(names_from=area_key,values_from=existe,names_prefix="existe_",values_fill=FALSE)
areas<-master%>%select(codigo_departamento,codigo_municipio,nombre_municipio,nombre_departamento)%>%left_join(area_exist,by="codigo_municipio")%>%mutate(across(starts_with("existe_"),~coalesce(.x,FALSE)))
wo(areas%>%filter(!existe_Cabecera|!existe_Centro_poblado|!existe_Rural_disperso)%>%select(codigo_departamento,codigo_municipio,nombre_municipio,nombre_departamento,starts_with("existe_")),"areas_inexistentes.csv")
ae("Municipios sin Cabecera",20,sum(!areas$existe_Cabecera));ae("Municipios sin Centro poblado",192,sum(!areas$existe_Centro_poblado))

message("[3/8] Denominadores municipales y quinquenales")
age_codes<-c("0 a 4"="pob_0_4","5 a 9"="pob_5_9","10 a 14"="pob_10_14","15 a 19"="pob_15_19","20 a 24"="pob_20_24","25 a 29"="pob_25_29","30 a 34"="pob_30_34","35 a 39"="pob_35_39","40 a 44"="pob_40_44","45 a 49"="pob_45_49","50 a 54"="pob_50_54","55 a 59"="pob_55_59","60 a 64"="pob_60_64","65 a 69"="pob_65_69","70 a 74"="pob_70_74","75 a 79"="pob_75_79","80 a 84"="pob_80_84","85 y mas"="pob_85_mas")
age_w<-age_full%>%filter(area=="Total",grupo_edad!="Total")%>%mutate(grupo_edad=str_replace(grupo_edad,"85 y más","85 y mas"),col=unname(age_codes[grupo_edad]))%>%select(codigo_municipio,col,total)%>%pivot_wider(names_from=col,values_from=total)
age_w<-age_w%>%mutate(pob_0_14=rowSums(across(all_of(c("pob_0_4","pob_5_9","pob_10_14")))),pob_15_59=rowSums(across(all_of(paste0("pob_",c("15_19","20_24","25_29","30_34","35_39","40_44","45_49","50_54","55_59"))))),pob_60_mas=rowSums(across(all_of(paste0("pob_",c("60_64","65_69","70_74","75_79","80_84","85_mas"))))))
pop<-age_full%>%filter(grupo_edad=="Total")%>%select(codigo_municipio,area,total,hombre,mujer)%>%mutate(area_key=recode(area,"Total"="Total","Centro poblado"="Centro_poblado","Rural disperso"="Rural_disperso"))%>%select(-area)%>%pivot_wider(names_from=area_key,values_from=c(total,hombre,mujer),names_glue="{.value}_{area_key}")
ctx1v<-d$contexto_1V%>%filter(area=="Total",tipo_vivienda=="Total")%>%ncols(c("viviendas_total","ocupada_presentes"),"1V")
v8<-d$viviendas_8V%>%filter(area=="Total")%>%ncols(names(d$viviendas_8V)[6:ncol(d$viviendas_8V)],"8V")
v10<-d$viviendas_10V%>%filter(area=="Total")%>%ncols(names(d$viviendas_10V)[6:ncol(d$viviendas_10V)],"10V")
hh<-d$hogares_1HM_2HM%>%filter(area=="Total")%>%ncols(names(d$hogares_1HM_2HM)[6:ncol(d$hogares_1HM_2HM)],"HOGARES")
p17<-d$persona_demo_17PM%>%filter(area=="Total",sexo=="Total")%>%ncols(names(d$persona_demo_17PM)[7:ncol(d$persona_demo_17PM)],"17PM")
p5<-d$persona_social_5PM%>%filter(area=="Total",sexo=="Total")%>%ncols(names(d$persona_social_5PM)[7:ncol(d$persona_social_5PM)],"5PM")
den<-master%>%select(codigo_municipio,codigo_departamento,nombre_municipio,nombre_departamento,tipo_divipola,en_divipola,en_ipm)%>%left_join(age_w,by="codigo_municipio")%>%
 left_join(pop%>%select(codigo_municipio,pob_total=total_Total,pob_cabecera=total_Cabecera,pob_centro_poblado=total_Centro_poblado,pob_rural_disperso=total_Rural_disperso,pob_hombres=hombre_Total,pob_mujeres=mujer_Total),by="codigo_municipio")%>%
 left_join(ctx1v%>%select(codigo_municipio,viviendas_1V=viviendas_total,viviendas_ocupadas_presentes_1V=ocupada_presentes),by="codigo_municipio")%>%
 left_join(v8%>%select(codigo_municipio,viviendas_8V=viviendas_presentes),by="codigo_municipio")%>%
 left_join(hh%>%select(codigo_municipio,hogares_total,hogares_menores15,personas_menores15,hogares_total_2HM,hogares_adultos_mayores,personas_60mas),by="codigo_municipio")%>%
 left_join(v10%>%select(codigo_municipio,personas_hogares_particulares),by="codigo_municipio")%>%
 left_join(p17%>%select(codigo_municipio,pob_17PM_educacion=total),by="codigo_municipio")%>%left_join(p5%>%select(codigo_municipio,pob_base_actividad=total),by="codigo_municipio")%>%
 mutate(pct_rural_disperso=rate(pob_rural_disperso,pob_total),es_anm_2018=if_else(!areas$existe_Cabecera[match(codigo_municipio,areas$codigo_municipio)],TRUE,pob_cabecera==0),flag_pob_lt1000=pob_total<1000,flag_pob_lt5000=pob_total<5000,contiene_probable_bajira_2018=codigo_municipio=="27615")
den<-den%>%mutate(pob_10mas=pob_total-pob_0_4-pob_5_9,cobertura_5pm_actividad=rate(pob_base_actividad,pob_10mas),flag_pers10_cobertura_baja=is.na(cobertura_5pm_actividad)|cobertura_5pm_actividad<ivs_config$cobertura_baja[["actividad_personas_10mas"]],cob_hogares_menores15=rate(personas_menores15,pob_0_14),flag_hogares_cobertura_baja_menores15=is.na(cob_hogares_menores15)|cob_hogares_menores15<ivs_config$cobertura_baja[["hogares_menores15"]],cob_hogares_60mas=rate(personas_60mas,pob_60_mas),flag_hogares_cobertura_baja_60mas=is.na(cob_hogares_60mas)|cob_hogares_60mas<ivs_config$cobertura_baja[["hogares_adultos_60mas"]],flag_denominador_cero=pob_total==0|pob_10mas==0|pob_base_actividad==0|viviendas_8V==0|viviendas_1V==0)
ww(den%>%select(codigo_departamento,codigo_municipio,nombre_municipio,nombre_departamento,everything()),"denominadores_municipales.csv")
ww(age_w%>%left_join(master%>%select(codigo_municipio,codigo_departamento,nombre_municipio,nombre_departamento),by="codigo_municipio")%>%select(codigo_departamento,codigo_municipio,nombre_municipio,nombre_departamento,everything()),"denominadores_edad_quinquenal.csv")
ae("Poblacion <1000",10,sum(den$flag_pob_lt1000));ae("Poblacion <5000",225,sum(den$flag_pob_lt5000));ae("CNPV sin cabecera",20,sum(den$es_anm_2018,na.rm=TRUE))
ae("CNPV sin cabecera y etiqueta ANM DIVIPOLA",18,sum(den$es_anm_2018&den$tipo_divipola=="Área no municipalizada",na.rm=TRUE))
ae("Cobertura baja población 10+ 5PM",28,sum(den$flag_pers10_cobertura_baja),paste("pob_base_actividad / pob_10mas <",ivs_config$cobertura_baja[["actividad_personas_10mas"]]))
ae("Cobertura baja menores15 HOGARES",26,sum(den$flag_hogares_cobertura_baja_menores15),paste("personas_menores15 / pob_0_14 <",ivs_config$cobertura_baja[["hogares_menores15"]]))
ae("Cobertura baja personas 60+ HOGARES",20,sum(den$flag_hogares_cobertura_baja_60mas),paste("personas_60mas / pob_60_mas <",ivs_config$cobertura_baja[["hogares_adultos_60mas"]]))
ae("Poblacion de los 18 ANM DIVIPOLA sin cabecera",26569,sum(den$pob_total[den$es_anm_2018&den$tipo_divipola=="Área no municipalizada"],na.rm=TRUE),"Los otros dos sin cabecera se detallan aparte")
ae("Poblacion en 20 municipios sin cabecera",34787,sum(den$pob_total[den$es_anm_2018],na.rm=TRUE),"Incluye 18 ANM y los códigos 94343/94663")
ae("Poblacion de 94343 y 94663 sin cabecera",8218,sum(den$pob_total[den$codigo_municipio%in%c("94343","94663")],na.rm=TRUE),"94343=7207; 94663=1011")
ae("Diferencias total 17PM vs poblacion 5+ 1PM",0,sum(den$pob_17PM_educacion!=(den$pob_total-den$pob_0_4),na.rm=TRUE),"Evidencia de universo etario 5+; 17PM no permite denominar solo a 10+")
ctrl_pop<-d$control_nacional%>%filter(hoja=="CONTEXTO",bloque=="1PM",area=="Total",dimension=="Total",columna=="E")
ctrl_pop_value<-if(nrow(ctrl_pop)==1)parse_n(ctrl_pop$valor_original,"control_nacional 1PM Total E")else NA_real_
pop_sum_2018<-sum(den$pob_total,na.rm=TRUE)
av("Suma población total municipios = control_nacional 1PM E",1,if(is.na(ctrl_pop_value))1L else as.integer(pop_sum_2018!=ctrl_pop_value),"exacta",paste("suma municipal",pop_sum_2018,"control",ctrl_pop_value))

message("[4/8] Especificacion y calculo de indicadores")
ind_spec<-tribble(
 ~id_indicador,~familia,~definicion,~numerador,~tabla_fuente,~denominador,~direccion,~sensible_nr,~incluir_pca_propuesto,~motivo,
 "educacion_ninguno_pre","Educacion","Personas de 5+ sin nivel o preescolar","ninguno + preescolar","17PM","total personas 5+ en 17PM","1 = mas vulnerable",TRUE,FALSE,"El total observado coincide con 1PM de 5+; el archivo no permite restringir categorias a 10+. Excluir por cercania con bajo logro IPM.",
 "educacion_primaria_o_menos","Educacion","Personas de 5+ hasta primaria completa/incompleta","ninguno + preescolar + primaria completa/incompleta","17PM","total personas 5+ en 17PM","1 = mas vulnerable",TRUE,FALSE,"Proxy de bajo logro educativo del IPM; excluir del PCA para evitar circularidad.",
 "educacion_sin_media_completa","Educacion","Personas de 5+ hasta media incompleta","categorias hasta media incompleta","17PM","total personas 5+ en 17PM","1 = mas vulnerable",TRUE,FALSE,"Proxy cercano a bajo logro educativo del IPM; calcular para descripcion.",
 "actividad_desocupacion_incapacidad_hogar","Actividad","Busqueda de trabajo, oficios, incapacidad permanente u otra situacion","busco_trabajo + oficios_hogar + incapacidad + otra situacion","5PM","personas 10+ actividad","1 = mas vulnerable",TRUE,TRUE,"Propuesta de dimension laboral/social; no incluye estudio ni pension.",
 "paredes_inadecuadas","Vivienda","Materiales de pared de mayor precariedad","guadua + tapia + madera burda + cana + desecho + sin paredes","6V","viviendas tipo Total","1 = mas vulnerable",FALSE,FALSE,"Componente directo de material de paredes del IPM; excluir de PCA.",
 "sin_acueducto","Servicios","Viviendas sin acueducto","acueducto_no","8V","viviendas ocupadas presentes","1 = mas vulnerable",FALSE,FALSE,"Se solapa con acceso a fuente de agua del IPM.",
 "sin_alcantarillado","Servicios","Viviendas sin alcantarillado","alcantarillado_no","8V","viviendas ocupadas presentes","1 = mas vulnerable",FALSE,FALSE,"Se solapa con eliminacion de excretas del IPM.",
 "sin_energia_electrica","Servicios","Viviendas sin energia electrica","energia_no","8V","viviendas ocupadas presentes","1 = mas vulnerable",FALSE,TRUE,"No es una de las 15 privaciones listadas del IPM.",
 "sin_gas_red_publica","Servicios","Viviendas sin gas por red","gas_no","8V","total de respuesta del item","1 = mas vulnerable",TRUE,TRUE,"La base valida excluye sin informacion; revisar sensibilidad.",
 "sin_recoleccion_basuras","Servicios","Viviendas sin recoleccion de basuras","basuras_no","8V","viviendas ocupadas presentes","1 = mas vulnerable",FALSE,TRUE,"Candidata adicional no identica a privacion IPM.",
 "sin_internet","Servicios","Viviendas sin internet","internet_no","8V","total de respuesta del item","1 = mas vulnerable",TRUE,TRUE,"La base valida excluye sin informacion; revisar sensibilidad.",
 "hogares_con_menores15","Hogar/demografia","Hogares con menores de 15","hogares_menores15","HOGARES 1HM","hogares_total","1 = mas vulnerable",FALSE,TRUE,"Decision autor 1HM; presion demografica, no componente directo IPM.",
 "hogares_con_adultos_mayores","Hogar/demografia","Hogares con adultos mayores","hogares_adultos_mayores","HOGARES 2HM","hogares_total_2HM","direccion por decidir",FALSE,FALSE,"La direccion de vulnerabilidad no esta definida; conservar descriptivo.",
 "estrato_1_2","Hogar/demografia","Personas en estratos 1 o 2","estrato_1 + estrato_2","10V","personas hogares particulares","1 = mas vulnerable",TRUE,TRUE,"Candidata SES. No_tiene_estrato es categoria distinta a no sabe/no responde.",
 "sin_servicio_energia_10v","Hogar/demografia","Personas sin energia","sin_servicio_energia","10V","personas hogares particulares","1 = mas vulnerable",FALSE,FALSE,"Duplicado conceptual con energia 8V; se excluye.",
 "dependencia_demografica","Hogar/demografia","(poblacion 0-14 + 60+) / poblacion 15-59","grupos de edad 0-14 y 60+","1PM","poblacion 15-59","1 = mas vulnerable",FALSE,FALSE,"Tasa de dependencia es componente IPM; dejar para descripcion.",
 "pct_rural_disperso","Covariable","Poblacion rural dispersa sobre poblacion total","pob_rural_disperso","1PM","poblacion total","descriptiva",FALSE,FALSE,"Covariable descriptiva; no PCA salvo decision del autor."
)%>%mutate(orientacion_original=direccion,direccion=case_when(id_indicador=="hogares_con_adultos_mayores"~-1L,TRUE~1L),pendiente_direccion=id_indicador=="hogares_con_adultos_mayores")
wo(ind_spec,"especificacion_indicadores.csv")
p17<-p17%>%filter(codigo_municipio%in%codes)
p5<-p5%>%filter(codigo_municipio%in%codes)
v8<-v8%>%filter(codigo_municipio%in%codes)
v10<-v10%>%filter(codigo_municipio%in%codes)
hh<-hh%>%filter(codigo_municipio%in%codes)
v6<-d$viviendas_6V%>%ncols(names(d$viviendas_6V)[6:ncol(d$viviendas_6V)],"6V")%>%filter(codigo_municipio%in%codes,tipo_vivienda=="Total")
ind<-master%>%select(codigo_departamento,codigo_municipio,nombre_municipio,nombre_departamento)
join_cols<-function(x,cols,suffix) ind<<-ind%>%left_join(x%>%select(codigo_municipio,all_of(cols)),by="codigo_municipio",suffix=c("",suffix))
join_cols(p17,c("total","ninguno","preescolar","primaria_completa","primaria_incompleta","secundaria_completa","secundaria_incompleta","media_completa","media_incompleta","sin_informacion"),"_17")
join_cols(p5,c("total","no_informa","busco_trabajo","realizo_oficios_del_hogar","esta_incapacitado_a_permanentemente_para_trabajar","estuvo_en_otra_situacion"),"_5")
join_cols(v8,c("viviendas_presentes","energia_no","acueducto_no","alcantarillado_no","gas_total","gas_no","gas_sin_informacion","basuras_no","internet_total","internet_no","internet_sin_informacion"),"_8")
join_cols(v10,c("personas_hogares_particulares","sin_servicio_energia","no_tiene_estrato","estrato_1","estrato_2","no_sabe_no_responde"),"_10")
wall_cols<-c("total_total","total_guadua","total_tapia_bahareque_adobe","total_madera_burda","total_cana_vegetales","total_desecho","total_sin_paredes")
join_cols(v6,wall_cols,"_6")
join_cols(hh,c("hogares_total","hogares_menores15","hogares_total_2HM","hogares_adultos_mayores"),"_hh")
join_cols(den,c("pob_total","pob_0_14","pob_15_59","pob_60_mas","pob_rural_disperso","pct_rural_disperso"),"_den")
ind<-ind%>%mutate(
 edu_nr=sin_informacion, activity_nr=no_informa,gas_nr=gas_sin_informacion,internet_nr=internet_sin_informacion,estrato_nr=no_sabe_no_responde,
 educacion_ninguno_pre=rate(ninguno+preescolar,total),
 educacion_primaria_o_menos=rate(ninguno+preescolar+primaria_completa+primaria_incompleta,total),
 educacion_sin_media_completa=rate(ninguno+preescolar+primaria_completa+primaria_incompleta+secundaria_completa+secundaria_incompleta+media_incompleta,total),
 actividad_desocupacion_incapacidad_hogar=rate(busco_trabajo+realizo_oficios_del_hogar+esta_incapacitado_a_permanentemente_para_trabajar+estuvo_en_otra_situacion,total_5),
 paredes_inadecuadas=rate(total_guadua+total_tapia_bahareque_adobe+total_madera_burda+total_cana_vegetales+total_desecho+total_sin_paredes,total_total),
 sin_acueducto=rate(acueducto_no,viviendas_presentes),sin_alcantarillado=rate(alcantarillado_no,viviendas_presentes),
 sin_energia_electrica=rate(energia_no,viviendas_presentes),sin_gas_red_publica=rate(gas_no,gas_total),
 sin_recoleccion_basuras=rate(basuras_no,viviendas_presentes),sin_internet=rate(internet_no,internet_total),
 hogares_con_menores15=rate(hogares_menores15,hogares_total),hogares_con_adultos_mayores=rate(hogares_adultos_mayores,hogares_total_2HM),
 estrato_1_2=rate(estrato_1+estrato_2,personas_hogares_particulares),
 sin_servicio_energia_10v=rate(sin_servicio_energia,personas_hogares_particulares),
 dependencia_demografica=rate(pob_0_14+pob_60_mas,pob_15_59),pct_rural_disperso_ind=pct_rural_disperso,
 educacion_ninguno_pre_valida=rate(ninguno+preescolar,total-edu_nr),
 educacion_primaria_o_menos_valida=rate(ninguno+preescolar+primaria_completa+primaria_incompleta,total-edu_nr),
 educacion_sin_media_completa_valida=rate(ninguno+preescolar+primaria_completa+primaria_incompleta+secundaria_completa+secundaria_incompleta+media_incompleta,total-edu_nr),
 actividad_desocupacion_incapacidad_hogar_valida=rate(busco_trabajo+realizo_oficios_del_hogar+esta_incapacitado_a_permanentemente_para_trabajar+estuvo_en_otra_situacion,total_5-activity_nr),
 sin_gas_red_publica_valida=rate(gas_no,gas_total-gas_nr),sin_internet_valida=rate(internet_no,internet_total-internet_nr),
 estrato_1_2_valida=rate(estrato_1+estrato_2,personas_hogares_particulares-estrato_nr)
)
ind_ids<-ind_spec$id_indicador
for(nm in ind_ids) if(!paste0(nm,"_valida")%in%names(ind)) ind[[paste0(nm,"_valida")]]<-ind[[nm]]
base_total<-ind%>%select(codigo_departamento,codigo_municipio,nombre_municipio,nombre_departamento,all_of(ind_ids))
base_valid<-ind%>%select(codigo_departamento,codigo_municipio,nombre_municipio,nombre_departamento,all_of(paste0(ind_ids,"_valida")))
names(base_valid)[5:ncol(base_valid)]<-ind_ids
ww(base_total,"indicadores_municipales_base_total.csv");ww(base_valid,"indicadores_municipales_base_valida.csv")

message("[5/8] Construccion de matrices y estandarizacion descriptiva")
main_ids<-ind_spec%>%filter(incluir_pca_propuesto)%>%pull(id_indicador)
matrix_base<-ind%>%select(codigo_municipio,all_of(main_ids))%>%arrange(codigo_municipio)
matrix_valid<-base_valid%>%select(codigo_municipio,all_of(main_ids))%>%arrange(codigo_municipio)
for(nm in main_ids) if(ind_spec$direccion[match(nm,ind_spec$id_indicador)]==-1L){matrix_base[[nm]]<-1-matrix_base[[nm]];matrix_valid[[nm]]<-1-matrix_valid[[nm]]}
matrix_na<-sum(is.na(matrix_base[main_ids]))
na_list<-map_dfr(main_ids,function(nm){i<-which(is.na(matrix_base[[nm]]));if(length(i))tibble(codigo_municipio=matrix_base$codigo_municipio[i],indicador=nm,motivo="NA en indicador/denominador; no imputado")else tibble()})
ww(matrix_base,"matriz_pca.csv");ww(matrix_valid,"matriz_pca_base_valida.csv")
if(matrix_na>0)wo(na_list,"na_matriz_pca_detencion.csv")
av("Matriz propuesta base total sin NA",nrow(matrix_base)*length(main_ids),matrix_na,"0","Si >0 no se genera z-score ni diagnosticos")
for(nm in main_ids) {
 out_range<-sum(ind[[nm]]<0|ind[[nm]]>1,na.rm=TRUE)
 av(paste("Proporcion 0-1",nm),nrow(ind),out_range,"[0,1]")
}
wo(den%>%select(codigo_municipio,codigo_departamento,nombre_municipio,nombre_departamento,pct_rural_disperso,pob_total,tipo_divipola,es_anm_2018,starts_with("flag_")),"covariables_descriptivas.csv")
if(matrix_na==0&&length(main_ids)>1){
 x<-as.data.frame(matrix_base[main_ids])
 means<-vapply(x,mean,numeric(1));sds<-vapply(x,sd,numeric(1));scale_sd<-ifelse(sds==0|!is.finite(sds),1,sds)
 z<-as_tibble(scale(x,center=means,scale=scale_sd))%>%bind_cols(matrix_base%>%select(codigo_municipio),.)
 ww(z,"matriz_pca_z.csv")
 wo(tibble(indicador=main_ids,media=means,desviacion_estandar=sds,desviacion_aplicada=scale_sd),"parametros_estandarizacion.csv")
}else{
 av("Estandarizacion descriptiva",0,1,"No aplica","Matriz con NA; no se genera matriz z")
}

message("[6/8] Crosswalk, configuracion y documentacion")
av("Viviendas presentes 1V = 8V",nrow(den),sum(den$viviendas_ocupadas_presentes_1V!=den$viviendas_8V,na.rm=TRUE),"exacta","Reportar diferencia sin ajustar")
v6_total<-v6%>%select(codigo_municipio,v6_total=total_total)
comp_v<-den%>%left_join(v6_total,by="codigo_municipio")
av("Viviendas 1V ocupadas presentes vs total tipo Total 6V",nrow(comp_v),sum(comp_v$viviendas_ocupadas_presentes_1V!=comp_v$v6_total,na.rm=TRUE),"exacta","Conceptos pueden diferir; solo reportar")
div_path<-list.files(file.path(root,ivs_config$rutas$datos),pattern="^DIVIPOLA-.*\\.csv$",full.names=TRUE)
crosswalk<-tribble(~codigo_2018,~codigo_2026,~tipo_cambio,~fuente,~estado,~se_aplica_en,
 "94663","94343","Fusion Mapiripana a Barrancominas","Ordenanza 248 de 2019, Guainia","documentado","Solo enlace SECOP; ambos permanecen en universo CNPV 2018",
 "27615","27493","Posible segregacion a Nuevo Belen de Bajira","Hipotesis autor; verificar DANE/IGAC","pendiente de verificacion","No dividir conteos 2018; agregar contratos SECOP a 27615 solo si confirma el padre")
if(length(div_path)==1){
 div<-read_txt(div_path)
 colcode<-intersect(names(div),c("Código Municipio","Codigo Municipio","codigo_municipio"))[1]
 if(!is.na(colcode)){
  div_codes<-str_pad(div[[colcode]],5,pad="0")
  crosswalk<-bind_rows(crosswalk,
   tibble(codigo_2018=NA_character_,codigo_2026=setdiff(unique(div_codes),codes),tipo_cambio="DIVIPOLA sin equivalente CNPV 2018",fuente=basename(div_path),estado="documentar",se_aplica_en="Fuera del universo CNPV 2018"),
   tibble(codigo_2018=setdiff(codes,unique(div_codes)),codigo_2026=NA_character_,tipo_cambio="CNPV 2018 sin equivalente DIVIPOLA 2026",fuente=basename(div_path),estado="documentar",se_aplica_en="Conservar en universo 2018; resolver para enlace SECOP"))
 }
}
wo(crosswalk,"crosswalk_enlace.csv")


message("[7/8] No respuesta y sensibilidad por indicador")
nr<-bind_rows(
 tibble(codigo_municipio=p17$codigo_municipio,bloque="17PM",item="sin_informacion",n_nr=p17$sin_informacion,total=p17$total),
  tibble(codigo_municipio=p5$codigo_municipio,bloque="5PM",item="no_informa",n_nr=p5$no_informa,total=p5$total),
 tibble(codigo_municipio=v8$codigo_municipio,bloque="8V_gas",item="sin_informacion",n_nr=v8$gas_sin_informacion,total=v8$gas_total),
 tibble(codigo_municipio=v8$codigo_municipio,bloque="8V_internet",item="sin_informacion",n_nr=v8$internet_sin_informacion,total=v8$internet_total),
 tibble(codigo_municipio=v10$codigo_municipio,bloque="10V",item="no_sabe_no_responde",n_nr=v10$no_sabe_no_responde,total=v10$personas_hogares_particulares),
 tibble(codigo_municipio=v10$codigo_municipio,bloque="10V",item="no_tiene_estrato (categoria distinta)",n_nr=v10$no_tiene_estrato,total=v10$personas_hogares_particulares)
)%>%mutate(tasa_nr=rate(n_nr,total))%>%left_join(master%>%select(codigo_municipio,nombre_municipio),by="codigo_municipio")
nr_flags<-nr%>%filter(item!="no_tiene_estrato (categoria distinta)")%>%group_by(codigo_municipio,nombre_municipio)%>%summarise(tasa_nr_max=max(tasa_nr,na.rm=TRUE),nr_gt5=any(tasa_nr>ivs_config$umbrales_nr[["gt_5"]],na.rm=TRUE),nr_gt10=any(tasa_nr>ivs_config$umbrales_nr[["gt_10"]],na.rm=TRUE),nr_gt20=any(tasa_nr>ivs_config$umbrales_nr[["gt_20"]],na.rm=TRUE),.groups="drop")
nr<-nr%>%left_join(nr_flags,by=c("codigo_municipio","nombre_municipio"))
wo(nr,"nr_item_municipal.csv")
ae("Municipios con item NR >5%",83,sum(nr_flags$nr_gt5),"No_tiene_estrato queda aparte")
ae("Municipios con item NR >10%",37,sum(nr_flags$nr_gt10))
ae("Municipios con item NR >20%",7,sum(nr_flags$nr_gt20))
sensitive<-ind_spec%>%filter(sensible_nr)%>%pull(id_indicador)
deltas<-map_dfr(sensitive,function(nm){
 a<-ind[[nm]];b<-ind[[paste0(nm,"_valida")]];delta<-abs(b-a);rel<-ifelse(!is.na(a)&a!=0,delta/abs(a),NA_real_)
 tibble(codigo_municipio=ind$codigo_municipio,id_indicador=nm,base_total=a,base_valida=b,diferencia_abs=delta,diferencia_rel=rel,sens_alta=delta>=ivs_config$sensibilidad[["delta_absoluta"]]|rel>=ivs_config$sensibilidad[["delta_relativa"]])
})
wo(deltas,"sensibilidad_nr_municipio.csv")
sens_summary<-map_dfr(sensitive,function(nm){
 x<-deltas%>%filter(id_indicador==nm);ok<-complete.cases(x$base_total,x$base_valida)
 tibble(id_indicador=nm,spearman=if(sum(ok)>2)cor(x$base_total[ok],x$base_valida[ok],method="spearman") else NA_real_,
 dif_abs_max=max(x$diferencia_abs,na.rm=TRUE),dif_abs_mediana=median(x$diferencia_abs,na.rm=TRUE),
            n_abs_ge_002=sum(x$diferencia_abs>=ivs_config$sensibilidad[["delta_absoluta"]],na.rm=TRUE),n_rel_ge_10pct=sum(x$diferencia_rel>=ivs_config$sensibilidad[["delta_relativa"]],na.rm=TRUE),
 n_sens_alta=sum(x$sens_alta,na.rm=TRUE),n_base_valida_NA=sum(is.na(x$base_valida)))
})%>%arrange(desc(n_sens_alta),desc(dif_abs_max))
wo(sens_summary,"sensibilidad_nr.csv")

message("[8/8] Reconciliaciones e IPM")
sum_check<-function(df,cols,total,label){
 bad<-contar_sumas_distintas(df,cols,total,ivs_config$control$tolerancia_suma)
 av(label,nrow(df),bad,paste("abs <=",ivs_config$control$etiqueta_tolerancia_suma))
}
demo_cat<-c("ninguno","preescolar","primaria_completa","primaria_incompleta","secundaria_completa","secundaria_incompleta","media_completa","media_incompleta","normal_completa","normal_incompleta","tecnico","tecnologico","universitario","especializacion_maestria_doctorado","sin_informacion")
social_cat<-setdiff(names(p5),c(names(master)[1], "area","sexo","total_5","no_informa","busco_trabajo","realizo_oficios_del_hogar","no_trabajo_pero_tenia_un_empleo_trabajo_o_negocio_por_el_que_recibe_ingresos","busco_trabajo","vivio_de_jubilacion_pension_o_renta","estudio","realizo_oficios_del_hogar","esta_incapacitado_a_permanentemente_para_trabajar","estuvo_en_otra_situacion"))
# Verify each row family totals before municipal aggregation.
p17_all<-d$persona_demo_17PM%>%ncols(names(d$persona_demo_17PM)[7:ncol(d$persona_demo_17PM)],"17PM")
p5_all<-d$persona_social_5PM%>%ncols(names(d$persona_social_5PM)[7:ncol(d$persona_social_5PM)],"5PM")
sum_check(p17_all,c("ninguno","preescolar","primaria_completa","primaria_incompleta","secundaria_completa","secundaria_incompleta","media_completa","media_incompleta","normal_completa","normal_incompleta","tecnico","tecnologico","universitario","especializacion_maestria_doctorado","sin_informacion"),"total","17PM total = suma de categorias")
sum_check(p5_all,setdiff(names(p5_all),c("codigo_departamento","codigo_municipio","nombre_municipio","nombre_departamento","area","sexo","total")),"total","5PM total = suma de categorias")
sex_check<-function(x,label){w<-x%>%select(codigo_municipio,area,sexo,total)%>%pivot_wider(names_from=sexo,values_from=total);b<-sum(abs(w$Total-w$Hombre-w$Mujer)>ivs_config$control$tolerancia_suma,na.rm=TRUE);av(paste(label,"Total=Hombre+Mujer"),nrow(w),b,paste("abs <=",ivs_config$control$etiqueta_tolerancia_suma))}
sex_check(p17_all,"17PM");sex_check(p5_all,"5PM")
v8_all<-d$viviendas_8V%>%ncols(names(d$viviendas_8V)[6:ncol(d$viviendas_8V)],"8V")
for(s in c("energia","acueducto","alcantarillado","gas","basuras","internet")){
 cols<-paste0(s,c("_si","_no",if(s%in%c("gas","internet")) "_sin_informacion"))
 cols<-intersect(cols,names(v8_all));sum_check(v8_all,cols,paste0(s,"_total"),paste("8V servicio",s,"= categorias"))
}
v10_all<-d$viviendas_10V%>%ncols(names(d$viviendas_10V)[6:ncol(d$viviendas_10V)],"10V")
sum_check(v10_all,c("sin_servicio_energia","no_tiene_estrato","estrato_1","estrato_2","estrato_3","estrato_4","estrato_5","estrato_6","no_sabe_no_responde"),"personas_hogares_particulares","10V BU = suma BV:CD")
ipm<-d$ipm_municipal_ancho%>%ncols(setdiff(names(d$ipm_municipal_ancho),c("codigo_departamento","codigo_municipio","nombre_municipio","nombre_departamento","region_geografica","municipio")),"IPM")%>%mutate(ipm_cabecera_no_aplica=is.na(cabeceras))
ipm_cols<-setdiff(names(ipm),c("codigo_departamento","codigo_municipio","nombre_municipio","nombre_departamento","region_geografica","municipio","ipm_cabecera_no_aplica"))
ipm_na<-map_int(ipm[ipm_cols],~sum(is.na(.x)))
ipm_head_na<-ipm%>%filter(is.na(cabeceras))%>%pull(codigo_municipio)
head_missing<-areas%>%filter(!existe_Cabecera)%>%pull(codigo_municipio)
sin_cabecera<-den%>%filter(es_anm_2018)%>%select(codigo_departamento,codigo_municipio,nombre_municipio,nombre_departamento,tipo_divipola,pob_total,pct_rural_disperso)%>%left_join(ipm%>%select(codigo_municipio,cabeceras),by="codigo_municipio")
wo(sin_cabecera,"municipios_sin_cabecera.csv")
wo(sin_cabecera%>%count(codigo_departamento,nombre_departamento,tipo_divipola,name="municipios_sin_cabecera"),"resumen_sin_cabecera_departamento.csv")
av("20 NA IPM cabeceras = municipios sin cabecera",20,length(setdiff(ipm_head_na,head_missing))+length(setdiff(head_missing,ipm_head_na)))
av("IPM Municipal = IPM",nrow(ipm),sum(abs(ipm$ipm_municipal-ipm$ipm)>ivs_config$control$tolerancia_ipm,na.rm=TRUE),as.character(ivs_config$control$tolerancia_ipm))
av("IPM fuera de rango 0-100",nrow(ipm)*length(ipm_cols),sum(map_int(ipm[ipm_cols],~sum(.x<0|.x>100,na.rm=TRUE))),"[0,100]")
av("IPM NA fuera de Cabeceras",nrow(ipm),sum(ipm_na[names(ipm_na)!="cabeceras"]))
ww(ipm%>%select(-municipio),"ipm_municipal_ancho.csv")
ae("NA estructurales IPM cabeceras",20,sum(is.na(ipm$cabeceras)))

# Conteos municipales: negativos y valores no enteros se documentan sin corregir.
count_audit<-function(df,cols,label){
 map_dfr(cols,function(nm){
  x<-parse_n(df[[nm]],paste(label,nm))
  tibble(tabla=label,columna=nm,n=sum(!is.na(x)),negativos=sum(x<0,na.rm=TRUE),no_enteros=sum(abs(x-round(x))>ivs_config$control$tolerancia_suma,na.rm=TRUE),faltantes=sum(is.na(x)))
 })
}
count_audit_out<-bind_rows(
 count_audit(age_full,c("total","hombre","mujer"),"1PM"),
 count_audit(d$hogares_1HM_2HM%>%ncols(names(d$hogares_1HM_2HM)[6:ncol(d$hogares_1HM_2HM)],"HOGARES"),names(d$hogares_1HM_2HM)[6:ncol(d$hogares_1HM_2HM)],"HOGARES"),
 count_audit(p17_all,names(p17_all)[7:ncol(p17_all)],"17PM"),
 count_audit(p5_all,names(p5_all)[7:ncol(p5_all)],"5PM"),
 count_audit(v8_all,names(v8_all)[6:ncol(v8_all)],"8V"),
 count_audit(v10_all,names(v10_all)[6:ncol(v10_all)],"10V"),
 count_audit(d$viviendas_6V%>%ncols(names(d$viviendas_6V)[6:ncol(d$viviendas_6V)],"6V"),names(d$viviendas_6V)[6:ncol(d$viviendas_6V)],"6V"),
 count_audit(d$contexto_1V,c("viviendas_total","ocupada_presentes","ocupada_ausentes","temporal_vacaciones","desocupada"),"1V")
)
wo(count_audit_out,"auditoria_conteos.csv")
av("Valores negativos en conteos",sum(count_audit_out$n),sum(count_audit_out$negativos),"0")
av("Valores no enteros en conteos",sum(count_audit_out$n),sum(count_audit_out$no_enteros),"0")
av("Llaves universo 2018 únicas",nrow(master),sum(duplicated(master$codigo_municipio)),"0")

# Hashes de los insumos: comprobación al cierre, incluidos los diez CSV intermedios.
hash_after<-hash(c(paths,master_path))
hash_unchanged<-identical(hash_before$md5,hash_after$md5)
av("MD5 insumos sin cambios",nrow(hash_before),sum(hash_before$md5!=hash_after$md5),"0")
wo(hash_before,"md5_insumos_antes.csv");wo(hash_after,"md5_insumos_despues.csv")
wo(exp,"resumen_hallazgos.csv");wo(val,"validaciones.csv")
if(!hash_unchanged) stop("Cambio inesperado en hash de insumos; revisar antes de continuar.")

# Nota Obsidian en español: distingue decisiones del autor, reglas implementadas e inferencias.
md_table<-function(x){
 x<-as.data.frame(x,stringsAsFactors=FALSE)
 clean<-lapply(x,function(v){v<-ifelse(is.na(v),"",as.character(v));v<-gsub("[\r\n]+"," ",v);gsub("|","\\\\|",v,fixed=TRUE)})
 names(clean)<-names(x);x<-as.data.frame(clean,check.names=FALSE)
 c(paste0("| ",paste(names(x),collapse=" | ")," |"),paste0("| ",paste(rep("---",ncol(x)),collapse=" | ")," |"),
   apply(x,1,function(r)paste0("| ",paste(r,collapse=" | ")," |")))
}
rural_min_pct<-100*min(sin_cabecera$pct_rural_disperso,na.rm=TRUE)
rural_max_pct<-100*max(sin_cabecera$pct_rural_disperso,na.rm=TRUE)
aptitud_note<-"Descriptivos, correlaciones y diagnósticos previos se generan por R/03_auditoria_indicadores.R. No se ejecuta PCA ni bootstrap."
note<-c(
 "> Enlaces de la bóveda: [[Inicio_Proyecto]] · [[Estructura_Bases]] · [[VERIFICACION_CONSOLIDADOS]] · [[Correccion_Estructura_Bases]] · [[docs/calidad/Auditoria_Estadistica_Indicadores]] · [[docs/calidad/Refactorizacion_Pipeline_Indicadores]]",
 "", "# Base final e indicadores candidatos (PCA no ejecutado)", "",
 "Fecha de ejecución: 2026-10-13. Script: R/02_base_final_indicadores.R.",
 "", "## Alcance",
 "",
 "La ejecución construye los denominadores, especifica indicadores, calcula proporciones en versiones base total y base válida para variables sensibles a no respuesta, y genera matrices y diagnósticos de aptitud. No ejecuta PCA ni bootstrap.",
 "", "## Decisiones metodológicas fijadas por el autor",
 "",
 "- Universo: 1.122 códigos con datos CNPV/IPM 2018. Se conservan sin fusiones o exclusiones; los cambios se reservan para el enlace posterior con SECOP.",
 "- Los CSV en datos/intermedio son de solo lectura. Sus MD5 antes y después están en resultados/base_trabajo/.",
 "- No hay imputación estadística. Las combinaciones demográficas ausentes dentro de áreas existentes se completan como ceros estructurales y se marcan. Las áreas inexistentes se documentan y no se crean filas.",
 "- Los índices 0/0 quedan NA y se señalan con flag_indice_indefinido. Los 20 NA de Cabeceras en IPM se conservan como NA estructural y se cotejan con municipios sin cabecera.",
 "- No respuesta de ítem se trata como calidad: base total incluye la categoría en el denominador y base válida la resta. no_tiene_estrato se mantiene distinto de no_sabe_no_responde.",
 "- El IPM se reserva para validación externa. Se excluyen del PCA propuesto indicadores que replican directamente sus privaciones.",
 paste0("- El total de 17PM coincide con la población de 5+ de 1PM en los 1.122 municipios. Por ello pob_10mas se calculó desde 1PM; el total de 17PM se conserva como pob_17PM_educacion. Las categorías de nivel educativo no se pueden filtrar a 10+ con los archivos disponibles."),
 "", "## Especificación de indicadores",
 "",
 "Verificación estructural de edad: el total de 17PM (Nivel educativo) coincide con población 5+ de 1PM, no con población 10+. El libro no permite cortar las categorías de nivel educativo por edad; se calculan usando el total del 17PM y se documenta esta discrepancia. pob_10mas se calcula desde los grupos 1PM de 10 años o más; la cobertura de 5PM se coteja contra ese valor.",
 "Los indicadores de educación, paredes inadecuadas, acueducto, alcantarillado y dependencia se calculan para descripción, pero quedan fuera de la matriz PCA propuesta por solapamiento con IPM. Hogares con adultos mayores queda fuera hasta definir su dirección. Como candidatos analíticos provisionales quedan actividad no ocupada, falta de electricidad, gas, recolección, internet, hogares con menores y estratos 1-2. La decisión final de inclusión corresponde al autor; consultar especificacion_indicadores.csv.",
 "", "## Resultados esperado vs obtenido", "", md_table(exp), "",
 "## Resultados de validación", "", md_table(val), "",
 aptitud_note, "",
 "## Tratamiento de territorio y calidad",
 "",
 "- 94663 Mapiripana → 94343 Barrancominas: documentado para la capa SECOP; en 2018 permanecen ambos códigos.",
 "- 27493 Nuevo Belén de Bajirá: se propone 27615 Riosucio como padre, pendiente de verificación DANE/IGAC. Existe conflicto histórico con 05480 Mutatá; Riosucio suma 48.257 personas y un centro poblado de 13.504, mientras Mutatá suma 12.607. Es evidencia compatible, no prueba del límite; no se dividen datos CNPV.",
 paste0("- En los veinte municipios sin cabecera hay 26.569 personas en las 18 áreas no municipalizadas DIVIPOLA. Los otros dos códigos suman 8.218: 94343 Barrancominas (7.207) y 94663 Mapiripana (1.011). La proporción rural dispersa de esos veinte va de ",round(rural_min_pct,2),"% a ",round(rural_max_pct,2),"%; consultar municipios_sin_cabecera.csv."),
 "- Umbrales operativos de cobertura: 5PM sobre pob_10mas, menores15 de HOGARES sobre 1PM y personas 60+ usan los parámetros de R/00_config.R. El prompt no daba esos tres umbrales; quedan editables y requieren aprobación metodológica.",
 "- La población agregada de los 20 municipios sin cabecera se informa con pct_rural_disperso por municipio en municipios_sin_cabecera.csv. Los códigos fuera del conjunto de ANM 2026 se mantienen separados.",
 "- La hipótesis para 27493 tiene conflicto histórico con Mutatá (05480); los totales municipales de 2018 y el centro poblado de Riosucio son coherentes con que incluya parte de Bajirá, pero no prueban el padre. No se fraccionan ni reasignan los conteos.",
 "- Comparar el PCA posterior con y sin los 20 municipios sin cabecera como análisis de sensibilidad; esta etapa solo crea la bandera y covariables.",
 "", "## Entregables",
 "",
 "Tablas de denominadores e indicadores: datos/trabajo/. Especificación, controles, sensibilidad, crosswalk y diagnósticos: resultados/base_trabajo/.",
 "", "## Próximo paso",
 "",
 "Aprobar indicadores y direcciones, confirmar el umbral de cobertura y el padre de 27493; después ejecutar PCA, selección de componentes, bootstrap y validación externa con IPM.",
 "", "Reproducción: Rscript R/02_base_final_indicadores.R (incluye auditoría R/03_auditoria_indicadores.R)."
)
writeLines(note,file.path(root,"Final_Base.md"),useBytes=TRUE)
if(matrix_na==0) source(file.path(root,"R/03_auditoria_indicadores.R"),encoding="UTF-8")
wo(exp,"resumen_hallazgos.csv");wo(val,"validaciones.csv")
message("Municipios en universo 2018: ",nrow(master),"; ceros estructurales 1PM: ",nrow(missing_age),"; indicadores: ",length(ind_ids),"; candidatos PCA: ",length(main_ids))
message("Hallazgos por revisar: ",sum(exp$estado!="PASS"),"; validaciones FAIL: ",sum(val$estado!="PASS"),"; NA matriz PCA: ",matrix_na)
message("MD5 insumos intactos: ",hash_unchanged,". PCA/bootstrap no ejecutados.")
if(matrix_na>0) stop("Hay NA inesperados en matriz_pca.csv; no se estandarizó ni ejecutó diagnóstico de aptitud. Ver na_matriz_pca_detencion.csv y Final_Base.md.")







# Instalação de pacotes (apenas necessário uma vez)
# Estes são conjuntos de ferramentas que permitem ler, manipular e salvar dados
install.packages("tidyverse")  #Para manipulação de dados
install.packages("writexl") # Para escrever arquivos Excel
install.packages("data.table") # Para trabalhar com tabelas grandes
install.packages("readxl") # Para ler arquivos Excel
install.packages("httr") # Para baixar arquivos da internet
install.packages("openxlsx") # Para criar arquivos Excel

# Carregando os pacotes instalados
# Isso torna as ferramentas disponíveis para uso
library(tidyverse)
library(writexl)
library(data.table)
library(readxl)
library(httr)
library(openxlsx)


# ---- SUBSTITUINDO CÓDIGOS POR DESCRIÇÕES LEGÍVEIS ----

# Baixando dados da RAIS de 1994-2021 da ocupação Arqueólogo
url <- "https://raw.githubusercontent.com/machadotm/Dados_MTE_Arqueo/refs/heads/main/RAIS/Microdados_RAIS_ARQUEO_1994-2021.csv"

Dados_Arqueo_RAIS <- read_csv(url) # Lê os dados do link acima

# Criando uma tabela para traduzir códigos de afastamento (1ª causa) para descrições
Causa.Afast.DF1 <- data.frame(categorias=c(
  "ACI TRB TIP", "ACI TRB TJT","DOEN REL TR","DOEN NREL TR","LIC MATERNID","SERV MILITAR", "LIC SEM VENC",
  "LIC COM VENC","SUSP TEMP DE TRAB","ACID DOENC TRAB","SEM AFASTAMENTOS","IGNORADO"),
  Causa.Afastamento.1= c(   10,   20,   30,   40,   50,   60,   70,   80,   85,   90,   99,   -1))

# Convertendo para texto
Causa.Afast.DF1$Causa.Afastamento.1 <-  as.character(Causa.Afast.DF1$Causa.Afastamento.1)

# Juntando esta tabela de tradução aos dados principais
# Substitui códigos numéricos por descrições textuais
Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, Causa.Afast.DF1, by= "Causa.Afastamento.1") %>% 
  mutate(Causa.Afastamento.1 = categorias) %>% # Substitui código por texto
  dplyr::select(-categorias) # Remove coluna auxiliar

# Repetindo o mesmo processo para a 2ª causa de afastamento
Causa.Afast.DF2 <- data.frame(categorias=c(
  "ACI TRB TIP", "ACI TRB TJT","DOEN REL TR","DOEN NREL TR","LIC MATERNID","SERV MILITAR", "LIC SEM VENC",
  "LIC COM VENC","SUSP TEMP DE TRAB","ACID DOENC TRAB","SEM AFASTAMENTOS","IGNORADO"),
  Causa.Afastamento.2= c(   10,   20,   30,   40,   50,   60,   70,   80,   85,   90,   99,   -1))

Causa.Afast.DF2$Causa.Afastamento.2 <-  as.character(Causa.Afast.DF2$Causa.Afastamento.2)

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, Causa.Afast.DF2, by= "Causa.Afastamento.2") %>% 
  mutate(Causa.Afastamento.2 = categorias) %>%
  dplyr::select(-categorias)

# Repetindo para a 3ª causa de afastamento
Causa.Afast.DF3 <- data.frame(categorias=c(
  "ACI TRB TIP", "ACI TRB TJT","DOEN REL TR","DOEN NREL TR","LIC MATERNID","SERV MILITAR", "LIC SEM VENC",
  "LIC COM VENC","SUSP TEMP DE TRAB","ACID DOENC TRAB","SEM AFASTAMENTOS","IGNORADO"),
  Causa.Afastamento.3= c(   10,   20,   30,   40,   50,   60,   70,   80,   85,   90,   99,   -1))

Causa.Afast.DF3$Causa.Afastamento.3 <-  as.character(Causa.Afast.DF3$Causa.Afastamento.3)

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, Causa.Afast.DF3, by= "Causa.Afastamento.3") %>% 
  mutate(Causa.Afastamento.3 = categorias) %>%
  dplyr::select(-categorias)

# Traduzindo códigos de motivo de desligamento
Motivo.Deslig.DF <- data.frame(categorias=c(
  "DEM COM JC",  "DEM SEM JC",  "TERM CONTR",  "DESL COM JC",  "DESL SEM JC",  "POSS OUT CAR",  "TRANS C/ONUS",
  "TRANS S/ONUS",  "READAP/REDIS",  "CESSAO",  "REDISTRIBUIÇÃO",  "MUD. REGIME",  "REFORMA",  "FALECIMENTO",
  "FALEC AC TRB",  "FALEC AC TIP",  "FALEC D PROF",  "APOS TS CRES",  "APOS TS SRES",  "APOS ID CRES",
  "APOS IN ACID",  "APOS IN DOEN",  "APOS COMPULS",  "APOS IN OUTR",  "APOS ID SRES",  "APOS ESP CRE",
  "APOS ESP SRE",  "DESL POR ACORDO",  "NAO DESL ANO",  "IGNORADO"),
  Motivo.Desligamento=c(
    10,    11,    12,    20,    21,    22,    30,    31,    32,    33,    34,    40,    50,    60,    62,    63,
    64,    70,    71,    72,    73,    74,    75,    76,    78,    79,    80,    90,    0,    -1))


Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, Motivo.Deslig.DF, by= "Motivo.Desligamento") %>% 
  mutate(Motivo.Desligamento = categorias) %>%
  dplyr::select(-categorias)

# Baixando e processando informações de CNAE (Classificação Nacional de Atividades Econômicas)
url2 <- "https://github.com/machadotm/Novos_Dados_MTE_Arqueo/raw/refs/heads/main/Scripts_R/CNAE20_EstruturaDetalhada.xls"
tmp <- tempfile(fileext = ".xls") # Cria arquivo temporário
GET(url2, write_disk(tmp)) # Baixa o arquivo

# Lê a planilha com informações do CNAE
CNAE20.IBGE <- read_excel(tmp, 
                          sheet = "Planilha1")

# Limpa e formata os códigos CNAE
CNAE20.IBGE$CNAE.2.0.Classe <- gsub("[.-]", "", CNAE20.IBGE$CNAE.2.0.Classe) %>% 
  as.integer(CNAE20.IBGE$CNAE.2.0.Classe)
  
# Remove colunas desnecessárias
CNAE20.IBGE <- subset(CNAE20.IBGE,
                      select = -c(Seção, Divisão, Grupo))

# Cria uma tabela de referência com códigos CNAE de 4 dígitos e suas descrições
CNAE_PONTE <- CNAE20.IBGE %>%
  mutate(CNAE_4digitos = str_sub(as.character(CNAE.2.0.Classe), 1, 4)) %>%
  select(CNAE_4digitos, CNAE_Completo = CNAE.2.0.Classe, Denominacao) %>%
  distinct(CNAE_4digitos, .keep_all = TRUE) %>% # Remove duplicatas
  na.omit() # Remove valores faltantes

# Aplica as traduções de CNAE aos dados principais
Dados_Arqueo_RAIS <- Dados_Arqueo_RAIS %>% 
  mutate(CNAE_4digitos = str_sub(as.character(CNAE.2.0.Classe), 1, 4)) %>%
  left_join(CNAE_PONTE, by = "CNAE_4digitos") %>%
  mutate(CNAE.2.0.Classe = Denominacao) %>% # Substitui código pela descrição
  select(-c(CNAE_4digitos, CNAE_Completo, Denominacao)) # Remove colunas auxiliares

# Processa classificações CNAE mais antigas (1995)
CNAE95.DF<- read_excel(tmp, 
                       sheet = "CNAE 95")

CNAE95.DF <- CNAE95.DF %>%
  separate(`CNAE.95.Classe:Categoria`, into = c("CNAE.95.Classe", "Categoria"), sep = ":",
           extra = "merge", fill = "right") 

CNAE95.DF$CNAE.95.Classe <- as.integer(CNAE95.DF$CNAE.95.Classe)

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, CNAE95.DF, by= "CNAE.95.Classe") %>% 
  mutate(CNAE.95.Classe = Categoria) %>%
  dplyr::select(-Categoria)

# Continua traduzindo outras colunas...

Vinc.Atv.31.12 <- data.frame(status=c("SIM","NÃO"),
                             Vínculo.Ativo.31.12=c(1,0))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, Vinc.Atv.31.12, by= "Vínculo.Ativo.31.12") %>% 
  mutate(Vínculo.Ativo.31.12 = status) %>%
  dplyr::select(-status)

Faixa.Etária.DF <- data.frame(Faixa.Idade=c(
  "10 A 14 anos",   "15 A 17 anos",  "18 A 24 anos",  "25 A 29 anos",  "30 A 39 anos",  "40 A 49 anos",
  "50 A 64 anos",  "65 anos ou mais"),
  Faixa.Etária= c(1,    2,    3,    4,    5,    6,    7,    8 ))


Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, Faixa.Etária.DF, by= "Faixa.Etária") %>% 
  mutate(Faixa.Etária = Faixa.Idade) %>%
  dplyr::select(-Faixa.Idade)


Faixa.Hora.Contrat.DF <- data.frame(hora=c(
  "Até 12 horas",  "13 a 15 horas",  "16 a 20 horas",  "21 a 30 horas",  "31 a 40 horas",  "41 a 44 horas", 
  "Acima de 44 horas" , "Acima de 44 horas" ,"{ñ class}"),
  Faixa.Hora.Contrat= c(1,    2,    3,    4,    5,    6, 7, 8, 99))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, Faixa.Hora.Contrat.DF, by= "Faixa.Hora.Contrat") %>% 
  mutate(Faixa.Hora.Contrat = hora) %>%
  dplyr::select(-hora)


faixa.media.dez <- data.frame(media.dez=c(
  "Não Ativ Dez",  "Até 0,50 salários mínimos",  "0,51 a 1,00 salários mínimos",
  "1,01 a 1,50 salários mínimos",  "1,51 a 2,00 salários mínimos",  "2,01 a 3,00 salários mínimos",
  "3,01 a 4,00 salários mínimos",  "4,01 a 5,00 salários mínimos",  "5,01 a 7,00 salários mínimos",
  "7,01 a 10,00 salários mínimos",  "10,01 a 15,00 salários mínimos",  "15,01 a 20,00 salários mínimos",
  "Mais de 20,00 salários mínimos",  "{ñ class}"),
  Faixa.Remun.Dezem..SM. =c( 0,    1,    2,    3,    4,    5,    6,    7,    8,    9,    10,    11,    12,    99))

faixa.media.dez$Faixa.Remun.Dezem..SM. <- as.character(faixa.media.dez$Faixa.Remun.Dezem..SM.)

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, faixa.media.dez, by= "Faixa.Remun.Dezem..SM.") %>% 
  mutate(Faixa.Remun.Dezem..SM. = media.dez) %>%
  dplyr::select(-media.dez)

faixa.media.anual <- data.frame(media.anual=c(
  "Até 0,50 salários mínimos",  "0,51 a 1,00 salários mínimos",  "1,01 a 1,50 salários mínimos",
  "1,51 a 2,00 salários mínimos",  "2,01 a 3,00 salários mínimos",  "3,01 a 4,00 salários mínimos",
  "4,01 a 5,00 salários mínimos",  "5,01 a 7,00 salários mínimos",  "7,01 a 10,00 salários mínimos",
  "10,01 a 15,00 salários mínimos",  "15,01 a 20,00 salários mínimos",  "Mais de 20,00 salários mínimos",
  "{ñ class}"),
  Faixa.Remun.Média..SM. =c(
    1,    2,    3,    4,    5,    6,    7,    8,    9,    10,  11, 12,  99))

faixa.media.dez$Faixa.Remun.Dezem..SM. <- as.character(faixa.media.dez$Faixa.Remun.Dezem..SM)

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, faixa.media.anual, by= "Faixa.Remun.Média..SM.") %>% 
  mutate(Faixa.Remun.Média..SM. = media.anual) %>%
  dplyr::select(-media.anual)


faixa.emprego <- data.frame(emprego=c(
  "Ate 2,9 meses",  "3,0 a 5,9 meses",  "6,0 a 11,9 meses",  "12,0 a 23,9 meses",  "24,0 a 35,9 meses",
  "36,0 a 59,9 meses",  "60,0 a 119,9 meses",  "120,0 meses ou mais",  "{ñ class}"),
  Faixa.Tempo.Emprego=c(
    1,    2,    3,    4,    5,    6,    7,    8,    9))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, faixa.emprego, by= "Faixa.Tempo.Emprego") %>% 
  mutate(Faixa.Tempo.Emprego = emprego) %>%
  dplyr::select(-emprego)

escola.1985a2005 <- data.frame(grau_titulacao=c(
  "ANALFABETO",  "4.SER INCOMP",  "4.SER COMP",  "8.SER INCOMP",  "8.SER COMP",  "2.GR INCOMP",
  "2GR. COMP",  "SUP. INCOMP",  "SUP. COMP"),
  Grau.Instrução.2005.1985=c(
    1, 2, 3, 4, 5, 6, 7, 8, 9))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, escola.1985a2005, by= "Grau.Instrução.2005.1985") %>% 
  mutate(Grau.Instrução.2005.1985 = grau_titulacao) %>%
  dplyr::select(-grau_titulacao)

escola.apos2005 <- data.frame(grau_titulacao=c(
  "ANALFABETO",  "ATE 5.A INC",  "5.A CO FUND",  "6. A 9. FUND",  "FUND COMPL",  "MEDIO INCOMP",
  "MEDIO COMPL",  "SUP. INCOMP",  "SUP. COMP",  "MESTRADO",  "DOUTORADO",  "IGNORADO"),
  Escolaridade.após.2005=c(
    1,    2,    3,    4,    5,    6,    7,    8,    9,    10,    11,    -1))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, escola.apos2005, by= "Escolaridade.após.2005") %>% 
  mutate(Escolaridade.após.2005 = grau_titulacao) %>%
  dplyr::select(-grau_titulacao)


Cei_VInc <- data.frame(cei=c( "NAO",  "SIM"),Ind.CEI.Vinculado=c(0,1))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, Cei_VInc, by= "Ind.CEI.Vinculado") %>% 
  mutate(Ind.CEI.Vinculado = cei) %>%
  dplyr::select(-cei)

simples <- data.frame(i.simples=c( "NAO",  "SIM"),
                      Ind.Simples=c(0,1))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, simples, by= "Ind.Simples") %>% 
  mutate(Ind.Simples = i.simples) %>%
  dplyr::select(-i.simples)

url3 <- "https://github.com/machadotm/Dados_MTE_Arqueo/raw/refs/heads/main/RAIS/Dicionario_Dados/RAIS_vinculos_layout.xls"
tmp2 <- tempfile(fileext = ".xls")
GET(url3, write_disk(tmp2))

uf.municipios <- read_excel(tmp2, 
                            sheet = "municipio")

uf.municipios <- uf.municipios %>%
  separate(Município, into = c("Mun.Trab", "geral"), sep = ":") %>% 
  separate(geral, into = c("UF", "Municípios"), sep = "-",
           extra = "merge", fill = "right")

uf.municipios$UF <- toupper(uf.municipios$UF)

uf.municipios <- uf.municipios[-c(5659:5664),]

uf.municipios <- uf.municipios %>% 
  unite(Municípios, Municípios, UF, sep = "-")

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, uf.municipios, by= "Mun.Trab") %>% 
  mutate(Mun.Trab = Municípios) %>%
  dplyr::select(-Municípios)

setnames(uf.municipios,old = "Mun.Trab",
         new = "Município")

uf.municipios$Município <- as.numeric(uf.municipios$Município)

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, uf.municipios, by= "Município") %>% 
  mutate(Município = Municípios) %>%
  dplyr::select(-Municípios)


nacionalidade <- data.frame(paises=c(
  "Brasileira",  "Naturalidade Brasileira",  "Argentina",  "Boliviana",  "Chilena",  "Paraguaia",
  "Uruguaia",  "Venezuelano",  "Colombiano",  "Peruano",  "Equatoriano",  "Alemã",  "Belga",
  "Britânica",  "Canadense",  "Espanhola",  "Norte-Americana",  "Francesa",  "Suíça",  "Italiana",
  "Haitiano",  "Japonesa",  "Chinesa",  "Coreana",  "Russo",  "Portuguesa",  "Paquistanês",
  "Indiano",  "Outras Latino-Americanas",  "Outras Asiáticas",  "Outras Nacionalidades",
  "Outros Europeus",  "Guine Bissau (Guineense)",  "Marroquino",  "Cubano",  "Sirio",  "Sul-Coreano",
  "Bengalesa",  "Angolano",  "Congolês",  "Sul-Africano",  "Ganesa",  "Senegalesa",  "Norte-Coreana",
  "Outros Africanos",  "Outros",  "IGNORADO"),
  Nacionalidade=c(
    10,    20,    21,    22,    23,    24,    25,    26,    27,    28,    29,    30,    31,    32,    34,
    35,    36,    37,    38,    39,    40,    41,    42,    43,    44,    45,    46,    47,    48,    49,
    50,    51,    52,    53,    54,    55,    56,    59,    60,    61,    62,    63,    64,    65,    70,
    80,    -1 ))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, nacionalidade, by= "Nacionalidade") %>% 
  mutate(Nacionalidade = paises) %>%
  dplyr::select(-paises)

nat.jur <- data.frame(juridico=c(
  "POD EXEC FE",  "POD EXEC ES",  "POD EXEC MU",  "POD LEG FED",  "POD LEG EST",  "POD LEG MUN",  "POD JUD FED",
  "POD JUD EST",  "AUTARQ FED",  "AUTARQ EST",  "AUTARQ MUN",  "FUNDAC FED",  "FUNDAC EST",  "FUNDAC MUN",
  "ORG AUT FED",  "ORG AUT EST",  "ORG AUT MUN",  "COM POLINAC",  "FUNDO PUBLIC",  "ASSOC PUBLIC",  
  "CONS PUB DIR PRIV",  "ESTADO DF",  "MUNICIPIO",  "FUND PUB DIR PRIV FED",  "FUND PUB DIR PRIV EST",
  "FUND PUB DIR PRIV MUN",  "EMP PUB",  "SOC MISTA",  "SA ABERTA",  "SA FECH",  "SOC QT LTDA",  "SOC COLETV",
  "SOC COLETV07",  "SOC COMD SM",  "SOC COMD AC",  "SOC CAP IND",  "SOC CIVIL",  "SOC CTA PAR",  "FRM MER IND",
  "COOPERATIVA",  "CONS EMPRES",  "GRUP SOC",  "FIL EMP EXT",  "FIL ARG-BRA",  "ENT ITAIPU",  "EMP DOM EXT",
  "FUN INVEST",  "SOC SIMP PUR",  "SOC SIMP LTD",  "SOC SIMP COL",  "SOC SIMP COM",  "EMPR BINAC",  "CONS EMPREG",
  "CONS SIMPLES",  "EIRL NAT EMPRES",  "EIRL NAT SIMPLES",  "CARTORIO",  "ORG SOCIAL",  "OSCIP",  "OUT FUND PR",
  "SERV SOC AU",  "CONDOMIN",  "UNID EXEC",  "COM CONC",  "ENT MED ARB",  "PART POLIT",  "ENT SOCIAL",
  "ENT SOCIAL07",  "FIL FUN EXT",  "FUN DOM EXT",  "ORG RELIG",  "COMUN INDIG",  "FUNDO PRIVAD",  "DIR NAC PARTIDO",
  "DIR REG PARTIDO",  "DIR LOCAL PARTIDO",  "FINANC PARTIDO",  "FRENT PLEBISCIT",  "ORG SOCIAL OS",  "OUTR ORG",
  "EMP IND IMO",  "SEG ESPEC",  "CONTR IND",  "CONTR IND07",  "CAN CARG POL",  "LEILOEIRO",  "PROD RURAL PF",
  "ORG INTERN",  "ORG INTERNAC",  "REPR DIPL ES",  "OUT INST EXT",  "IGNORADO",  "{ñ class}"),
  Natureza.Jurídica=c(
    1015,    1023,    1031,    1040,    1058,    1066,    1074,    1082,    1104,    1112,    1120,    1139,    
    1147,    1155,    1163,    1171,    1180,    1198,    1201,    1210,    1228,    1236,    1244,    1252,
    1260,    1279,    2011,    2038,    2046,    2054,    2062,    2070,    2076,    2089,    2097,    2100,
    2119,    2127,    2135,    2143,    2151,    2160,    2178,    2194,    2208,    2216,    2224,    2232,
    2240,    2259,    2267,    2275,    2283,    2291,    2305,    2313,    3034,    3042,    3050,    3069,
    3077,    3085,    3093,    3107,    3115,    3123,    3130,    3131,    3204,    3212,    3220,    3239,
    3247,    3255,    3263,    3271,    3280,    3298,    3301,    3999,    4014,    4022,    4080,    4081,
    4090,    4111,    4120,    5002,    5010,    5029,    5037,    -1, 9999))


Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, nat.jur, by= "Natureza.Jurídica") %>% 
  mutate(Natureza.Jurídica = juridico) %>%
  dplyr::select(-juridico)


ind.def <- data.frame(indicador=c("SIM",  "NAO"), 
                      Ind.Portador.Defic=c(1, 0))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, ind.def, by= "Ind.Portador.Defic") %>% 
  mutate(Ind.Portador.Defic = indicador) %>%
  dplyr::select(-indicador)

raca.df <- data.frame(cor=c(
  "INDIGENA",  "BRANCA",  "PRETA",  "AMARELA",  "PARDA",  "NAO IDENT","IGNORADO"),
  Raça.Cor=c( 1,    2,    4,    6,    8,    9,    -1))

raca.df$Raça.Cor <- as.character(raca.df$Raça.Cor)

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, raca.df, by= "Raça.Cor") %>% 
  mutate(Raça.Cor = cor) %>%
  dplyr::select(-cor)

cnae2.0_subclas<- read_excel(tmp2, 
                             sheet = "subclasse 2.0")

cnae2.0_subclas <- cnae2.0_subclas %>%
  separate(`CNAE 2.0 Subclas`, into = c("CNAE.2.0.Subclasse", "descricao"), sep = ":",
           extra = "merge", fill = "right")

cnae2.0_subclas <- cnae2.0_subclas[-c(1330:1335),]

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, cnae2.0_subclas, by= "CNAE.2.0.Subclasse") %>% 
  mutate(CNAE.2.0.Subclasse = descricao) %>%
  dplyr::select(-descricao)

sexo <- data.frame(sexo=c(  "MASCULINO",  "FEMININO",  "IGNORADO"),
                   Sexo.Trabalhador=c( 1, 2, -1))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, sexo, by= "Sexo.Trabalhador") %>% 
  mutate(Sexo.Trabalhador = sexo) %>%
  dplyr::select(-sexo)

tamanho.estab.df <- data.frame(tamanho=c(
  "ZERO",  "ATE 4",  "DE 5 A 9",  "DE 10 A 19",  "DE 20 A 49",  "DE 50 A 99",  "DE 100 A 249",  "DE 250 A 499",
  "DE 500 A 999",  "1000 OU MAIS",  "IGNORADO"),
  Tamanho.Estabelecimento=c(1,    2,    3,    4,    5,    6,    7,    8,    9,    10,    -1))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, tamanho.estab.df, by= "Tamanho.Estabelecimento") %>% 
  mutate(Tamanho.Estabelecimento = tamanho) %>%
  dplyr::select(-tamanho)

tipo.adm.df <- data.frame(admissao= c(
  "Não Admitido Ano",  "Primeiro Emprego",  "Reemprego",  "Transferência com Ônus",  "Transferência sem Ônus",
  "Reintegração",  "Recondução",  "Reversão",  "Requisição",
  "Exercício provisório ou exercício descentralizado de servidor oriundo do mesmo órgão/entidade ou de outro órgão/entidade",
  "Readaptação (específico para servidor público)",  "Redistribuição (específico para servidor público)",
  "Exercício descentralizado de servidor oriundo do mesmo órgão/entidade ou de outro órgão/entidade",
  "Remoção (específico para servidor público)",  "IGNORADO"),
  Tipo.Admissão=c(
    0,    1,    2,    3,    4,    6,    7,    8,    9,    10,    11,    12,    13,    14,    -1))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, tipo.adm.df, by= "Tipo.Admissão") %>% 
  mutate(Tipo.Admissão = admissao) %>%
  dplyr::select(-admissao)

tipo.estb.df <- data.frame(tipo.estb=c("CNPJ", "CEI", "NAO IDENTIF","IGNORADO",
                                       "CAEPF", "CNO"),
                           Tipo.Estab=c( 1,  3,  9,  -1, 5, 6))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, tipo.estb.df, by= "Tipo.Estab") %>% 
  mutate(Tipo.Estab = tipo.estb) %>%
  dplyr::select(-tipo.estb)

tipo.defc.df <- data.frame(deficiencia=c(
  "FISICA", "AUDITIVA", "VISUAL", "MENTAL", "MULTIPLA", "REABILITADO","NAO DEFIC","IGNORADO"),
  Tipo.Defic=c(1,    2,    3,    4,    5,    6,    0,    -1))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, tipo.defc.df, by= "Tipo.Defic") %>% 
  mutate(Tipo.Defic = deficiencia) %>%
  dplyr::select(-deficiencia)

tipo.vinc <- data.frame(vinculo=c(
  "CLT U/PJ IND", "CLT U/PF IND", "CLT R/PJ IND", "CLT R/PF IND", "ESTATUTARIO","ESTAT RGPS", "ESTAT N/EFET",
  "AVULSO",  "TEMPORARIO",  "APREND CONTR",  "CLT U/PJ DET",  "CLT U/PF DET",  "CLT R/PJ DET",  "CLT R/PF DET",
  "DIRETOR",  "CONT PRZ DET",  "CONT TMP DET",  "CONT LEI EST",  "CONT LEI MUN",  "IGNORADO"),
  Tipo.Vínculo=c(
    10,    15,    20,    25,    30,    31,    35,    40,    50,    55,    60,    65,    70,    75,    80,
    90,    95,    96,    97,    -1))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, tipo.vinc, by= "Tipo.Vínculo") %>% 
  mutate(Tipo.Vínculo = vinculo) %>%
  dplyr::select(-vinculo)

ibge.subs.df <- data.frame(subsetor=c(
  "Extrativa mineral",  "Indústria de produtos minerais nao metálicos",  "Indústria metalúrgica",
  "Indústria mecânica",  "Indústria do material elétrico e de comunicaçoes",
  "Indústria do material de transporte",  "Indústria da madeira e do mobiliário",
  "Indústria do papel, papelao, editorial e gráfica",
  "Ind. da borracha, fumo, couros, peles, similares, ind. diversas",
  "Ind. química de produtos farmacêuticos, veterinários, perfumaria",
  "Indústria têxtil do vestuário e artefatos de tecidos",
  "Indústria de calçados",  "Indústria de produtos alimentícios, bebidas e álcool etílico",
  "Serviços industriais de utilidade pública",  "Construçao civil",  "Comércio varejista",
  "Comércio atacadista",  "Instituiçoes de crédito, seguros e capitalizaçao",
  "Com. e administraçao de imóveis, valores mobiliários, serv. Técnico",
  "Transportes e comunicaçoes",  "Serv. de alojamento, alimentaçao, reparaçao, manutençao, redaçao",
  "Serviços médicos, odontológicos e veterinários",  "Ensino",  "Administraçao pública direta e autárquica",
  "Agricultura, silvicultura, criaçao de animais, extrativismo vegetal",  "Ignorado"),
  IBGE.Subsetor=c(
    1,    2,    3,    4,    5,    6,    7,    8,    9,    10,    11,    12,    13,    14,    15,    16,    17,
    18,    19,    20,    21,    22,    23,    24,    25,    99))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, ibge.subs.df, by= "IBGE.Subsetor") %>% 
  mutate(IBGE.Subsetor = subsetor) %>%
  dplyr::select(-subsetor)

ind.intermit <- data.frame(indice=c("SIM",  "NAO",  "IGNORADO"),
                           Ind.Trab.Intermitente=c(1, 0, 99))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, ind.intermit, by= "Ind.Trab.Intermitente") %>% 
  mutate(Ind.Trab.Intermitente = indice) %>%
  dplyr::select(-indice)


ind.parcial <- data.frame(indice.parcial=c("SIM",  "NAO",  "IGNORADO"),
                          Ind.Trab.Parcial=c(1, 0, 99))

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, ind.parcial, by= "Ind.Trab.Parcial") %>% 
  mutate(Ind.Trab.Parcial = indice.parcial) %>%
  dplyr::select(-indice.parcial)

bairroSP <- read_excel(tmp2, 
                       sheet = "BAIRRO_SP")%>% 
  setNames(.[1, ])%>% 
  slice(-1) %>% 
  rename(Bairros.SP = `Valor na Fonte`) %>% 
  dplyr::select(-1)
  
Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, bairroSP, by= "Bairros.SP") %>% 
  mutate(Bairros.SP = Descrição) %>%
  dplyr::select(-Descrição)

bairroFort <- read_excel(tmp2, 
                       sheet = "BAIRRO FORT")%>% 
  setNames(.[1, ])%>% 
  slice(-1) %>% 
  rename(Bairros.Fortaleza = `Valor na Fonte`) %>% 
  dplyr::select(-1)

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, bairroFort, by= "Bairros.Fortaleza") %>% 
  mutate(Bairros.Fortaleza = Descrição) %>%
  dplyr::select(-Descrição)

bairroRJ <- read_excel(tmp2, 
                       sheet = "BAIRRO_RJ") %>% 
  setNames(.[1, ])%>% 
  slice(-1) %>% 
  rename(Bairros.RJ = `Valor na Fonte`) %>% 
  dplyr::select(-1)

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, bairroRJ, by= "Bairros.RJ") %>% 
  mutate(Bairros.RJ = Descrição) %>%
  dplyr::select(-Descrição)

distritoSP <- read_excel(tmp2, 
                         sheet = "Distrito SP") 

distritoSP <- rbind(names(distritoSP),distritoSP) %>% 
  rename(Distritos.SP = 0001,
         Descrição = `A RASA`)

distritoSP$Distritos.SP <- as.numeric(distritoSP$Distritos.SP)

Dados_Arqueo_RAIS$Distritos.SP <- as.numeric(Dados_Arqueo_RAIS$Distritos.SP)
   
Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, distritoSP, by= "Distritos.SP") %>% 
     mutate(Distritos.SP = Descrição) %>%
     dplyr::select(-Descrição)

regAdmDF <- read_excel(tmp2, 
                         sheet = "REG ADM DF") %>% 
  rename(Regiões.Adm.DF = `regioes administrativas DF`,
         Descrição = ...2)

regAdmDF$Regiões.Adm.DF <- as.numeric(regAdmDF$Regiões.Adm.DF)

Dados_Arqueo_RAIS$Regiões.Adm.DF <- as.numeric(Dados_Arqueo_RAIS$Regiões.Adm.DF)

Dados_Arqueo_RAIS <- left_join(Dados_Arqueo_RAIS, regAdmDF, by= "Regiões.Adm.DF") %>% 
  mutate(Regiões.Adm.DF = Descrição) %>%
  dplyr::select(-Descrição)

# Cria um arquivo Excel com os dados tratados
wb <- createWorkbook() # Cria um novo arquivo Excel
nome_da_aba <- "Resultado RAIS 1991-2021"
addWorksheet(wb, nome_da_aba) # Adiciona uma planilha
writeData(wb, sheet = nome_da_aba, x = Dados_Arqueo_RAIS, withFilter = TRUE) # Escreve os dados
setColWidths(wb, sheet = nome_da_aba, cols = 1:ncol(Dados_Arqueo_RAIS), widths = "auto") # Ajusta larguras
saveWorkbook(wb, "RAIS_1991-2021_Arqueo_Dados_Tratados.xlsx", overwrite = TRUE) # Salva o arquivo



# Instalação de pacotes (apenas necessário uma vez)
# Estes são conjuntos de ferramentas que permitem ler, manipular e salvar dados
install.packages("tidyverse")   # Para manipulação de dados
install.packages("writexl")     # Para escrever arquivos Excel
install.packages("data.table")  # Para trabalhar com tabelas grandes
install.packages("readxl")      # Para ler arquivos Excel
install.packages("httr")        # Para baixar arquivos da internet
install.packages("openxlsx")    # Para criar arquivos Excel

# Carregando os pacotes instalados
# Isso torna as ferramentas disponíveis para uso
library(tidyverse)
library(writexl)
library(data.table)
library(readxl)
library(httr)
library(openxlsx)


# ---- SUBSTITUINDO CÓDIGOS POR DESCRIÇÕES LEGÍVEIS ----

# Baixando dados do CAGED de 2007-2019 para a ocupação Arqueólogo
url <- "https://github.com/machadotm/Dados_MTE_Arqueo/raw/refs/heads/main/CAGED/1-CAGED/Microdados_CAGED_ARQUEO_2007-2019.csv"

# Lê os dados do CAGED, ajustando a codificação de caracteres (acentuação em português)
Dados_Arqueo_CAGED <- read_csv(url, locale = locale(encoding = "latin1"))

# Converte a coluna de competência (ex: 201901) para formato de data (2019-01-01)
Dados_Arqueo_CAGED <- Dados_Arqueo_CAGED %>% 
  mutate(Competência.Declarada = ymd(paste0(Competência.Declarada,"01")))

# Traduz códigos de situação (admissão/desligamento)
saldomov <- data.frame(situacao=c("ADMISSAO","DESLIGAMENTO"),
                       Admitidos.Desligados=c(1,2)
)

# Substitui 1 por "ADMISSAO" e 2 por "DESLIGAMENTO"
Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED,saldomov,by='Admitidos.Desligados') %>% 
  mutate(Admitidos.Desligados= situacao) %>% 
  dplyr::select(-situacao)

# Baixando dicionário de dados do CAGED para traduzir códigos
url2 <- "https://github.com/machadotm/Dados_MTE_Arqueo/raw/refs/heads/main/CAGED/1-CAGED/Dicionario_Dados/CAGED_layout_Atualizado.xls"
tmp <- tempfile(fileext = ".xls") # Cria arquivo temporário
GET(url2, write_disk(tmp))  # Baixa o arquivo

# Traduz códigos de municípios para nomes de cidades
municipios <- read_excel(tmp, 
                         sheet = "municipio") %>% 
  separate(Município, into = c("Município", "Descrição"), sep = ":")  # Separa código do nome
  
municipios$Município <- as.numeric(municipios$Município)  # Converte para número

# Substitui códigos de município por nomes
Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, municipios, by = 'Município') %>% 
  mutate(Município = Descrição) %>% 
  dplyr::select(-Descrição)

# Reorganiza colunas: coloca Ano.Declarado antes de Admitidos.Desligados
Dados_Arqueo_CAGED <- Dados_Arqueo_CAGED %>% 
  relocate(Ano.Declarado, .before = Admitidos.Desligados)

# Traduz códigos CNAE 1.0 (Classificação de atividades econômicas antiga)
classe1.0 <- read_excel(tmp, 
                         sheet = "classe 10") %>% 
  separate(`CNAE 1.0 Classe`, into = c("CNAE.1.0.Classe", "Descrição"), sep = ":")


Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, classe1.0, by = 'CNAE.1.0.Classe') %>% 
  mutate(CNAE.1.0.Classe = Descrição) %>% 
  dplyr::select(-Descrição)

# Traduz códigos CNAE 2.0 (Classificação de atividades econômicas atual)
classe2.0 <- read_excel(tmp, 
                        sheet = "classe 20") %>% 
  separate(`CNAE 2.0 Classe`, into = c("CNAE.2.0.Classe", "Descrição"), sep = ":")

classe2.0$CNAE.2.0.Classe <- as.numeric(classe2.0$CNAE.2.0.Classe)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, classe2.0, by = 'CNAE.2.0.Classe') %>% 
  mutate(CNAE.2.0.Classe = Descrição) %>% 
  dplyr::select(-Descrição)

# Traduz subclasses CNAE 2.0 (mais detalhada)
sub.classe2.0 <- read_excel(tmp, 
                        sheet = "subclasse") %>% 
  separate(`CNAE 2.0 Subclas`, into = c("CNAE.2.0.Subclas", "Descrição"), sep = ":")

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, sub.classe2.0, by = 'CNAE.2.0.Subclas') %>% 
  mutate(CNAE.2.0.Subclas = Descrição) %>% 
  dplyr::select(-Descrição)

# Traduz faixas de tamanho de empresa no início de janeiro
fx.emp.jan <- data.frame(tamanho=c(
  "ATE 4", "DE 5 A 9", "DE 10 A 19", "DE 20 A 49", "DE 50 A 99", "DE 100 A 249", "DE 250 A 499", "DE 500 A 999",
  "1000 OU MAIS", "IGNORADO"),
  Faixa.Empr.Início.Jan=c(1,2,3,4,5,6,7,8,9,-1))

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, fx.emp.jan, by = 'Faixa.Empr.Início.Jan') %>% 
  mutate(Faixa.Empr.Início.Jan = tamanho) %>% 
  dplyr::select(-tamanho)

# Traduz graus de instrução (escolaridade)
grau.inst <- data.frame(escolaridade=c(
  "Analfabeto","Até 5ª Incompleto","5ª Completo Fundamental","6ª a 9ª Fundamental","Fundamental Completo",
  "Médio Incompleto", "Médio Completo", "Superior Incompleto", "Superior Completo", "MESTRADO","DOUTORADO", "IGNORADO"),
  Grau.Instrução=c(1,2,3,4,5,6,7,8,9,10,11,-1))

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, grau.inst, by = 'Grau.Instrução') %>% 
  mutate(Grau.Instrução = escolaridade) %>% 
  dplyr::select(-escolaridade)

# Traduz subsetores do IBGE (áreas da economia)
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
    18,    19,    20,    21,    22,    23,    24,    25,    -1))

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, ibge.subs.df, by= "IBGE.Subsetor") %>% 
  mutate(IBGE.Subsetor = subsetor) %>%
  dplyr::select(-subsetor)

# Traduz indicador de aprendiz (jovem aprendiz)
ind.aprendiz <- data.frame(Descrição=c("SIM","NÃO"),
                           Ind.Aprendiz=c(1,0))

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, ind.aprendiz, by = 'Ind.Aprendiz') %>% 
  mutate(Ind.Aprendiz = Descrição) %>% 
  dplyr::select(-Descrição)

# Traduz indicador de portador de deficiência
ind.def <- data.frame(Descrição=c("SIM","NÃO"),
                      Ind.Portador.Defic=c(1,0))

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, ind.def, by = 'Ind.Portador.Defic') %>% 
  mutate(Ind.Portador.Defic = Descrição) %>% 
  dplyr::select(-Descrição)

# Traduz raça/cor
raca.df <- data.frame(cor=c(
  "INDIGENA",  "BRANCA",  "PRETA",  "AMARELA",  "PARDA",  "NAO IDENT","IGNORADO"),
  Raça.Cor=c( 1,    2,    4,    6,    8,    9,    -1))

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, raca.df, by= "Raça.Cor") %>% 
  mutate(Raça.Cor = cor) %>%
  dplyr::select(-cor)

# Traduz saldo de movimento (positivo para admissão, negativo para desligamento)
saldomov2 <- data.frame(situacao=c("Admissão","Desligamento"),
                        Saldo.Mov=c(1,-1)
)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED,saldomov2,by='Saldo.Mov') %>% 
  mutate(Saldo.Mov= situacao) %>% 
  dplyr::select(-situacao)

# Traduz sexo
sexo <- data.frame(Descrição=c(  "MASCULINO",  "FEMININO",  "IGNORADO"),
                   Sexo=c( 1, 2, -1))

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, sexo, by= "Sexo") %>% 
  mutate(Sexo = Descrição) %>%
  dplyr::select(-Descrição)

# Traduz tipo de estabelecimento (CNPJ, CEI, etc.)
tipo.estb.df <- data.frame(tipo.estb=c("CNPJ", "CEI", "NAO IDENTIF","IGNORADO"),
                           Tipo.Estab=c( 1,  3,  9,  -1))

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, tipo.estb.df, by= "Tipo.Estab") %>% 
  mutate(Tipo.Estab = tipo.estb) %>%
  dplyr::select(-tipo.estb)

# Traduz tipo de deficiência
tipo.defc.df <- data.frame(deficiencia=c(
  "FISICA", "AUDITIVA", "VISUAL", "Intelectual (Mental)", "MULTIPLA", "REABILITADO","NAO DEFIC","IGNORADO"),
  Tipo.Defic=c(1,    2,    3,    4,    5,    6,    0,    -1))

tipo.defc.df$Tipo.Defic <- as.character(tipo.defc.df$Tipo.Defic)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, tipo.defc.df, by= "Tipo.Defic") %>% 
  mutate(Tipo.Defic = deficiencia) %>%
  dplyr::select(-deficiencia)

# Traduz tipo de movimento desagregado (detalhado)
tipo.mov.desag <- data.frame(Descrição=c(
  "Admissão por Primeiro Emprego","Admissão por Reemprego","Admissão por Transferência",
  "Desligamento por Demissão sem Justa Causa","Desligamento por Demissão com Justa Causa","Desligamento a Pedido",
  "Desligamento por Aposentadoria","Desligamento por Morte","Desligamento por Transferência",
  "Admissão por Reintegraçao","Desligamento por Término de Contrato","Contrato Trabalho Prazo Determinado",
  "Término Contrato Trabalho Prazo Determinado","Desliamento por Acordo Empregado e Empregador","IGNORADO"),
  Tipo.Mov.Desagregado=c(1,2,3,4,5,6,7,8,9,10,11,25,43,90,-1)
  )

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, tipo.mov.desag, by= "Tipo.Mov.Desagregado") %>% 
  mutate(Tipo.Mov.Desagregado = Descrição) %>%
  dplyr::select(-Descrição)

# Baixando novo dicionário do CAGED atualizado
url3 <- "https://github.com/machadotm/Dados_MTE_Arqueo/raw/refs/heads/main/CAGED/3-Novo_Caged/Dicionario_Dados/Layout_Novo_Caged.xlsx"
tmp2 <- tempfile(fileext = ".xlsx")
GET(url3, write_disk(tmp2))

# Traduz códigos de UF (Unidades Federativas) para nomes de estados
uf <- read_excel(tmp2, 
                 sheet = "uf") %>% 
  rename(UF= Código)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, uf, by= "UF") %>% 
  mutate(UF = Descrição) %>%
  dplyr::select(-Descrição)

# ... continua com traduções de regiões administrativas, bairros, etc.

bairroSP <- read_excel(tmp, 
                       sheet = "BAIRRO_SP")%>% 
  setNames(.[1, ])%>% 
  slice(-1) %>% 
  rename(Bairros.SP = `Valor na Fonte`) %>% 
  dplyr::select(-1)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, bairroSP, by= "Bairros.SP") %>% 
  mutate(Bairros.SP = Descrição) %>%
  dplyr::select(-Descrição)

bairroFort <- read_excel(tmp, 
                         sheet = "BAIRRO FORT")%>% 
  setNames(.[1, ])%>% 
  slice(-1) %>% 
  rename(Bairros.Fortaleza = `Valor na Fonte`) %>% 
  dplyr::select(-1)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, bairroFort, by= "Bairros.Fortaleza") %>% 
  mutate(Bairros.Fortaleza = Descrição) %>%
  dplyr::select(-Descrição)

bairroRJ <- read_excel(tmp, 
                       sheet = "BAIRRO_RJ") %>% 
  setNames(.[1, ])%>% 
  slice(-1) %>% 
  rename(Bairros.RJ = `Valor na Fonte`) %>% 
  dplyr::select(-1)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, bairroRJ, by= "Bairros.RJ") %>% 
  mutate(Bairros.RJ = Descrição) %>%
  dplyr::select(-Descrição)

distritoSP <- read_excel(tmp, 
                         sheet = "Distrito SP")

distritoSP <- rbind(names(distritoSP),distritoSP) %>% 
  rename(Distritos.SP = 0001,
         Descrição = `A RASA`)

distritoSP$Distritos.SP <- as.numeric(distritoSP$Distritos.SP)

Dados_Arqueo_CAGED$Distritos.SP <- as.numeric(Dados_Arqueo_CAGED$Distritos.SP)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, distritoSP, by= "Distritos.SP") %>% 
  mutate(Distritos.SP = Descrição) %>%
  dplyr::select(-Descrição)

regAdmDF <- read_excel(tmp, 
                       sheet = "REG ADM DF") %>% 
  rename(Regiões.Adm.DF = `regioes administrativas DF`,
         Descrição = ...2)

regAdmDF$Regiões.Adm.DF <- as.numeric(regAdmDF$Regiões.Adm.DF)

Dados_Arqueo_CAGED$Regiões.Adm.DF <- as.numeric(Dados_Arqueo_CAGED$Regiões.Adm.DF)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, regAdmDF, by= "Regiões.Adm.DF") %>% 
  mutate(Regiões.Adm.DF = Descrição) %>%
  dplyr::select(-Descrição)

regiões <- read_excel(tmp, 
                       sheet = "outros")

mesoreg<- read_excel(tmp, 
                     sheet = "outros") %>% 
  separate(Mesorregião, into = c("Mesorregião", "Descrição"), sep = ":") %>% 
  dplyr::select(1:2)%>% 
  na.omit()

mesoreg$Mesorregião <- as.numeric(mesoreg$Mesorregião)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, mesoreg, by= "Mesorregião") %>% 
  mutate(Mesorregião = Descrição) %>%
  dplyr::select(-Descrição)

microreg<- read_excel(tmp, 
                     sheet = "outros") %>% 
  separate(Microrregião, into = c("Microrregião", "Descrição"), sep = ":") %>% 
  dplyr::select(3:4)%>% 
  na.omit()

microreg$Microrregião <- as.numeric(microreg$Microrregião)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, microreg, by= "Microrregião") %>% 
  mutate(Microrregião = Descrição) %>%
  dplyr::select(-Descrição)


reg.adm.rj <- read_excel(tmp, 
                      sheet = "outros") %>% 
  separate(`Reg adm RJ`, into = c("Região.Adm.RJ", "Descrição"), sep = ":") %>% 
  dplyr::select(5:6) %>% 
  na.omit()

reg.adm.rj$Região.Adm.RJ <- as.numeric(reg.adm.rj$Região.Adm.RJ)

Dados_Arqueo_CAGED$Região.Adm.RJ <- as.numeric(Dados_Arqueo_CAGED$Região.Adm.RJ)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, reg.adm.rj, by= "Região.Adm.RJ") %>% 
  mutate(Região.Adm.RJ = Descrição) %>%
  dplyr::select(-Descrição)

reg.adm.sp <- read_excel(tmp, 
                         sheet = "outros") %>% 
  separate(`Reg adm SP`, into = c("Região.Adm.SP", "Descrição"), sep = ":") %>% 
  dplyr::select(7:8) %>% 
  na.omit()

reg.adm.sp$Região.Adm.SP <- as.numeric(reg.adm.sp$Região.Adm.SP)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, reg.adm.sp, by= "Região.Adm.SP") %>% 
  mutate(Região.Adm.SP = Descrição) %>%
  dplyr::select(-Descrição)

reg.gov.sp <- read_excel(tmp, 
                         sheet = "outros") %>% 
  separate(`Região Gov SP`, into = c("Região.Gov.SP", "Descrição"), sep = ":") %>% 
  dplyr::select(9:10) %>% 
  na.omit()

reg.gov.sp$Região.Gov.SP <- as.numeric(reg.gov.sp$Região.Gov.SP)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, reg.gov.sp, by= "Região.Gov.SP") %>% 
  mutate(Região.Gov.SP = Descrição) %>%
  dplyr::select(-Descrição)

reg.senai.sp <- read_excel(tmp, 
                         sheet = "outros") %>% 
  separate(`Região Senai SP`, into = c("Região.Senai.SP", "Descrição"), sep = ":") %>% 
  dplyr::select(11:12) %>% 
  na.omit()

reg.senai.sp$Região.Senai.SP<- as.numeric(reg.senai.sp$Região.Senai.SP)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, reg.senai.sp, by= "Região.Senai.SP") %>% 
  mutate(Região.Senai.SP = Descrição) %>%
  dplyr::select(-Descrição)

reg.senac.pr <- read_excel(tmp, 
                           sheet = "outros") %>% 
  separate(`Região SenaC PR`, into = c("Região.Senac.PR", "Descrição"), sep = ":") %>% 
  dplyr::select(13:14) %>% 
  na.omit()

reg.senac.pr$Região.Senac.PR<- as.numeric(reg.senac.pr$Região.Senac.PR)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, reg.senac.pr, by= "Região.Senac.PR") %>% 
  mutate(Região.Senac.PR = Descrição) %>%
  dplyr::select(-Descrição)

reg.senai.pr <- read_excel(tmp, 
                           sheet = "outros") %>% 
  separate(`Região Senai PR`, into = c("Região.Senai.PR", "Descrição"), sep = ":") %>% 
  dplyr::select(Região.Senai.PR, Descrição) %>% 
  na.omit()

reg.senai.pr$Região.Senai.PR<- as.numeric(reg.senai.pr$Região.Senai.PR)

Dados_Arqueo_CAGED$Região.Senai.PR <- as.numeric(Dados_Arqueo_CAGED$Região.Senai.PR)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, reg.senai.pr, by= "Região.Senai.PR") %>% 
  mutate(Região.Senai.PR = Descrição) %>%
  dplyr::select(-Descrição)

sub.reg.senai.pr <- read_excel(tmp, 
                           sheet = "outros") %>% 
  separate(`Sub-Região Senai PR`, into = c("Sub.Região.Senai.PR", "Descrição"), sep = ":") %>% 
  dplyr::select(Sub.Região.Senai.PR, Descrição) %>% 
  na.omit()

sub.reg.senai.pr$Sub.Região.Senai.PR<- as.numeric(sub.reg.senai.pr$Sub.Região.Senai.PR)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, sub.reg.senai.pr, by= "Sub.Região.Senai.PR") %>% 
  mutate(Sub.Região.Senai.PR = Descrição) %>%
  dplyr::select(-Descrição)

reg.corede04 <- read_excel(tmp, 
                               sheet = "outros") %>% 
  separate(`Região Corede 04`, into = c("Região.Corede.04", "Descrição"), sep = ":") %>% 
  dplyr::select(Região.Corede.04, Descrição) %>% 
  na.omit()

reg.corede04$Região.Corede.04<- as.numeric(reg.corede04$Região.Corede.04)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, reg.corede04, by= "Região.Corede.04") %>% 
  mutate(Região.Corede.04 = Descrição) %>%
  dplyr::select(-Descrição)

reg.corede <- read_excel(tmp, 
                           sheet = "outros") %>% 
  separate(`Região Corede`, into = c("Região.Corede", "Descrição"), sep = ":") %>% 
  dplyr::select(Região.Corede, Descrição) %>% 
  na.omit()

reg.corede$Região.Corede<- as.numeric(reg.corede$Região.Corede)

Dados_Arqueo_CAGED$Região.Corede <- as.numeric(Dados_Arqueo_CAGED$Região.Corede)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, reg.corede, by= "Região.Corede") %>% 
  mutate(Região.Corede = Descrição) %>%
  dplyr::select(-Descrição)

indtrabinter <- read_excel(tmp2, 
                           sheet = "indtrabintermitente") %>% 
  rename(Ind.Trab.Intermitente= Código)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, indtrabinter, by = 'Ind.Trab.Intermitente') %>% 
  mutate(Ind.Trab.Intermitente = Descrição) %>% 
  dplyr::select(-Descrição)

indtrabparcial <- read_excel(tmp2, 
                             sheet = "indtrabparcial") %>% 
  rename(Ind.Trab.Parcial= Código)

Dados_Arqueo_CAGED <- left_join(Dados_Arqueo_CAGED, indtrabparcial, by = 'Ind.Trab.Parcial') %>% 
  mutate(Ind.Trab.Parcial = Descrição) %>% 
  dplyr::select(-Descrição)


# SALVANDO OS RESULTADOS FINAIS

# Cria um arquivo Excel com os dados tratados
wb <- createWorkbook()  # Cria um novo arquivo Excel
nome_da_aba <- "Resultado CAGED"
addWorksheet(wb, nome_da_aba)  # Adiciona uma planilha
writeData(wb, sheet = nome_da_aba, x = Dados_Arqueo_CAGED, withFilter = TRUE)  # Escreve os dados
setColWidths(wb, sheet = nome_da_aba, cols = 1:ncol(Dados_Arqueo_CAGED), widths = "auto")  # Ajusta larguras
saveWorkbook(wb, "CAGED_2007-2019_Arqueo_Dados_Tratados.xlsx", overwrite = TRUE)  # Salva o arquivo


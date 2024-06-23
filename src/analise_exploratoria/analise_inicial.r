data <- read.csv("data/personagens_mod.csv", header = TRUE)
summary(data)

data$Numero_de_capitulos_ate_o_volume <- NULL
data$Distancia_da_Primeira_Aparicao_em_capitulo <- NULL

model <- glm(Esta_na_Capa ~ Grupo + Porcentagem_de_Capitulos_do_Volume, data = data, family = binomial)
summary(model)
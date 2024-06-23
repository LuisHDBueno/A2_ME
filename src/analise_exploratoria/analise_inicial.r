data <- read.csv("data/personagens_mod.csv", header = TRUE)
summary(data)

set.seed(123)  # Define uma semente aleatória para reprodução
index_train <- sample(1:nrow(data), 4000)
data_train <- data[index_train, ]
data_test <- data[-index_train, ]

data$Numero_de_capitulos_ate_o_volume <- NULL
data$Distancia_da_Primeira_Aparicao_em_capitulo <- NULL

modelIntercept <- glm(Esta_na_Capa ~ 1, data = data_train, family = binomial)
summary(modelIntercept)
# Matriz de confusão treino
pred <- predict(modelIntercept, newdata = data_test, type = "response")
pred <- ifelse(pred > 0.5, 1, 0)
table(data_test$Esta_na_Capa, pred)

model1 <- glm(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume, data = data_train, family = binomial)
summary(model1)
# Matriz de confusão treino
pred <- predict(model1, newdata = data_test, type = "response")
pred <- ifelse(pred > 0.5, 1, 0)
table(data_test$Esta_na_Capa, pred)


model2 <- glm(Esta_na_Capa ~ Grupo + Porcentagem_de_Capitulos_do_Volume + Primeiro_Capitulo + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga, data = data_train, family = binomial)
summary(model2)

# Matriz de confusão
pred <- predict(model2, newdata = data_test, type = "response")
pred <- ifelse(pred > 0.5, 1, 0)
# Tamanho da resposta
length(pred)
# Tamanho da resposta esperada
length(data_test$Esta_na_Capa)
table(data_test$Esta_na_Capa, pred)


model3 <- glm(Esta_na_Capa ~ Grupo + Primeiro_Capitulo + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga, data = data_train, family = binomial)
summary(model3)

# Matriz de confusão
pred <- predict(model3, newdata = data_test, type = "response")
pred <- ifelse(pred > 0.5, 1, 0)
table(data_test$Esta_na_Capa, pred)

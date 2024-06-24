library(lme4)
data <- read.csv("data/personagens_mod.csv", header = TRUE)
summary(data)

#Remover colunas que não serão utilizadas
data$Distancia_da_Primeira_Aparicao_em_capitulos <- NULL


set.seed(123)  # Define uma semente aleatória para reprodução
index_train <- sample(1:nrow(data), 4000)
data_train <- data[index_train, ]
data_test <- data[-index_train, ]

model1 <- glm(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Grupo + Primeiro_Capitulo 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga,
              data = data_train, family = binomial)

summary(model1)

model2 <- glm(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga,
              data = data_train, family = binomial)
summary(model2)

model3 <- glmer(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga
              + (1|Protagonista), data = data_train, family = binomial)
summary(model3)

model4 <- glm(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga
              + Protagonista + Protagonista * Porcentagem_de_Capitulos_do_Volume,
              data = data_train, family = binomial)
summary(model4)

#Matriz de confusão modelo 1
pred <- predict(model1, newdata = data_test, type = "response")
pred <- ifelse(pred > 0.5, 1, 0)
table <- table(data_test$Esta_na_Capa, pred)
table

#Matriz de confusão modelo 2
pred <- predict(model2, newdata = data_test, type = "response")
pred <- ifelse(pred > 0.5, 1, 0)
table(data_test$Esta_na_Capa, pred)

#Matriz de confusão modelo 3
pred <- predict(model3, newdata = data_test, type = "response")
pred <- ifelse(pred > 0.5, 1, 0)
table(data_test$Esta_na_Capa, pred)

#Matriz de confusão modelo 4
pred <- predict(model4, newdata = data_test, type = "response")
pred <- ifelse(pred > 0.5, 1, 0)
table(data_test$Esta_na_Capa, pred)

#Curva ROC
install.packages("pROC")
library(pROC)
roc1 <- roc(data_test$Esta_na_Capa, predict(model1, newdata = data_test, type = "response"))
roc2 <- roc(data_test$Esta_na_Capa, predict(model2, newdata = data_test, type = "response"))
roc3 <- roc(data_test$Esta_na_Capa, predict(model3, newdata = data_test, type = "response"))
roc4 <- roc(data_test$Esta_na_Capa, predict(model4, newdata = data_test, type = "response"))

plot(roc1, col = "red")
plot(roc2, col = "blue", add = TRUE)
plot(roc3, col = "green", add = TRUE)
plot(roc4, col = "yellow", add = TRUE)


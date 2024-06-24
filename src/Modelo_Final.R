library(lme4)
data <- read.csv("data/personagens_mod.csv", header = TRUE)
summary(data)

# Remover dados de protagonista
data = data[data$Protagonista == 0,]
data$Protagonista <- NULL

#Remover colunas que não serão utilizadas
data$Distancia_da_Primeira_Aparicao_em_capitulos <- NULL

set.seed(123)  # Define uma semente aleatória para reprodução
index_train <- sample(1:nrow(data), 4000)
data_train <- data[index_train, ]
data_test <- data[-index_train, ]

model <- glmer(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
                + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga + 
                  Distancia_da_Primeira_Aparicao_em_volumes + 
                  (1|Grupo), data = data_train, family = binomial)


metrics <- function(table) {
  TP <- table[2, 2]
  TN <- table[1, 1]
  FP <- table[1, 2]
  FN <- table[2, 1]
  
  precision <- ifelse((TP + FP) == 0, NA, TP / (TP + FP))
  recall <- ifelse((TP + FN) == 0, NA, TP / (TP + FN))
  f1_score <- ifelse((precision + recall) == 0, NA, 2 * precision * recall / (precision + recall))
  accuracy <- (TP + TN) / (TP + TN + FP + FN)
  specificity <- ifelse((TN + FP) == 0, NA, TN / (TN + FP))
  
  return(c(precision = precision, recall = recall, f1_score = f1_score, accuracy = accuracy, specificity = specificity))
}

# Função para criar uma tabela 2x2
create_2x2_table <- function(real, pred) {
  table_2x2 <- matrix(0, nrow = 2, ncol = 2, 
                      dimnames = list("Real" = c("0", "1"), "Pred" = c("0", "1")))
  contingency_table <- table(real, pred)
  for (i in 1:nrow(contingency_table)) {
    for (j in 1:ncol(contingency_table)) {
      table_2x2[as.character(rownames(contingency_table)[i]), 
                as.character(colnames(contingency_table)[j])] <- contingency_table[i, j]
    }
  }
  return(table_2x2)
}

summary(model)
# Metricas de avaliação threshold 0.16
threshold <- 0.16
pred <- predict(model, data_test, type = "response")
pred <- ifelse(pred > threshold, 1, 0)
table_2x2 <- create_2x2_table(data_test$Esta_na_Capa, pred)
print(table_2x2)
metrics(table_2x2)



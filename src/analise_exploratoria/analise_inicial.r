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

model2 <- glm(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga,
              data = data_train, family = binomial)

model3 <- glmer(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga + 
              (1|Protagonista), data = data_train, family = binomial)

model4 <- glmer(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga + 
              (1|Grupo), data = data_train, family = binomial)

model5 <- glm(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga + 
                Distancia_da_Primeira_Aparicao_em_volumes, data = data_train, family = binomial)

model6 <- glm(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga + 
                Distancia_da_Primeira_Aparicao_em_volumes + 
                Numero_de_capitulos_ate_o_volume, data = data_train, family = binomial)

model7 <- glmer(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
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

# ajuste nos modelos
thresholds <- seq(0, 1, 0.01)
models <- list(model1, model2, model3, model4, model5, model6, model7)
results <- list()

for (i in 1:length(models)) {
  model_results <- data.frame(threshold = thresholds, precision = numeric(length(thresholds)), 
                              recall = numeric(length(thresholds)), f1_score = numeric(length(thresholds)), 
                              accuracy = numeric(length(thresholds)), specificity = numeric(length(thresholds)))
  for (j in 1:length(thresholds)) {
    pred <- predict(models[[i]], newdata = data_test, type = "response")
    pred <- ifelse(pred > thresholds[j], 1, 0)
    table_2x2 <- create_2x2_table(data_test$Esta_na_Capa, pred)
    metrics_values <- metrics(table_2x2)
    model_results[j, 2:6] <- metrics_values
  }
  results[[i]] <- model_results
}
# Tabela com os melhores resultados por f1_score e threshold para cada modelo
best_results <- lapply(results, function(res) res[which.max(res$f1_score), ])

# Combinar todos os melhores resultados em um único data frame
combined_results <- do.call(rbind, best_results)

# Adicionar uma coluna com o nome do modelo para identificação
model_names <- c("model1", "model2", "model3", "model4", "model5", "model6", "model7")
combined_results$model <- model_names

# Reordenar as colunas para ter o modelo como a primeira coluna
combined_results <- combined_results[, c(ncol(combined_results), 1:(ncol(combined_results)-1))]

print(combined_results)

# Modelos sem o protagonista
data = data[data$Protagonista == 0,]
data$Protagonista <- NULL

set.seed(123)  # Define uma semente aleatória para reprodução
index_train <- sample(1:nrow(data), 4000)
data_train <- data[index_train, ]
data_test <- data[-index_train, ]


model1 <- glm(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Grupo + Primeiro_Capitulo 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga,
              data = data_train, family = binomial)

model2 <- glm(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga,
              data = data_train, family = binomial)

model4 <- glmer(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
                + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga + 
                  (1|Grupo), data = data_train, family = binomial)

model5 <- glm(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga + 
                Distancia_da_Primeira_Aparicao_em_volumes, data = data_train, family = binomial)

model6 <- glm(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
              + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga + 
                Distancia_da_Primeira_Aparicao_em_volumes + 
                Numero_de_capitulos_ate_o_volume, data = data_train, family = binomial)

model7 <- glmer(Esta_na_Capa ~ Porcentagem_de_Capitulos_do_Volume 
                + Ultimo_Capitulo + E_a_Primeira_Aparicao_no_manga + 
                  Distancia_da_Primeira_Aparicao_em_volumes + 
                  (1|Grupo), data = data_train, family = binomial)

# ajuste nos modelos
thresholds <- seq(0, 1, 0.01)
models <- list(model1, model2, model4, model5, model6, model7)
results <- list()

for (i in 1:length(models)) {
  model_results <- data.frame(threshold = thresholds, precision = numeric(length(thresholds)), 
                              recall = numeric(length(thresholds)), f1_score = numeric(length(thresholds)), 
                              accuracy = numeric(length(thresholds)), specificity = numeric(length(thresholds)))
  for (j in 1:length(thresholds)) {
    pred <- predict(models[[i]], newdata = data_test, type = "response")
    pred <- ifelse(pred > thresholds[j], 1, 0)
    table_2x2 <- create_2x2_table(data_test$Esta_na_Capa, pred)
    metrics_values <- metrics(table_2x2)
    model_results[j, 2:6] <- metrics_values
  }
  results[[i]] <- model_results
}
# Tabela com os melhores resultados por f1_score e threshold para cada modelo
best_results <- lapply(results, function(res) res[which.max(res$f1_score), ])

# Combinar todos os melhores resultados em um único data frame
combined_results <- do.call(rbind, best_results)

# Adicionar uma coluna com o nome do modelo para identificação
model_names <- c("model1", "model2", "model4", "model5", "model6", "model7")
combined_results$model <- model_names

# Reordenar as colunas para ter o modelo como a primeira coluna
combined_results <- combined_results[, c(ncol(combined_results), 1:(ncol(combined_results)-1))]

print(combined_results)

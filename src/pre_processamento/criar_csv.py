import pandas as pd
import json

with open("data/personagens_capa.json", "r", encoding="utf-8") as file:
    personagens_capa = json.load(file)

with open("data/personagens_capitulo_padronizado.json", "r", encoding="utf-8") as file:
    personagens_capitulo = json.load(file)

colunas = ["Esta na Capa",
           "Grupo",
           "Subgrupo",
           "Primeiro Capitulo",
           "Ultimo Capitulo",
           "Porcentagem de Capitulos do Volume",
           "E a Primeira Aparicao no manga",
           "Distancia da Primeira Aparicao em capitulos",
           "Numero total de capitulos que apareceu",
           "Numero de capitulos ate o volume",
           "Nome do Personagem",
           "Volume",
           "Numero de Capitulos no Volume"]

personagens_unicos_capa = []
for volume, conteudo in personagens_capa.items():
    for personagem in conteudo["personagens"]:
        if personagem not in personagens_unicos_capa:
            personagens_unicos_capa.append(personagem)

print("Numero de personagens unicos na capa: ", len(personagens_unicos_capa))

personagens_unicos_por_volume = {}
for volume, conteudo in personagens_capa.items():
    capitulos = conteudo["capitulos"]
    personagens_volume = {}
    for capitulo in capitulos:
        for grupo, subgrupos in personagens_capitulo[capitulo].items():
            for subgrupo in subgrupos:
                subgrupo_nome, personagens = subgrupo
                print(subgrupo_nome, personagens)
                for personagem in personagens:
                    if personagem not in personagens_volume.keys():
                        personagens_volume[personagem] = {
                            "Grupo": grupo,
                            "Subgrupo": subgrupo_nome,
                            "Primeiro Capitulo no Volume": 1 if capitulo == capitulos[0] else 0,
                            "Ultimo Capitulo no Volume": 0,
                            "Numero de Capitulos no Volume": 1,
                            "E a Primeira Aparicao no manga": 0,
                            "Distancia da Primeira Aparicao em volumes": 0,
                            "Numero total de capitulos que apareceu": 1,
                            "Numero de capitulos ate o volume": int(capitulos[0]) - 1
                        }
                        
                    else:
                        personagens_volume[personagem]["Ultimo Capitulo no Volume"] = 1 if capitulo == capitulos[-1] else 0
                        personagens_volume[personagem]["Numero de Capitulos no Volume"] += 1
                        personagens_volume[personagem]["Numero total de capitulos que apareceu"] += 1

    personagens_unicos_por_volume[volume] = personagens_volume

print("Numero de volumes: ", len(personagens_unicos_por_volume))
soma = 0
for volume, personagens in personagens_unicos_por_volume.items():
    soma += len(personagens)
    print("Numero de personagens no volume ", volume, ": ", len(personagens))

print("Numero de personagens unicos por volume: ", soma)

# Criar o dataframe
df = pd.DataFrame(columns=colunas)
for volume, personagens in personagens_unicos_por_volume.items():
    for personagem, conteudo in personagens.items():
        df = df._append({
            "Esta na Capa": 0,
            "Grupo": conteudo["Grupo"],
            "Subgrupo": conteudo["Subgrupo"],
            "Primeiro Capitulo": conteudo["Primeiro Capitulo no Volume"],
            "Ultimo Capitulo": conteudo["Ultimo Capitulo no Volume"],
            "Porcentagem de Capitulos do Volume": 0,
            "E a Primeira Aparicao no manga": conteudo["E a Primeira Aparicao no manga"],
            "Distancia da Primeira Aparicao em volumes": conteudo["Distancia da Primeira Aparicao em volumes"],
            "Numero total de capitulos que apareceu": conteudo["Numero total de capitulos que apareceu"],
            "Numero de capitulos ate o volume": conteudo["Numero de capitulos ate o volume"],
            "Nome do Personagem": personagem,
            "Volume": volume,
            "Numero de Capitulos no Volume": conteudo["Numero de Capitulos no Volume"]
        }, ignore_index=True)

# Consertando E a Primeira Aparicao no manga
df.sort_values(by=["Volume", "Nome do Personagem"], inplace=True)
df.reset_index(drop=True, inplace=True)
for i in range(1, len(df)):
    if df.loc[i, "Nome do Personagem"] == df.loc[i - 1, "Nome do Personagem"]:
        df.loc[i, "E a Primeira Aparicao no manga"] = 0
        df.loc[i, "Distancia da Primeira Aparicao em volumes"] = df.loc[i, "Volume_num"] - df.loc[i - 1, "Volume_num"]
    else:
        df.loc[i, "E a Primeira Aparicao no manga"] = 1
        df.loc[i, "Distancia da Primeira Aparicao em volumes"] = 0

soma = 0
for volume, conteudo in personagens_capa.items():
    personagens_volume = personagens_unicos_por_volume[volume].keys()
    n_personagens = len(conteudo["personagens"])
    n_capitulos = len(conteudo["capitulos"])
    df_volume = df[df["Volume"] == volume]
    for personagem in personagens_volume:
        soma += 1
        df.loc[(df["Volume"] == volume) & (df["Nome do Personagem"] == personagem), "Esta na Capa"] = 1 if personagem in conteudo["personagens"] else 0
        df.loc[(df["Volume"] == volume) & (df["Nome do Personagem"] == personagem), "Porcentagem de Capitulos do Volume"] \
            = df_volume.loc[df_volume["Nome do Personagem"] == personagem, "Numero de Capitulos no Volume"] / n_capitulos
        
# duas casas decimais
df["Porcentagem de Capitulos do Volume"] = df["Porcentagem de Capitulos do Volume"].apply(lambda x: round(x, 2))

df.sort_values(by=["Volume"], inplace=True)
df["Volume_num"] = df["Volume"].str.extract('Volume_(\d+)').astype(int)
for personagem in df["Nome do Personagem"].unique():
    df_personagem = df[df["Nome do Personagem"] == personagem]
    # primeira linha é a primeira aparição
    df.loc[df_personagem.index[0], "E a Primeira Aparicao no manga"] = 1
    df.loc[df_personagem.index[0], "Distancia da Primeira Aparicao em volumes"] = 0
    #outros nao é a primeira aparição
    df.loc[df_personagem.index[1:], "E a Primeira Aparicao no manga"] = 0
    df.loc[df_personagem.index[1:], "Distancia da Primeira Aparicao em volumes"] = df_personagem["Volume_num"] - df_personagem["Volume_num"].min()


print("Numero de personagens na capa: ", soma)
print(df["Esta na Capa"].value_counts())
print(df["E a Primeira Aparicao no manga"].value_counts())

# Troque os espacos por _ nas colunas
df.columns = df.columns.str.replace(" ", "_")

df.to_csv("data/personagens.csv", index=False)


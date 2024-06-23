import json
import re

with open("data/personagens_capa.json", "r", encoding="utf-8") as file:
    personagens_capa = json.load(file)

with open("data/personagens_capitulo_padronizado.json", "r", encoding="utf-8") as file:
    personagens_capitulo = json.load(file)

lista_personagens_capa = []
for volume, conteudo in personagens_capa.items():
    for personagem in conteudo["personagens"]:
        lista_personagens_capa.append(personagem)

lista_personagens_capitulo = []
for capitulo, conteudo in personagens_capitulo.items():
    for grupo, subgrupos in conteudo.items():
        for subgrupo in subgrupos:
            personagens_capitulo = subgrupo[1]
            for personagem in personagens_capitulo:
                lista_personagens_capitulo.append(personagem)

for personagem in lista_personagens_capa:
    if personagem not in lista_personagens_capitulo:
        print(personagem)
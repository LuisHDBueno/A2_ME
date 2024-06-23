import json
import re

with open("data/personagens_capitulo.json", "r", encoding="utf-8") as file:
    personagens = json.load(file)

for capitulo, conteudo in personagens.items():
    for grupo, subgrupos in conteudo.items():
        for subgrupo in subgrupos:
            nome_subgrupo = subgrupo[0]
            personagens_capitulo = subgrupo[1]
            for i, personagem in enumerate(personagens_capitulo):
                nome = personagem
                nome = re.sub(r"\s+", " ", nome)
                # retira tudo que está em ()
                nome = re.sub(r"\(.*?\)", "", nome)
                nome = nome.strip()
                personagens_capitulo[i] = nome

with open("data/personagens_capitulo_padronizado.json", "w", encoding="utf-8") as file:
    json.dump(personagens, file, indent=4, ensure_ascii=False)
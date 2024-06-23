from bs4 import BeautifulSoup as bs
import requests
import re
import json

link = "https://onepiece.fandom.com/wiki/Chapter_"
capitulos = list(range(1, 932))

def get_characters(table):
    header, body = table.find_all('tr')
    header = header.find_all('th')
    header = [[h.text.strip(), h.get("colspan", 1)] for h in header]
    groups = body.find_all('td')
    groups_characters = []
    for group in groups:
        try:
            group_name = group.find("dl").text
            group_name = group_name.strip()
        except:
            group_name = "Others"
        group_characters = group.find_all("li")
        characters = []
        for character in group_characters:
            character = character.text
            character = re.sub(r"\[.*\]", "", character)
            character = character.strip()
            characters.append(character)
        groups_characters.append([group_name, characters])
    characters = {}
    key = 0
    for h, colspan in header:
        characters[h] = []
        for i in range(int(colspan)):
            characters[h].append(groups_characters[key])
            key += 1
    return characters

characters_volume = {}
erros = []
for capitulo in capitulos:
    site = requests.get(link + str(capitulo))
    site = site.text.encode('utf-8').decode('utf-8')
    soup = bs(site, 'html.parser')
    table = soup.find(class_ = "CharTable")
    try:
        characters = get_characters(table)
        print(f"Capítulo {capitulo} extraído")
        print(characters)
        characters_volume[capitulo] = characters
    except:
        print(f"Capítulo {capitulo} sem personagens")
        erros.append(capitulo)
    
with open("personagens_capitulo.json", "w") as file:
    json.dump(characters_volume, file, indent = 4)

with open("erros_capitulo.json", "w") as file:
    json.dump(erros, file, indent = 4)
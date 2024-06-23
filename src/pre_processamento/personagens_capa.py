from bs4 import BeautifulSoup as bs
import requests
import re
import json

def pegar_volume_tabela_except(soup, volume):
    tabelas = soup.find_all("table")
    for tabela in tabelas:
        if (f"Volume {volume}" in tabela.text) and ("Volume 0" not in tabela.text):
            break
    return tabela


def pegar_personagens(volume_tabela):
    tabelas = volume_tabela.find_all('td')
    for tabela in tabelas:
        if ("Personagens da Capa(s)" in tabela.text) and ("Capítulos" not in tabela.text):
            break
    try:
        tabela = tabela.find("ul")
        tabela = tabela.find_all("li")
    except:
        return []
    personagens = []
    for personagem in tabela:
        personagem = personagem.text
        personagem = re.sub(r"\[.*\]", "", personagem)
        personagem = personagem.strip()
        personagens.append(personagem)
    return personagens

def pegar_capitulos(volume_tabela):
    tabelas = volume_tabela.find_all('td')
    for tabela in tabelas:
        if ("Capítulos" in tabela.text) and ("Personagens da Capa(s)" not in tabela.text):
            break
    try:
        tabela = tabela.find("ul")
        tabela = tabela.find_all("li")
    except:
        return []
    capitulos = []
    for capitulo in tabela:
        #pegar title da tag a
        try:
            capitulo = capitulo.find("a")["title"]
        except TypeError:
            continue
        capitulo = re.sub(r"\[.*\]", "", capitulo)
        capitulo = capitulo.strip()
        capitulo = re.sub(r"Capítulo ", "", capitulo)
        capitulos.append(capitulo)
    return capitulos

link = "https://onepiece.fandom.com/pt/wiki/Lista_de_Capítulos_e_Volumes/Volumes"
volumes = list(range(1, 93))

site = requests.get(link)
site = site.text.encode('utf-8').decode('utf-8')

soup = bs(site, 'html.parser')

volumes_dict = dict()
personagens = str()
for volume in volumes:
    try:
        #selecionar id do volume
        id_volume = f"Volume_{volume}"
        volume_tabela = soup.find(id=id_volume)
        #selecionar personagens da capa
        personagens = pegar_personagens(volume_tabela)
        #selecionar capitulos
        capitulos = pegar_capitulos(volume_tabela)
    except:
        volume_tabela = pegar_volume_tabela_except(soup, volume)
        personagens = pegar_personagens(volume_tabela)
        capitulos = pegar_capitulos(volume_tabela)
    finally:
        volumes_dict[id_volume] = {"personagens": personagens,
                                    "capitulos": capitulos}

#salvar em json
with open('data/personagens_capa.json', 'w', ) as json_file:
    json.dump(volumes_dict, json_file, indent=4)
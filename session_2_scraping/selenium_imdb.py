# session 2 - version selenium
# ici je vais utiliser selenium pour charger la page imdb comme un vrai navigateur

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options

# je prépare les options du navigateur
chrome_options = Options()
chrome_options.add_argument("--start-maximized")

# je précise où se trouve chromedriver
service = Service("/usr/local/bin/chromedriver")

# je lance chrome
driver = webdriver.Chrome(service=service, options=chrome_options)

# j'ouvre la page imdb
driver.get("https://www.imdb.com/chart/top/")

print("page ouverte")

import csv
from selenium.webdriver.common.by import By

# je récupère les blocs des films
films_elements = driver.find_elements(By.XPATH, "//li[contains(@class, 'ipc-metadata-list-summary-item')]")

films = []

for film in films_elements[:10]:
    try:
        # je récupère le classement (ex: #1)
        rank = film.find_element(By.XPATH, ".//div[contains(@data-testid, 'title-list-item-ranking')]").text
        
        # je récupère le titre
        titre = film.find_element(By.XPATH, ".//h3").text.split(" ", 1)[1]
        
        # je récupère toutes les infos metadata du film
        metadata = film.find_elements(By.XPATH, ".//span[contains(@class, 'cli-title-metadata-item')]")
        annee = metadata[0].text if len(metadata) > 0 else ""
        
        # ici je cible la vraie note seulement, sans le nombre de votes
        note = film.find_element(By.XPATH, ".//span[contains(@class, 'ipc-rating-star--rating')]").text.replace(",", ".")
        films.append([rank, titre, annee, note])
    
    except Exception as e:
        print("film ignoré :", e)

# j'enregistre le résultat dans un csv propre
with open("films.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["Classement", "Titre", "Année", "Note"])
    writer.writerows(films)

print("CSV créé ")

input("appuie sur entrée pour fermer le navigateur...")
driver.quit()
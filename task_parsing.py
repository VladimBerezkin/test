import requests
import bs4

site = requests.get('https://yandex.ru/')   #создаем подключение
html = bs4.BeautifulSoup(site.text, "html.parser")  #получаем html
output = open("yandex_news.txt", "wb")      
news = html.select('.list__item-content')   #собираем нужные объекты с помощью селектора
for i in range(len(news)):
    line = news[i].getText() + "\n"         #извлекаем текст
    output.write(line.encode('utf-8'))      
output.close()

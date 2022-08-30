import re
from weakref import WeakSet
import requests
import csv

REQUEST_URL = "http://localhost:8080"

def run():
  data= []
  with open('websites.csv', newline='') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=' ')
    for row in spamreader:
      data.append(row[0])
  with open('result.csv', 'a', newline='') as csvfile:
    csvfile.truncate(0)
    writer = csv.writer(csvfile)
    count = 1
    size = len(data)
    for row in data:
      print("Job : Working on " + row + " " + str(count) + "/" + str(size) + " left")
      count+= 1
      try :
        validator = requests.get("http://www." + row,  timeout=5)
        request = requests.get(url = REQUEST_URL, params = {'url' : validator.url}) 
        request = request.json()
        if request['success']:
          if (len(request['assets']) < 1) :
            writer.writerow([row, "Failed, this website probably use a svg/css html element on logo or blocked our connection"])
          else : 
            writer.writerow([row, "ok", request['assets'][-1]['url'], str(request['assets'][-1]['rate'])])
        else :
          raise "Failed"
      except :
         writer.writerow([row, "Failed, this website is off or blocked our connection"])

if __name__ == "__main__":
    run()
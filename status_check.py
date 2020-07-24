from urlparse import urlparse
import threading
import httplib, sys, time

url_status={}

def performCheck(name,url):
    while True:
        status, url = getStatus(url)
        url_status.setdefault(name, []).insert(0,status)
        url_status[name] = url_status[name][:6]
        print(url_status[name])
        time.sleep(3)

def getStatus(ourl):
    try:
        url = urlparse(ourl)
        conn = httplib.HTTPConnection(url.netloc)
        conn.request("HEAD", url.path)
        res = conn.getresponse()
        return res.status, ourl
    except:
        return "error", ourl

threads = [threading.Thread(target=performCheck, args=(line.split(",")[0],line.split(",")[1].strip(),)) for line in open('urllist.txt')]

for thread in threads:
    thread.start()

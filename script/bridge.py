import subprocess
import sys

python_version = int(sys.version[0])

if python_version == 2:
    import urllib2 as requests
else:
    from urllib import request as requests

live_server_process = None
url = None

opener = requests.build_opener(requests.ProxyHandler({}))


def configure(host, port):
    global url
    url = "http://{}:{}/__live".format(host, port)


def send(data):
    if url is None:
        return

    try:
        body = data.encode("utf-8") if python_version != 2 else data
        opener.open(url, body).read()
    except Exception as e:
        print("live error: " + str(e))


def send_from_file(filepath):
    if url is None:
        return

    try:
        with open(filepath, "r") as f:
            body = f.read().encode("utf-8") if python_version != 2 else f.read()
        opener.open(url, body).read()
    except Exception as e:
        print("live error: " + str(e))


def start_server(server_path, host, port, root):
    global live_server_process
    if live_server_process is not None:
        print("server already running")
        return

    cmd = ["node", server_path, "--root", root]
    print("starting server: " + str(cmd))

    try:
        live_server_process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        print("server started with pid: " + str(live_server_process.pid))
    except Exception as e:
        print("could not start live server: " + str(e))


def stop_server():
    global live_server_process

    if live_server_process is None:
        print("server not running")
        return

    live_server_process.terminate()
    live_server_process.wait()
    live_server_process = None
    print("server stopped")


def is_running():
    if live_server_process is None:
        return False
    return live_server_process.poll() is None
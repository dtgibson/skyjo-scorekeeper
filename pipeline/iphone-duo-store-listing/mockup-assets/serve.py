# Serves this folder with an explicit UTF-8 charset on HTML (python -m http.server omits it).
import http.server, sys
class H(http.server.SimpleHTTPRequestHandler):
    extensions_map = {**http.server.SimpleHTTPRequestHandler.extensions_map, '.html': 'text/html; charset=utf-8', '.md': 'text/plain; charset=utf-8'}
    def log_message(self, *a): pass
http.server.ThreadingHTTPServer(('127.0.0.1', int(sys.argv[1])), lambda *a, **k: H(*a, directory=sys.argv[2], **k)).serve_forever()

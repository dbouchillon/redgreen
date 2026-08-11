from http.server import HTTPServer, BaseHTTPRequestHandler
import json

def load_config():
    with open("config.json", "r") as f:
        config = json.load(f)
        return config

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/red':
            config = load_config()
            if config['red'] == 'up':
                self.send_response(200)
                self.send_header('Content-Type', 'text/html; charset=utf-8')
                self.end_headers()
                self.wfile.write(b'<body style="background:#ffdddd"><h1>Red</h1></body>')
            else:
                self.send_response(503)
                self.end_headers()
                self.wfile.write(b'Red is down')
        elif self.path == '/green':
            config = load_config()
            if config['green'] == 'up':
                self.send_response(200)
                self.send_header('Content-Type', 'text/html; charset=utf-8')
                self.end_headers()
                self.wfile.write(b'<body style="background:#ddffdd"><h1>Green</h1></body>')
            else:
                self.send_response(503)
                self.end_headers()
                self.wfile.write(b'Green is down')
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not found')

if __name__ == '__main__':
    import ssl
    import os
    from pathlib import Path
    port = 8443

    cert_dir = Path("certs")
    cert_file = cert_dir / "cert.pem"
    key_file = cert_dir / "key.pem"

    if not cert_dir.exists() or not cert_file.exists() or not key_file.exists():
        print(f"Certificate files not found in {cert_dir}.\nRun the provided generation script or create certs/key.pem and certs/cert.pem")

    server = HTTPServer(('0.0.0.0', port), Handler)

    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain(certfile=str(cert_file), keyfile=str(key_file))
    server.socket = context.wrap_socket(server.socket, server_side=True)

    print(f'Serving on https://0.0.0.0:{port}')
    server.serve_forever()

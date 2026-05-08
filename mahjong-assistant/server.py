import http.server
import json
import base64
import urllib.request
import urllib.error
import os
import sys

PORT = 8080
MINIMAX_API_HOST = 'https://api.minimaxi.com'

class MahjongProxyHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=os.path.dirname(os.path.abspath(__file__)), **kwargs)

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_POST(self):
        if self.path == '/api/recognize':
            self.handle_recognize()
        else:
            self.send_error(404)

    def handle_recognize(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)

        try:
            data = json.loads(body)
        except json.JSONDecodeError:
            self.send_json_response(400, {'error': 'Invalid JSON'})
            return

        api_key = data.get('apiKey', '')
        image_base64 = data.get('image', '')
        prompt = data.get('prompt', '')

        if not api_key:
            self.send_json_response(400, {'error': 'API Key 未配置，请先在设置页面配置 Minimax API Key'})
            return

        if not image_base64:
            self.send_json_response(400, {'error': '请先上传图片'})
            return

        if not image_base64.startswith('data:'):
            image_url = 'data:image/jpeg;base64,' + image_base64
        else:
            image_url = image_base64

        payload = json.dumps({
            'prompt': prompt,
            'image_url': image_url
        }).encode('utf-8')

        req = urllib.request.Request(
            MINIMAX_API_HOST + '/v1/coding_plan/vlm',
            data=payload,
            headers={
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + api_key,
                'MM-API-Source': 'MahjongAssistant'
            },
            method='POST'
        )

        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                resp_data = json.loads(resp.read().decode('utf-8'))
                base_resp = resp_data.get('base_resp', {})
                if base_resp.get('status_code') != 0:
                    self.send_json_response(502, {
                        'error': 'Minimax API 错误: ' + base_resp.get('status_msg', '未知错误')
                    })
                    return
                self.send_json_response(200, resp_data)
        except urllib.error.HTTPError as e:
            error_body = e.read().decode('utf-8', errors='replace')
            try:
                error_data = json.loads(error_body)
                msg = error_data.get('base_resp', {}).get('status_msg', error_body)
            except json.JSONDecodeError:
                msg = error_body
            self.send_json_response(e.code, {'error': 'API 请求失败 (' + str(e.code) + '): ' + msg})
        except urllib.error.URLError as e:
            self.send_json_response(502, {'error': '网络错误: ' + str(e.reason)})
        except Exception as e:
            self.send_json_response(500, {'error': '服务器错误: ' + str(e)})

    def send_json_response(self, code, data):
        self.send_response(code)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False).encode('utf-8'))

    def log_message(self, format, *args):
        sys.stderr.write('[%s] %s\n' % (self.log_date_time_string(), format % args))

if __name__ == '__main__':
    import socket
    class ReusableHTTPServer(http.server.HTTPServer):
        allow_reuse_address = True
        allow_reuse_port = True
    with ReusableHTTPServer(('', PORT), MahjongProxyHandler) as httpd:
        print('麻将助手预览服务器启动: http://localhost:' + str(PORT) + '/preview/index.html')
        httpd.serve_forever()

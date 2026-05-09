import http.server
import json
import os
import sys
import threading
import uuid
import time

import requests

PORT = 8080
MINIMAX_API_HOST = 'https://api.minimaxi.com'

jobs = {}
jobs_lock = threading.Lock()

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

    def do_GET(self):
        if self.path.startswith('/api/job/'):
            self.handle_job_status()
        else:
            super().do_GET()

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

        job_id = str(uuid.uuid4())[:8]

        with jobs_lock:
            jobs[job_id] = {'status': 'processing', 'result': None, 'error': None, 'created': time.time()}

        thread = threading.Thread(
            target=self._call_minimax_api,
            args=(job_id, api_key, image_url, prompt),
            daemon=True
        )
        thread.start()

        self.send_json_response(202, {'jobId': job_id, 'status': 'processing'})

    def _call_minimax_api(self, job_id, api_key, image_url, prompt):
        payload = {
            'prompt': prompt,
            'image_url': image_url
        }
        headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + api_key,
            'MM-API-Source': 'MahjongAssistant'
        }

        try:
            for attempt in range(3):
                try:
                    resp = requests.post(
                        MINIMAX_API_HOST + '/v1/coding_plan/vlm',
                        json=payload,
                        headers=headers,
                        timeout=120
                    )
                    break
                except (requests.exceptions.Timeout, requests.exceptions.ConnectionError) as exc:
                    self.log_message('Job %s attempt %d failed: %s', job_id, attempt + 1, str(exc)[:200])
                    if attempt < 2:
                        time.sleep(2 * (attempt + 1))
            else:
                with jobs_lock:
                    jobs[job_id] = {'status': 'error', 'result': None, 'error': 'Minimax API 多次重试后仍超时，请稍后重试', 'created': jobs[job_id]['created']}
                return

            self.log_message('Job %s API status: %d', job_id, resp.status_code)

            try:
                resp_data = resp.json()
            except ValueError:
                with jobs_lock:
                    jobs[job_id] = {'status': 'error', 'result': None, 'error': 'Minimax API 返回非JSON响应 (HTTP %d)' % resp.status_code, 'created': jobs[job_id]['created']}
                return

            base_resp = resp_data.get('base_resp', {})
            if base_resp.get('status_code') != 0:
                with jobs_lock:
                    jobs[job_id] = {'status': 'error', 'result': None, 'error': 'Minimax API 错误: ' + base_resp.get('status_msg', '未知错误'), 'created': jobs[job_id]['created']}
                return

            with jobs_lock:
                jobs[job_id] = {'status': 'done', 'result': resp_data, 'error': None, 'created': jobs[job_id]['created']}

        except Exception as e:
            self.log_message('Job %s unexpected error: %s', job_id, str(e)[:200])
            with jobs_lock:
                jobs[job_id] = {'status': 'error', 'result': None, 'error': '服务器错误: ' + str(e)[:200], 'created': jobs[job_id]['created']}

    def handle_job_status(self):
        job_id = self.path.split('/api/job/')[-1].split('?')[0]

        with jobs_lock:
            job = jobs.get(job_id)

        if not job:
            self.send_json_response(404, {'error': '任务不存在'})
            return

        response = {'status': job['status']}
        if job['status'] == 'done' and job['result']:
            response['result'] = job['result']
        elif job['status'] == 'error' and job['error']:
            response['error'] = job['error']

        self.send_json_response(200, response)

        if job['status'] in ('done', 'error') and time.time() - job.get('created', 0) > 300:
            with jobs_lock:
                jobs.pop(job_id, None)

    def send_json_response(self, code, data):
        self.send_response(code)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False).encode('utf-8'))

    def log_message(self, format, *args):
        sys.stderr.write('[%s] %s\n' % (self.log_date_time_string(), format % args))

if __name__ == '__main__':
    class ReusableHTTPServer(http.server.HTTPServer):
        allow_reuse_address = True
        allow_reuse_port = True
    with ReusableHTTPServer(('', PORT), MahjongProxyHandler) as httpd:
        print('麻将助手预览服务器启动: http://localhost:' + str(PORT) + '/preview/index.html')
        httpd.serve_forever()

from flask import Flask

app = Flask(__name__)
port = 8080

@app.route('/')
def home():
    return '¡Hola Mundo! ESTA ES MI PRACTIQUITA - AMR'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port)

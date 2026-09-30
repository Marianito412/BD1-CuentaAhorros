import os
from flask import Flask, send_from_directory, jsonify, request
from flask_cors import CORS

app = Flask(__name__, static_folder='dist', static_url_path='/')

# ==========================================
# 1. PLACE YOUR API ENDPOINTS HERE
# ==========================================

@app.route('/api/login', methods=['POST'])
def login():
    req_data = request.get_json() or {}
    print(req_data)
    return jsonify({
        "status": "success",
        "received": req_data
    })

@app.route('/api/getAccounts', methods=['GET'])
def getAccounts():
    pass

@app.route('/api/getAccountStatements', methods=['GET'])
def getAccountStatements():
    pass

@app.route('/api/getAccountBeneficiaries', methods=['GET'])
def getAccountBeneficaries():
    pass

# ==========================================
# 2. FRONTEND & SPA CATCH-ALL ROUTE
# ==========================================

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def catch_all(path):
    # Prevent API route typos from accidentally returning index.html
    if path.startswith('api/'):
        return jsonify({"error": "API route not found"}), 404

    # Check if the requested path matches an actual static asset file on disk
    full_path = os.path.join(app.static_folder, path)
    if path != "" and os.path.exists(full_path):
        return send_from_directory(app.static_folder, path)
    
    # Fallback to index.html to let React Router resolve client-side routes
    return send_from_directory(app.static_folder, 'index.html')

if __name__ == '__main__':
    CORS(app)
    app.run(port=5000, debug=True)

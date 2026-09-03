from flask import Flask, request

app = Flask(__name__)

stores = [
    {
        "name": "My Store",
        "items": [
            {
                "name": "Chair",
                "price": 15.99
            }
        ]
    }

]

@app.get("/store") #http://127.0.0.1:5000/store
def get_stores():
        return {"stores": stores}

@app.post("/store")
def create_store():
    request_data = request.get_json()
    new_store = {"name": request_data["name"], "items": []}
    stores.append(new_store)
    print(stores)
    return new_store, 201

@app.post("/store/<string:name>/item")
def create_item(name):
    request_data = request.get_json()
    for store in stores:
        if store["name"] == name:
            new_item = {"name": request_data["name"], "price": request_data["price"]}
            store["items"].append(new_item)
            return new_item, 201
    return {"message": "Store with that name does not exist"}, 404


@app.get("/store 2") #http://127.0.0.1:5000/store
def get_store2():

        return {"stores": stores}


if __name__ == "__main__":
    app.run(debug=True)
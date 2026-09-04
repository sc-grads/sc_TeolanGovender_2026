import uuid
from flask import Flask, request
from flask_smorest import abort
from db import stores, items

app = Flask(__name__)


#---------------------------------------Items---------------------------------------

#--gets specific item--
@app.get("/item/<string:item_id>")
def get_item(item_id):
    try:
        return items[item_id]
    except KeyError:
        abort(404, message="Store not found")

#--creates an item--
@app.post("/item")
def create_item():
    item_data = request.get_json()
    # Here not only we need to validate data exists,
    # But also what type of data. Price should be a float,
    # for example...
    if (
        "price" not in item_data
        or "store_id" not in item_data
        or "name" not in item_data
    ):
        abort(
            400,
            message="Bad request. Ensure 'price', 'store_id', and 'name' are included in the JSON payload.",
        )
    for item in items.values():
        if (
            item_data["name"] == item["name"]
            and item_data["store_id"] == item["store_id"]
        ):
            abort(400, message=f"Item already exists.")

    item_id = uuid.uuid4().hex
    item = {**item_data, "id": item_id}
    items[item_id] = item

    return item

#--gets all items--
@app.get("/item")
def get_all_items():
    return {"items": list(items.values())}



#---------------------------------------Stores---------------------------------------

@app.get("/store/<string:store_id>")
def get_store(store_id):
    try:
        # Here you might also want to add the items in this store
        # We'll do that later on in the course
        return stores[store_id]
    except KeyError:
        abort(404, message="Store not found")


@app.post("/store") # Register route for HTTP POST requests to /store
def create_store():
    store_data = request.get_json() # Extract incoming JSON body into a dictionary
    
    if "name" not in store_data:
        abort(
            400,
            message="Bad request. Ensure 'name' is included in the JSON payload.",
        )
    for store in stores.values():
        if store_data["name"] == store["name"]:
            abort(400, message=f"Store already exists.")

    store_id = uuid.uuid4().hex # Generate a unique ID string
    store = {**store_data, "id": store_id} # Merge request data with the new ID
    stores[store_id] = store # Store the new record in the main stores dictionary

    return store # Return response (Flask automatically serializes to JSON)


@app.get("/store")
def get_stores():
    return {"stores": list(stores.values())}
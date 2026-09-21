import { useEffect, useState } from "react";
import { config } from "../../../config";

interface OrderItem {
  product_id: number;
  quantity: number;
  product: {
    name: string;
    image_url: string;
  };
}

interface Order {
  order_id: number;
  order_date: string;
  order_amount: number;
  status: string;
  items: OrderItem[];
}

const Orders = () => {
  const [orders, setOrders] = useState<Order[]>([]);

  const fetchOrders = async () => {
    const token = localStorage.getItem("access_token");
    const response = await fetch(`${config.baseUrl}/orders`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    const data = await response.json();
    if (response.ok) {
      setOrders(data);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  return (
    <div className="p-5">
      <h1 className="text-2xl font-bold mb-5">My Orders</h1>
      {orders.length === 0 ? (
        <p>You have no orders yet.</p>
      ) : (
        <div className="space-y-4">
          {orders.map((order) => (
            <div key={order.order_id} className="border p-4 rounded">
              <div className="flex justify-between">
                <div>
                  <h2 className="font-bold">Order #{order.order_id}</h2>

                  <p className="text-gray-600">{new Date(order.order_date).toLocaleDateString()}</p>
                </div>
                <p className="font-bold"> R {Number(order.order_amount).toFixed(2)}</p>
              </div>

              {/* show the product */}
              <div className="flex gap-2 mt-3">
                {order.items.map((item) => (
                  <img key={item.product_id} src={item.product.image_url} alt={item.product.name} title={item.product.name} className="w-12 h-12 object-contain border rounded"/>))}
              </div>

              <div className="mt-3">
                <p>
                  {order.items.reduce(
                    (total, item) => total + item.quantity,
                    0
                  )}{" "}
                  items
                </p>
                <p className="mt-1">
                  Status: <span className="font-semibold">{order.status}</span>
                </p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default Orders;
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
  const [search, setSearch] = useState("");
  const [dateFilter, setDateFilter] = useState("all");
  const [sortOrder, setSortOrder] = useState("newest");

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

  const filteredOrders = orders
    .filter((order) => {
      const searchText = search.toLowerCase();

      // Search by order number
      const matchesOrderNumber = order.order_id
        .toString()
        .includes(searchText);

      // Search by product name
      const matchesProduct = order.items.some((item) =>
        item.product.name.toLowerCase().includes(searchText)
      );

      // Search must match either order number or product
      const matchesSearch =
        searchText === "" || matchesOrderNumber || matchesProduct;

      // Date filtering
      const orderDate = new Date(order.order_date);
      const now = new Date();

      const lastMonth = new Date(now);
      lastMonth.setMonth(now.getMonth() - 1);

      const lastThreeMonths = new Date(now);
      lastThreeMonths.setMonth(now.getMonth() - 3);

      const lastSixMonths = new Date(now);
      lastSixMonths.setMonth(now.getMonth() - 6);

      let matchesDate = true;

      if (dateFilter === "lastMonth") {
        matchesDate = orderDate >= lastMonth;
      }

      if (dateFilter === "last3Months") {
        matchesDate = orderDate >= lastThreeMonths;
      }

      if (dateFilter === "last6Months") {
        matchesDate = orderDate >= lastSixMonths;
      }

      if (dateFilter === "older") {
        matchesDate = orderDate < lastSixMonths;
      }

      return matchesSearch && matchesDate;
    })
    .sort((a, b) => {
      const dateA = new Date(a.order_date).getTime();
      const dateB = new Date(b.order_date).getTime();

      if (sortOrder === "newest") {
        return dateB - dateA;
      }

      return dateA - dateB;
    });

  return (
    <div className="p-5">
      <h1 className="mb-5 text-2xl font-bold">My Orders</h1>

      {/* Search and filters */}
      <div className="mb-6 flex flex-col items-start gap-3 sm:flex-row sm:items-center">
        {/* Search */}
        <input
          type="text"
          placeholder="Search orders..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full flex-1 rounded-full text-gray-900 text-lg placeholder:text-base placeholder:tracking-wide shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 placeholder:font-normal focus:ring-1 focus:ring-darkText sm:text-sm px-4 py-2"
          
        />

        {/* Date filter */}
        <select
          value={dateFilter}
          onChange={(e) => setDateFilter(e.target.value)}
          className="rounded-md border px-4 py-2"
        >
          <option value="all">All Orders</option>
          <option value="lastMonth">Last Month</option>
          <option value="last3Months">Last 3 Months</option>
          <option value="last6Months">Last 6 Months</option>
          <option value="older">Older</option>
        </select>

        {/* Sort order */}
        <select
          value={sortOrder}
          onChange={(e) => setSortOrder(e.target.value)}
          className="rounded-md border px-4 py-2"
        >
          <option value="newest">Newest First</option>
          <option value="oldest">Oldest First</option>
        </select>
      </div>

      {/* Orders */}
      {orders.length === 0 ? (
        <p>You have no orders yet.</p>
      ) : filteredOrders.length === 0 ? (
        <p className="text-gray-500">
          No orders match your search or filter.
        </p>
      ) : (
        <div className="space-y-4">
          {filteredOrders.map((order) => (
            <div key={order.order_id} className="rounded border p-4">
              <div className="flex justify-between">
                <div>
                  <h2 className="font-bold">Order #{order.order_id}</h2>

                  <p className="text-gray-600">
                    {new Date(order.order_date).toLocaleDateString()}
                  </p>
                </div>

                <p className="font-bold">
                  R {Number(order.order_amount).toFixed(2)}
                </p>
              </div>

              {/* Show the products */}
              <div className="mt-3 flex gap-2">
                {order.items.map((item) => (
                  <img
                    key={item.product_id}
                    src={item.product.image_url}
                    alt={item.product.name}
                    title={item.product.name}
                    className="h-12 w-12 rounded border object-contain"
                  />
                ))}
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
                  Status:{" "}
                  <span className="font-semibold">{order.status}</span>
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
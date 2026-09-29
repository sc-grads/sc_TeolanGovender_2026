import { useEffect, useState } from "react";
import { config } from "../../../config";

interface OrderProps {
  order_id: number;
  user_id: number;
  first_name: string;
  last_name: string;
  order_date: string;
  order_amount: number;
  status: string;
  address_id: number;
  address_line_1: string;
  address_line_2: string;
  city: string;
  province: string;
  postal_code: string;
}

const statuses = [
  "Paid",
  "Processing",
  "Shipped",
  "Delivered",
  "Cancelled",
];

const OrderManagement = () => {
  const [orders, setOrders] = useState<OrderProps[]>([]);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");

  const fetchOrders = async () => {
    const token = localStorage.getItem("access_token");

    const response = await fetch(`${config.baseUrl}/admin/orders`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    const data = await response.json();
    setOrders(data);
  };

  const updateStatus = async (orderId: number, newStatus: string) => {
    const token = localStorage.getItem("access_token");

    await fetch(`${config.baseUrl}/admin/orders/${orderId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        status: newStatus,
      }),
    });

    fetchOrders();
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  const filteredOrders = orders.filter((order) => {
    const query = search.toLowerCase();

    const matchesSearch =
      String(order.order_id ?? "").includes(query) ||
      String(order.user_id ?? "").includes(query) ||
      String(order.address_line_1 ?? "")
        .toLowerCase()
        .includes(query) ||
      String(order.address_line_2 ?? "")
        .toLowerCase()
        .includes(query) ||
      String(order.first_name ?? "")
        .toLowerCase()
        .includes(query) ||
      String(order.last_name ?? "")
        .toLowerCase()
        .includes(query);

    const matchesStatus =
      status === "" || order.status === status;

    return matchesSearch && matchesStatus;
  });

  return (
    <div className="p-5">
      <h1 className="text-2xl font-bold mb-4">
        Order Management
      </h1>

      <div className="flex gap-3 mb-4">
        <input
          type="text"
          placeholder="search for an order"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="border p-2 w-64"
        />

        <select
          value={status}
          onChange={(e) => setStatus(e.target.value)}
          className="border p-2"
        >
          <option value="">All Statuses</option>
          <option value="Paid">Paid</option>
          <option value="Processing">Processing</option>
          <option value="Shipped">Shipped</option>
          <option value="Delivered">Delivered</option>
          <option value="Cancelled">Cancelled</option>
        </select>
      </div>

      <table className="w-full border border-gray-300">
        <thead>
          <tr className="bg-gray-200">
            <th className="border p-2">Order Number</th>
            <th className="border p-2">Customer</th>
            <th className="border p-2">Date</th>
            <th className="border p-2">Total</th>
            <th className="border p-2">Status</th>
            <th className="border p-2">Going to</th>
          </tr>
        </thead>

        <tbody>
          {filteredOrders.map((order) => {
            const currentIndex = statuses.indexOf(order.status);

            const isCancelled = order.status === "Cancelled";
            const isDelivered = order.status === "Delivered";

            const sliderColor = isCancelled
              ? "accent-red-600"
              : isDelivered
              ? "accent-green-500"
              : "accent-sky-600";

            const labelColor = isCancelled
              ? "text-red-600 font-semibold"
              : isDelivered
              ? "text-green-600 font-semibold"
              : "";

            return (
              <tr key={order.order_id}>
                <td className="border p-2">
                  {order.order_id}
                </td>

                <td className="border p-2">
                  ID: {order.user_id} - {order.first_name}{" "}
                  {order.last_name}
                </td>

                <td className="border p-2">
                  {new Date(
                    order.order_date
                  ).toLocaleDateString()}
                </td>

                <td className="border p-2">
                  R {order.order_amount.toFixed(2)}
                </td>

                <td className="border p-2">
                  <div className="w-80">
                    <input
                      type="range"
                      min="0"
                      max={statuses.length - 1}
                      step="1"
                      value={
                        currentIndex === -1
                          ? 0
                          : currentIndex
                      }
                      onChange={(e) => {
                        const newIndex = Number(
                          e.target.value
                        );

                        if (
                          Math.abs(
                            newIndex - currentIndex
                          ) === 1
                        ) {
                          updateStatus(
                            order.order_id,
                            statuses[newIndex]
                          );
                        }
                      }}
                      className={`w-full cursor-pointer ${sliderColor}`}
                    />

                    <div
                      className={`flex justify-between text-xs mt-1 ${labelColor}`}
                    >
                      {statuses.map((statusName) => (
                        <span key={statusName}>
                          {statusName}
                        </span>
                      ))}
                    </div>
                  </div>
                </td>

                <td className="border p-2">
                  {order.address_line_1}{" "}
                  {order.address_line_2}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
};

export default OrderManagement;
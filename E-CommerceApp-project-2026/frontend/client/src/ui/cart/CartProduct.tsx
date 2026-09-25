import { useState } from "react";
import { FaMinus, FaPlus, FaTrash } from "react-icons/fa";
import { config } from "../../../config";
import { type CartItemProps } from "../../../type";

interface Props {
  item: CartItemProps;
  onCartUpdated: () => void;
}

const CartProduct = ({ item, onCartUpdated }: Props) => {
  const [loading, setLoading] = useState(false);

  const subtotal = item.product.price * item.quantity;

  const updateCart = async (
    method: "POST" | "PATCH" | "DELETE"
  ) => {
    const token = localStorage.getItem("access_token");

    if (!token) {
      return;
    }

    try {
      setLoading(true);

      const response = await fetch(`${config.baseUrl}/cart`, {
        method,
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          product_id: item.product.product_id,
          ...(method === "POST" && { quantity: 1 }),
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(
          data.message || data.description || "Failed to update cart."
        );
      }

      onCartUpdated();
    } catch (error) {
      console.error("Cart update error:", error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex gap-3 sm:gap-5 py-5 sm:py-6 border-b border-gray-200">

      {/* Product Image */}
      <div className="w-20 h-20 sm:w-28 sm:h-28 shrink-0 rounded-lg bg-gray-50 border flex items-center justify-center p-2">
        <img
          src={item.product.image_url}
          alt={item.product.name}
          className="w-full h-full object-contain"
        />
      </div>

      {/* Product Info */}
      <div className="flex-1 min-w-0">

        <h2 className="text-base sm:text-lg font-semibold text-darkText break-words">
          {item.product.name}
        </h2>

        <p className="text-gray-500 text-sm mt-1 line-clamp-2">
          {item.product.description}
        </p>

        {/* Controls */}
        <div className="flex flex-wrap items-center justify-between gap-3 mt-4">

          {/* Quantity controls */}
          <div className="flex items-center gap-2 shrink-0">

            <button
              onClick={() => updateCart("PATCH")}
              disabled={item.quantity === 1 || loading}
              aria-label="Decrease quantity"
              className={`w-8 h-8 rounded-md border flex items-center justify-center transition ${
                item.quantity === 1
                  ? "bg-gray-100 text-gray-300 cursor-not-allowed"
                  : "bg-white text-darkText hover:bg-gray-100"
              }`}
            >
              <FaMinus size={11} />
            </button>

            <span className="w-8 text-center font-semibold">
              {item.quantity}
            </span>

            <button
              onClick={() => updateCart("POST")}
              disabled={
                loading ||
                item.quantity >= item.product.quantity
              }
              aria-label="Increase quantity"
              className={`w-8 h-8 rounded-md border flex items-center justify-center transition ${
                item.quantity >= item.product.quantity
                  ? "bg-gray-100 text-gray-300 cursor-not-allowed"
                  : "bg-white text-darkText hover:bg-gray-100"
              }`}
            >
              <FaPlus size={11} />
            </button>

          </div>

          {/* Subtotal + Remove */}
          <div className="flex items-center gap-4 shrink-0">

            <p className="text-base sm:text-lg font-bold text-darkText whitespace-nowrap">
              R {subtotal.toFixed(2)}
            </p>

            <button
              onClick={() => updateCart("DELETE")}
              disabled={loading}
              aria-label="Remove item"
              className="text-red-500 hover:text-red-700 transition disabled:opacity-50"
            >
              <FaTrash size={15} />
            </button>

          </div>

        </div>
      </div>
    </div>
  );
};

export default CartProduct;
import { useState } from "react";
import { type ProductProps } from "../../../type";
import { config } from "../../../config";
import { FaCheck } from "react-icons/fa";

interface Props {
  product: ProductProps;
}

const AddToCartBtn = ({ product }: Props) => {
  const [loading, setLoading] = useState(false);
  const [added, setAdded] = useState(false);

  const outOfStock = product.quantity === 0;

  const getGuestToken = () => {
    let guestToken = localStorage.getItem("guest_token");

    if (!guestToken) {
      guestToken = crypto.randomUUID();
      localStorage.setItem("guest_token", guestToken);
    }

    return guestToken;
  };

  const handleAddToCart = async () => {
    if (outOfStock) {
      return;
    }

    try {
      setLoading(true);

      const token = localStorage.getItem("access_token");

      const headers: HeadersInit = {
        "Content-Type": "application/json",
      };

      if (token) {
        headers.Authorization = `Bearer ${token}`;
      } else {
        headers["X-Guest-Token"] = getGuestToken();
      }

      const response = await fetch(`${config.baseUrl}/cart`, {
        method: "POST",
        headers,
        body: JSON.stringify({
          product_id: product.product_id,
          quantity: 1,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Failed to add item.");
      }

      setAdded(true);
      setTimeout(() => setAdded(false), 2000);

      window.dispatchEvent(new Event("cartUpdated"));
    } catch (error) {
      console.error("Cart error:", error);

      alert(
        error instanceof Error
          ? error.message
          : "Something went wrong."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <button
      onClick={handleAddToCart}
      disabled={loading || outOfStock}
      className={`w-full py-2 rounded-md font-medium transition ${
        outOfStock
          ? "bg-gray-300 text-gray-500 cursor-not-allowed"
          : added
          ? "bg-green-600 text-white"
          : "bg-darkText text-white hover:bg-greenText"
      } disabled:opacity-100`}
    >
      {outOfStock ? (
        "Out of Stock"
      ) : loading ? (
        "Adding..."
      ) : added ? (
        <span className="flex items-center justify-center gap-2">
          <FaCheck /> Added
        </span>
      ) : (
        "Add to Cart"
      )}
    </button>
  );
};

export default AddToCartBtn;
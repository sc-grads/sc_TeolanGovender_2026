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

  const handleAddToCart = async () => {
    const token = localStorage.getItem("access_token");

    if (!token) {
      alert("Please login before adding items to your cart.");
      return;
    }

    try {
      setLoading(true);

      const response = await fetch(`${config.baseUrl}/cart`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
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

      // Reset button after 2 seconds
      setTimeout(() => setAdded(false), 2000);

      // We'll use this later for the cart badge.
      window.dispatchEvent(new Event("cartUpdated"));
    } catch (error) {
      console.error("Cart error:", error);
      alert(error instanceof Error ? error.message : "Something went wrong.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <button
      onClick={handleAddToCart}
      disabled={loading}
      className={`w-full py-2 rounded-md font-medium transition ${
        added
          ? "bg-green-600 text-white"
          : "bg-darkText text-white hover:bg-gray-800"
      } disabled:opacity-50`}
    >
      {loading ? (
        "Adding..."
      ) : added ? (
        <span className="flex items-center justify-center gap-2">
          <FaCheck />
          Added
        </span>
      ) : (
        "Add to Cart"
      )}
    </button>
  );
};

export default AddToCartBtn;
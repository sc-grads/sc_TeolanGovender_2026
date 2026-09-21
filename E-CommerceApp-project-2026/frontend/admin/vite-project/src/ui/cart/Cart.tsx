import { useCallback, useEffect, useState } from "react";
import { config } from "../../../config";
import { type CartProps } from "../../../type";
import CartProduct from "./CartProduct";

const Cart = () => {
  const [cart, setCart] = useState<CartProps | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const handleCheckout = async () => {
  const token = localStorage.getItem("access_token");

  if (!token) {
    return;
  }

  try {
    const response = await fetch(`${config.baseUrl}/checkout`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(
        data.message ||
          data.description ||
          "Checkout failed."
      );
    }

    console.log("Order created:", data);

    // Refresh cart
    await fetchCart();

    } catch (error) {
    console.error("Checkout error:", error);
    }
  };

  const fetchCart = useCallback(async () => {
    const token = localStorage.getItem("access_token");

    if (!token) {
      setError("Please login to view your cart.");
      setLoading(false);
      return;
    }

    try {
      const response = await fetch(`${config.baseUrl}/cart`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(
          data.message ||
            data.description ||
            "Failed to load cart."
        );
      }

      setCart(data);
      setError("");
    } catch (error) {
      console.error(error);
      setError(
        error instanceof Error
          ? error.message
          : "Something went wrong."
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchCart();
  }, [fetchCart]);

  const total =
    cart?.items.reduce(
      (sum, item) =>
        sum + item.product.price * item.quantity,
      0
    ) ?? 0;

  const itemCount =
    cart?.items.reduce(
      (sum, item) => sum + item.quantity,
      0
    ) ?? 0;

  if (loading) {
    return (
      <div className="max-w-6xl mx-auto py-20 text-center">
        Loading cart...
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-6xl mx-auto py-20 text-center text-red-500">
        {error}
      </div>
    );
  }

  if (!cart || cart.items.length === 0) {
    return (
      <div className="max-w-6xl mx-auto py-20 text-center">
        <h2 className="text-2xl font-semibold mb-3"> Your cart is empty. </h2>
        <p className="text-gray-500"> Add some products from the shop. </p>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto px-4 py-10">
      <h1 className="text-3xl font-semibold mb-8"> Shopping Cart </h1>

      <div className="grid lg:grid-cols-[2fr_1fr] gap-10">
        {/* Cart Products */}
        <div className="bg-white rounded-xl border p-6">
          {cart.items.map((item) => (<CartProduct key={item.product.product_id} item={item} onCartUpdated={fetchCart}/>))}
        </div>

        {/* order summary */}
        <div className="bg-white rounded-xl border p-6 h-fit sticky top-24">
          <h2 className="text-xl font-semibold mb-6">
            Order Summary
          </h2>

          <div className="flex justify-between mb-4">
            <span>Items</span>
            <span>{itemCount}</span>
          </div>

          <div className="flex justify-between mb-6">
            <span>Total</span>

            <span className="font-bold text-xl">
              R {total.toFixed(2)}
            </span>
          </div>

            <button
              onClick={handleCheckout}
              className="w-full bg-darkText text-white py-3 rounded-lg hover:bg-gray-800 transition">
              Proceed to Checkout
            </button>
        </div>
      </div>
    </div>
  );
};

export default Cart;
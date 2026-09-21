import { useCallback, useEffect, useState } from "react";
import { config } from "../../../config";
import { type CartProps } from "../../../type";

import CartProduct from "./CartProduct";
import OrderSummary from "./OrderSummary";
import StripeCheckout from "../checkout/StripeCheckout";

const Cart = () => {
  const [cart, setCart] = useState<CartProps | null>(null);
  const [loading, setLoading] = useState(true);
  const [showCheckout, setShowCheckout] = useState(false);

  const fetchCart = useCallback(async () => {
    const token = localStorage.getItem("access_token");
    if (!token) return setLoading(false);

    const response = await fetch(`${config.baseUrl}/cart`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    
    if (response.ok) {
      setCart(await response.json());
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    fetchCart();
  }, [fetchCart]);

  const handleCheckout = async () => {
    const token = localStorage.getItem("access_token");
    if (!token) return;

    await fetch(`${config.baseUrl}/checkout`, {
      method: "POST",
      headers: { Authorization: `Bearer ${token}` },
    });

    await fetchCart();
  };

  const total =
    cart?.items.reduce(
      (sum, item) => sum + item.product.price * item.quantity,
      0
    ) ?? 0;

  const itemCount =
    cart?.items.reduce((sum, item) => sum + item.quantity, 0) ?? 0;

  if (loading) {
    return (
      <div className="max-w-6xl mx-auto py-20 text-center">Loading cart...</div>
    );
  }

  if (!cart || cart.items.length === 0) {
    return (
      <div className="max-w-6xl mx-auto py-20 text-center">
        <h2 className="text-2xl font-semibold mb-3">Cart is empty</h2>
      </div>
    );
  }

  return (
    <>
      <div className="max-w-6xl mx-auto px-4 py-10">
        <h1 className="text-3xl font-semibold mb-8">Cart</h1>

        <div className="grid lg:grid-cols-[2fr_1fr] gap-10">
          <div className="bg-white rounded-xl border p-6">
            {cart.items.map((item) => (
              <CartProduct key={item.product.product_id} item={item} onCartUpdated={fetchCart}/>
            ))}
          </div>

          <OrderSummary total={total} itemCount={itemCount} onCheckout={() => setShowCheckout(true)}/>
        </div>
      </div>
      {showCheckout && (<StripeCheckout amount={total} onPaymentSuccess={handleCheckout} onClose={() => setShowCheckout(false)}/>)}
    </>
  );
};

export default Cart;